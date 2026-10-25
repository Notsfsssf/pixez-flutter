/*
 * Copyright (C) 2020. by perol_notsf, All rights reserved
 *
 * This program is free software: you can redistribute it and/or modify it under
 * the terms of the GNU General Public License as published by the Free Software
 * Foundation, either version 3 of the License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful, but WITHOUT ANY
 * WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A
 * PARTICULAR PURPOSE.  See the GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License along with
 * this program. If not, see <http://www.gnu.org/licenses/>.
 */

/// llama.cpp 端侧推理引擎（实现 translator 包 [LlmGenerationEngine]）。
///
/// 架构：
/// - 权重加载与逐 token 推理都在长驻 **worker isolate** 内同步 FFI 调用
///   （单 token 50-200ms，放主 isolate 会卡 UI）；
/// - 生成循环每 token 之间 `await Future.delayed(Duration.zero)` 让出事件
///   循环，使取消（stop）消息得以插入——这是取消能生效的关键；
/// - token 的 UTF-8 piece 可能跨多字节（中文 BPE 常见），用 chunked
///   UTF-8 解码器增量拼接，不完整序列自动挂起等下一个 piece；
/// - host（LlmEngineHost）保证请求串行，engine 内不做排队。
///
/// 原生侧契约见 android/app/src/main/cpp/llama_shim.cpp。
library;

import 'dart:async';
import 'dart:convert';
import 'dart:ffi';
import 'dart:isolate';
import 'dart:typed_data';

import 'package:ffi/ffi.dart';
import 'package:translator/translator.dart';

import 'llama_ffi_bindings.dart';

/// piece 输出缓冲（字节）；llama.cpp 常规 BPE piece 远小于此。
const int _kPieceBufBytes = 64;

/// 多序列批量生成的输出缓冲（字节）：上限 8 段 × 每段数百 token 的
/// UTF-8 译文，64KB 富余；native 侧超出返回 -5（调用方回退逐段）。
const int _kMultiOutBytes = 64 * 1024;

class LlamaFfiEngine implements LlmGenerationEngine {
  /// 采样温度；<= 0 为贪心解码（翻译任务要稳定输出，默认贪心）。
  final double temperature;
  final double topP;

  LlamaFfiEngine({this.temperature = 0, this.topP = 0.9});

  LlmEngineState _state = LlmEngineState.unloaded;

  @override
  LlmEngineState get state => _state;

  Isolate? _isolate;
  SendPort? _workerPort;
  StreamSubscription<dynamic>? _workerSub;
  Completer<void>? _loadCompleter;
  Completer<void>? _freeCompleter;
  Completer<List<String>>? _multiCompleter;
  StreamController<String>? _activeGen;

  /// 实际生效的上下文容量（load 时记录），报错消息用它而非硬编码数字。
  int _loadedContextSize = 0;

  @override
  Future<void> loadModel(
    String modelPath, {
    required int contextSize,
    int? threads,
    bool flashAttn = false,
  }) async {
    await _shutdownWorker();
    _state = LlmEngineState.loading;
    _loadedContextSize = contextSize;
    final loaded = Completer<void>();
    _loadCompleter = loaded;

    final port = ReceivePort();
    _workerSub = port.listen(_onWorkerMessage, onError: (Object e) {
      _state = LlmEngineState.error;
      if (!loaded.isCompleted) {
        loaded.completeError(LlmModelNotReadyException('推理线程异常：$e'));
      }
    });
    try {
      _isolate = await Isolate.spawn(
        _workerMain,
        [port.sendPort, temperature, topP],
        debugName: 'llama.cpp',
      );
    } catch (e) {
      await _shutdownWorker();
      _state = LlmEngineState.error;
      throw LlmModelNotReadyException('无法启动推理线程：$e');
    }
    // worker 起来先回送自身端口，_onWorkerMessage 收到后自动发起 load。
    _pendingLoad = (
      path: modelPath,
      contextSize: contextSize,
      threads: threads ?? 0,
      flashAttn: flashAttn,
    );
    await loaded.future;
    _state = LlmEngineState.ready;
  }

  ({String path, int contextSize, int threads, bool flashAttn})? _pendingLoad;

  @override
  Stream<String> generateStream(String prompt, {required int maxTokens}) {
    if (_state != LlmEngineState.ready || _workerPort == null) {
      return Stream.error(
        LlmModelNotReadyException('模型未加载，无法生成'),
      );
    }
    final controller = StreamController<String>();
    _activeGen = controller;
    controller.onListen = () {
      _workerPort!.send(['gen', prompt, maxTokens]);
    };
    controller.onCancel = () {
      // 消费方取消：通知 worker 停止（循环在每个 token 边界响应）。
      _workerPort?.send(['stop']);
      _activeGen = null;
    };
    return controller.stream;
  }

  /// 多序列批量生成：一次同步 FFI 调用在 native 侧并行推进全部序列
  /// （共享前缀只 prefill 一次，生成阶段同批 decode，吞吐接近线性
  /// 提升）。批内不逐 token 回主 isolate，因此取消粒度是「整批完成」。
  @override
  Future<List<String>> generateBatch(
    List<String> prompts, {
    required int maxTokens,
  }) async {
    if (_state != LlmEngineState.ready || _workerPort == null) {
      throw LlmModelNotReadyException('模型未加载，无法生成');
    }
    final done = Completer<List<String>>();
    _multiCompleter = done;
    _workerPort!.send(['genMulti', prompts, maxTokens]);
    return done.future;
  }

  @override
  Future<void> cleanUp() async {
    if (_workerPort != null) {
      final freed = Completer<void>();
      _freeCompleter = freed;
      _workerPort!.send(['free']);
      // host 串行保证此时 worker 空闲；FFI 万一卡死则硬杀兜底。
      try {
        await freed.future.timeout(const Duration(seconds: 30));
      } on TimeoutException {
        await _shutdownWorker();
      }
    }
    await _shutdownWorker();
    _state = LlmEngineState.unloaded;
  }

  // ---- 主 isolate 侧消息处理 ----

  void _onWorkerMessage(dynamic raw) {
    final msg = raw as List<Object>;
    switch (msg[0] as String) {
      case 'port':
        _workerPort = msg[1] as SendPort;
        final pending = _pendingLoad;
        _pendingLoad = null;
        if (pending != null) {
          _workerPort!.send([
            'load',
            pending.path,
            pending.contextSize,
            pending.threads,
            pending.flashAttn ? 1 : 0,
          ]);
        }
        break;
      case 'ready':
        _loadCompleter?.complete();
        _loadCompleter = null;
        break;
      case 'loadfail':
        _loadCompleter?.completeError(
          LlmModelNotReadyException(
            '模型加载失败：文件损坏、量化不受支持或内存不足（code=${msg[1]}）',
          ),
        );
        _loadCompleter = null;
        _state = LlmEngineState.error;
        break;
      case 'nolib':
        _loadCompleter?.completeError(
          LlmModelNotReadyException('原生推理库不可用（libllamashim.so 加载失败）'),
        );
        _loadCompleter = null;
        _state = LlmEngineState.error;
        break;
      case 'tok':
        _activeGen?.add(msg[1] as String);
        break;
      case 'done':
        _finishGen();
        break;
      case 'multiDone':
        final c = _multiCompleter;
        _multiCompleter = null;
        c?.complete(msg[1] as List<String>);
        break;
      case 'multiErr':
        final c = _multiCompleter;
        _multiCompleter = null;
        c?.completeError(
          LlmModelNotReadyException('批量推理失败（native code=${msg[1]}）'),
        );
        break;
      case 'err':
        // 先 addError 再 close：反过来 addError 会落在已关闭的 controller
        // 上抛 "Cannot add event after closing"，错误丢失、上层只见流静默关闭。
        final gen = _activeGen;
        _activeGen = null;
        if (gen != null && !gen.isClosed) {
          gen.addError(_translateGenError(msg[1]));
          gen.close();
        }
        break;
      case 'freed':
        _freeCompleter?.complete();
        _freeCompleter = null;
        break;
    }
  }

  void _finishGen() {
    final gen = _activeGen;
    _activeGen = null;
    if (gen != null && !gen.isClosed) gen.close();
  }

  Exception _translateGenError(Object code) {
    switch (code) {
      case -2:
        // 上下文容量用 load 时记录的真实值：数字写死会误导排障
        // （配置明明是 4096，报错却显示 2048）。
        return LlmModelNotReadyException(
          '提示词超出上下文容量（$_loadedContextSize），请减少同页上下文',
        );
      case -3:
        return LlmModelNotReadyException('推理解码失败（可能内存不足）');
      default:
        return LlmModelNotReadyException('推理失败：$code');
    }
  }

  Future<void> _shutdownWorker() async {
    await _workerSub?.cancel();
    _workerSub = null;
    _isolate?.kill(priority: Isolate.immediate);
    _isolate = null;
    _workerPort = null;
    _activeGen = null;
    _loadCompleter = null;
    _freeCompleter = null;
    _multiCompleter = null;
    _pendingLoad = null;
  }
}

// ---- worker isolate（加载 + 推理都在这里，同步 FFI）----

void _workerMain(List<Object> args) {
  final mainPort = args[0] as SendPort;
  final temp = args[1] as double;
  final topP = args[2] as double;
  final port = ReceivePort();
  mainPort.send(['port', port.sendPort]);

  final LlamaFfiBindings bindings;
  try {
    bindings = LlamaFfiBindings();
  } catch (e) {
    mainPort.send(['nolib']);
    port.close();
    return;
  }
  final buf = calloc<Uint8>(_kPieceBufBytes);
  final multiOut = calloc<Uint8>(_kMultiOutBytes);
  var stopRequested = false;

  port.listen((dynamic raw) {
    try {
      final msg = raw as List<Object>;
      switch (msg[0] as String) {
        case 'load':
          final ok = bindings.load(
            msg[1] as String,
            msg[2] as int,
            temp,
            topP,
            msg[3] as int,
            flashAttn: (msg.length > 4 ? msg[4] : 0) != 0,
          );
          mainPort.send(ok == 1 ? ['ready'] : ['loadfail', ok]);
          break;
        case 'gen':
          stopRequested = false;
          _runGeneration(
            bindings: bindings,
            buf: buf,
            mainPort: mainPort,
            prompt: msg[1] as String,
            maxTokens: msg[2] as int,
            isStopped: () => stopRequested,
          );
          break;
        case 'genMulti':
          // 同步 FFI：整批完成才返回（native 内部并行 decode）。
          // 这里必须自己 catch：外层 catch 发的 'err' 走单序列流分支，
          // 批量调用的 Completer 收不到。
          try {
            final outputs = bindings.generateMulti(
              (msg[1] as List<Object>).cast<String>(),
              msg[2] as int,
              multiOut,
              _kMultiOutBytes,
            );
            mainPort.send(['multiDone', outputs]);
          } on LlamaMultiGenerateException catch (e) {
            mainPort.send(['multiErr', e.code]);
          } catch (e) {
            mainPort.send(['multiErr', '$e']);
          }
          break;
        case 'stop':
          stopRequested = true;
          break;
        case 'free':
          bindings.freeModel();
          malloc.free(buf);
          malloc.free(multiOut);
          mainPort.send(['freed']);
          port.close();
          Isolate.exit();
      }
    } catch (e) {
      mainPort.send(['err', '$e']);
    }
  });
}

/// 生成循环：FFI 逐 token 同步调用，token 间让出事件循环以响应 stop。
Future<void> _runGeneration({
  required LlamaFfiBindings bindings,
  required Pointer<Uint8> buf,
  required SendPort mainPort,
  required String prompt,
  required int maxTokens,
  required bool Function() isStopped,
}) async {
  final rc = bindings.start(prompt);
  if (rc != 0) {
    mainPort.send(['err', rc]);
    return;
  }
  // chunked UTF-8 解码：跨 piece 的多字节序列自动挂起拼装。
  final out = StringBuffer();
  final decoder = const Utf8Decoder(allowMalformed: true);
  final sink = decoder.startChunkedConversion(_StringBufferSink(out));
  var count = 0;
  while (!isStopped() && count < maxTokens) {
    final n = bindings.next(buf, _kPieceBufBytes);
    if (n == 0) break; // EOG：模型认为输出完整
    if (n < 0) {
      sink.close();
      mainPort.send(['err', n]);
      return;
    }
    sink.add(Uint8List.fromList(buf.asTypedList(n)));
    final text = out.toString();
    if (text.isNotEmpty) {
      out.clear();
      mainPort.send(['tok', text]);
    }
    count++;
    // 关键：让出事件循环，'stop' 消息才有机会被 listen 回调处理。
    await Future<void>.delayed(Duration.zero);
  }
  sink.close();
  final tail = out.toString();
  if (tail.isNotEmpty) {
    mainPort.send(['tok', tail]);
  }
  mainPort.send(['done']);
}

/// 把 chunked UTF-8 解码器的输出攒进 [buf]（StringBuffer 不是 Sink）。
class _StringBufferSink implements Sink<String> {
  final StringBuffer buf;
  _StringBufferSink(this.buf);

  @override
  void add(String data) => buf.write(data);

  @override
  void close() {}
}
