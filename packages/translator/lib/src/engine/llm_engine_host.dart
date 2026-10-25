/*
 * Copyright (C) 2020. by perol_notsf, All rights reserved
 *
 * This program is free software: you can redistribute it and/or modify it under
 * the terms of the GNU General Public License as published by the Free Software
 * Foundation, either version 3 of the License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful, but WITHOUT ANY
 * WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
 * FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License along with
 * this program. If not, see <http://www.gnu.org/licenses/>.
 *
 */

/// 端侧 LLM 引擎宿主（对齐参考 LlamaEngineHolder.kt 的生命周期语义）。
///
/// 进程内单实例：权重只加载一份；切换模型先 `cleanUp` 再 load。
/// 内存策略：
/// - **prewarm**：进入翻译页时用短句预热；未完成预热时首个请求复用同一把
///   初始化锁等待，不会重复加载；
/// - **idle unload**：每次 [touch] 重置 5 分钟倒计时，到点校验真实空闲时长
///   后 [unload]，释放 ~1GB 权重；**只 cleanUp 不 destroy**（destroy 后无法
///   再 load）；
/// - **Error 自愈**：上次 load 失败会让引擎停在 Error 态，load 前检查状态，
///   是 Error / ModelReady（切换模型）就先 cleanUp 再 load。
///
/// 原生后端（llama.cpp FFI）通过 [LlmGenerationEngine] 注入；app 侧实现负责
/// 把推理放到 Isolate / 原生线程，本宿主保证并发请求在 Dart 侧排队串行。
library;

import 'dart:async';
import 'dart:io' show Platform;
import 'dart:math' as math;

import 'inference_queue.dart';

/// 引擎加载状态（对齐参考 InferenceEngine.State 的可观测子集）。
enum LlmEngineState { unloaded, loading, ready, error }

/// 模型未就绪异常（文件缺失 / 校验失败 / native 拒识）。
class LlmModelNotReadyException implements Exception {
  final String message;

  LlmModelNotReadyException(this.message);

  @override
  String toString() => 'LlmModelNotReadyException: $message';
}

/// 注入的原生推理引擎抽象（app 侧实现，规格 §4 分层硬约束 3）。
abstract class LlmGenerationEngine {
  LlmEngineState get state;

  /// 加载 GGUF 权重；失败抛异常且实现方应把 [state] 置为 error。
  ///
  /// [threads] 为推理线程数（decode / prefill 同值），null 表示用后端默认
  /// （llama.cpp 恒 4，不感知本机大小核拓扑；自动调优后由设置页提供实测值）。
  /// [flashAttn] 启用 CPU flash-attn；部分量化 / KV 类型不支持时表现为
  /// 加载成功但 decode 失败，调用方需按「该组合不可用」处理。
  Future<void> loadModel(
    String modelPath, {
    required int contextSize,
    int? threads,
    bool flashAttn = false,
  });

  /// 逐 token 生成；实现方不得阻塞调用方 Isolate。
  Stream<String> generateStream(String prompt, {required int maxTokens});

  /// 多 prompt 批量生成（一次生成完整输出，不流式）。
  ///
  /// 默认实现逐个串行调 [generateStream]（语义等价，无加速）；llama.cpp
  /// 引擎覆盖为原生多序列并行 decode（共享前缀只 prefill 一次，吞吐
  /// 接近随批大小线性提升）。返回顺序与 [prompts] 一一对应，元素为
  /// 完整生成文本（空输出为空串）。
  Future<List<String>> generateBatch(
    List<String> prompts, {
    required int maxTokens,
  }) async {
    final outputs = <String>[];
    for (final prompt in prompts) {
      final buffer = StringBuffer();
      await for (final token in generateStream(prompt, maxTokens: maxTokens)) {
        buffer.write(token);
      }
      outputs.add(buffer.toString().trim());
    }
    return outputs;
  }

  /// 释放权重 + KV（保留实例，可再次 loadModel）。
  Future<void> cleanUp();
}

/// 引擎宿主。
class LlmEngineHost {
  /// 空闲超时（参考 IDLE_TIMEOUT_MS = 5 * 60 * 1000）。
  static const Duration defaultIdleTimeout = Duration(minutes: 5);

  final LlmGenerationEngine Function() _engineFactory;

  /// 返回 null 表示模型未安装（不可加载）。
  final String? Function() _modelPathProvider;

  /// 返回推理线程数（null = 后端默认）。每次 load 时读取，设置变更即时生效。
  final int? Function()? _threadsProvider;

  /// 返回是否启用 flash-attn（null = 关闭）。每次 load 时读取。
  final bool Function()? _flashAttnProvider;

  /// benchmark 期间临时覆盖加载参数（优先于 provider），结束置回 null。
  int? _threadsOverride;
  bool? _flashOverride;
  int? _contextOverride;

  final int contextSize;
  final Duration idleTimeout;

  /// 单调时钟（毫秒）；测试可注入。
  final int Function() _clockMs;

  /// 日志出口（app 侧接 LPrinter）。
  final void Function(String message)? onLog;

  /// 模型文件大小（MB）提供者；纯 Dart 包不做 IO，由 app 侧注入用于日志。
  final int Function(String modelPath) fileSizeMbProvider;

  final InferenceQueue _queue = InferenceQueue();
  LlmGenerationEngine? _engine;
  bool _loaded = false;
  int _lastUseAt = 0;
  Timer? _idleTimer;
  final StreamController<LlmEngineState> _stateController =
      StreamController<LlmEngineState>.broadcast();

  LlmEngineHost({
    required LlmGenerationEngine Function() engineFactory,
    String? Function() modelPathProvider = _alwaysNull,
    int? Function()? threadsProvider,
    bool Function()? flashAttnProvider,
    // 2048 装不下整页 OCR + 背景信息的 Hy-MT2 prompt（真机实测 -2 超限）；
    // 4096 的 fp16 KV cache 增量约 470MB，主流设备可承受。
    this.contextSize = 4096,
    this.idleTimeout = defaultIdleTimeout,
    int Function()? clockMs,
    this.onLog,
    int Function(String modelPath)? fileSizeMbProvider,
  }) : _engineFactory = engineFactory,
       _modelPathProvider = modelPathProvider,
       _threadsProvider = threadsProvider,
       _flashAttnProvider = flashAttnProvider,
       _clockMs = clockMs ?? (() => DateTime.now().millisecondsSinceEpoch),
       fileSizeMbProvider = fileSizeMbProvider ?? _zeroMb;

  static String? _alwaysNull() => null;

  static int _zeroMb(String path) => 0;

  /// 引擎状态流（加载 / 就绪 / 错误 / 卸载）。
  Stream<LlmEngineState> get state => _stateController.stream;

  /// 当前是否已有权重驻留。
  bool get isLoaded => _loaded;

  void _log(String message) => onLog?.call(message);

  void _emit(LlmEngineState s) {
    if (!_stateController.isClosed) _stateController.add(s);
  }

  /// 预热：短句 + maxTokens=1（参考 PREWARM_SOURCE / PREWARM_PREDICT_LENGTH）。
  Future<void> prewarm({String source = 'こんにちは', int maxTokens = 1}) async {
    final startedAt = _clockMs();
    await _queue.withSession(() async {
      final engine = await _ensureLoaded();
      await engine.generateStream(source, maxTokens: maxTokens).drain<void>();
      touchInternal();
      _log('perf> llm prewarm completed ms=${_clockMs() - startedAt}');
    });
  }

  /// 非流式生成：聚合全部 token 后返回；空输出返回 null。
  Future<String?> generate(String prompt, {required int maxTokens}) {
    return _queue.withSession(() async {
      final engine = await _ensureLoaded();
      final buffer = StringBuffer();
      await for (final token in engine.generateStream(
        prompt,
        maxTokens: maxTokens,
      )) {
        buffer.write(token);
      }
      touchInternal();
      final text = buffer.toString().trim();
      return text.isEmpty ? null : text;
    });
  }

  /// 多 prompt 批量生成（引擎支持时为原生多序列并行 decode）。
  ///
  /// 经推理队列串行进入；批内失败向上抛（调用方自行回退逐段）。
  Future<List<String>> generateBatch(
    List<String> prompts, {
    required int maxTokens,
  }) {
    return _queue.withSession(() async {
      final engine = await _ensureLoaded();
      final startedAt = _clockMs();
      final outputs = await engine.generateBatch(prompts, maxTokens: maxTokens);
      touchInternal();
      _log('perf> llm native batch generate count=${prompts.length} '
          'maxTokens=$maxTokens totalMs=${_clockMs() - startedAt}');
      return outputs;
    });
  }

  /// 流式生成：逐 token 发射（推理经队列串行执行）。
  Stream<String> generateStream(String prompt, {required int maxTokens}) {
    late StreamController<String> controller;
    controller = StreamController<String>(
      onListen: () async {
        try {
          await _queue.withSession(() async {
            final engine = await _ensureLoaded();
            await for (final token in engine.generateStream(
              prompt,
              maxTokens: maxTokens,
            )) {
              if (controller.isClosed) return;
              controller.add(token);
            }
            touchInternal();
          });
          await controller.close();
        } catch (e) {
          if (!controller.isClosed) {
            controller.addError(e);
            await controller.close();
          }
        }
      },
    );
    return controller.stream;
  }

  /// 每次成功翻译后调用：重置空闲计时（参考 touch）。
  Future<void> touch() async {
    touchInternal();
  }

  void touchInternal() {
    _lastUseAt = _clockMs();
    scheduleIdleUnload();
  }

  /// 调度空闲卸载；到点校验真实空闲时长，避免 delay 期间有 touch 误触发。
  void scheduleIdleUnload() {
    _idleTimer?.cancel();
    _idleTimer = Timer(idleTimeout, () {
      final idle = _clockMs() - _lastUseAt;
      if (idle >= idleTimeout.inMilliseconds) {
        _log('perf> llm idle ${idle}ms, unloading');
        unload();
      }
    });
  }

  /// 确保模型已加载（对齐参考 ensureLoaded：fast path / 自愈 / 切换）。
  ///
  /// 注意：全部公开入口（generate / generateStream / prewarm / unload）都经
  /// [InferenceQueue] 串行进入，这里直接执行；若再嵌套排队会与外层 session
  /// 互相等待而死锁（参考实现的 initLock 在 lifecycle gate 之内，同理）。
  Future<LlmGenerationEngine> _ensureLoaded() async {
    if (_loaded && _engine != null && _engine!.state != LlmEngineState.error) {
      touchInternal();
      return _engine!;
    }

    final modelPath = _modelPathProvider();
    if (modelPath == null || modelPath.isEmpty) {
      throw LlmModelNotReadyException('端侧模型未安装，请先在设置中下载模型');
    }

    var engine = _engine;
    if (engine == null) {
      engine = _engineFactory();
      _engine = engine;
    }
    // 状态自愈：Error 或已有驻留权重（ModelReady）都需要 cleanUp 再 load。
    if (engine.state == LlmEngineState.error ||
        (engine.state == LlmEngineState.ready && _loaded)) {
      _log('perf> llm reset before load state=${engine.state.name}');
      try {
        await engine.cleanUp();
      } catch (e) {
        _log('perf> llm cleanUp before load failed: $e');
      }
      _loaded = false;
    }

    _emit(LlmEngineState.loading);
    final startedAt = _clockMs();
    final effectiveContext = _contextOverride ?? contextSize;
    try {
      await engine.loadModel(
        modelPath,
        contextSize: effectiveContext,
        threads: _threadsOverride ?? _threadsProvider?.call(),
        flashAttn: _flashOverride ?? _flashAttnProvider?.call() ?? false,
      );
    } catch (e) {
      _emit(LlmEngineState.error);
      throw LlmModelNotReadyException('模型加载失败（可能损坏、量化格式不支持或内存不足）：$e');
    }
    final loadMs = _clockMs() - startedAt;
    final fileMb = fileSizeMbProvider(modelPath);
    _loaded = true;
    touchInternal();
    _log('perf> llm load kind=hy_mt2 loadMs=$loadMs fileMb=$fileMb '
        'ctx=$effectiveContext threads=${_threadsOverride ?? _threadsProvider?.call()} '
        'fa=${_flashOverride ?? _flashAttnProvider?.call() ?? false}');
    _emit(LlmEngineState.ready);
    return engine;
  }

  /// 主动卸载模型权重；engine 实例保留以便下次 load（参考 unload）。
  Future<void> unload() async {
    await _queue.withSession(() async {
      final engine = _engine;
      if (engine == null || !_loaded) return;
      try {
        await engine.cleanUp();
      } finally {
        _loaded = false;
        _idleTimer?.cancel();
        _idleTimer = null;
        _log('perf> llm unloaded');
        _emit(LlmEngineState.unloaded);
      }
    });
  }

  /// 彻底关闭宿主（进程退出 / 用户关闭功能时）。
  Future<void> shutdown() async {
    await unload();
    await _stateController.close();
  }

  /// 自动线程调优：对每个候选线程数重新加载模型并跑一次短生成实测速度。
  ///
  /// 经推理队列独占执行，期间不要并发翻译（UI 层防重入）。每次候选都会
  /// 强制重新 load（权重 mmap 有系统页缓存，第二次起加载明显变快）；
  /// 结束后释放权重，下次翻译按用户设置重新加载。
  /// 任一候选加载 / 生成失败即终止并抛出（其余候选大概率同样失败）。
  Future<ThreadBenchmarkReport> benchmarkThreads({
    required List<int> candidates,
    required String prompt,
    int maxTokens = 20,
    void Function(int threads, int index, int total)? onCandidateStart,
    void Function(int threads, ThreadBenchmarkPoint point)? onCandidateDone,
  }) async {
    return await _queue.withSession(() async {
      final points = <ThreadBenchmarkPoint>[];
      LlmGenerationEngine? eng;
      try {
        for (var i = 0; i < candidates.length; i++) {
          final threads = candidates[i];
          onCandidateStart?.call(threads, i, candidates.length);
          _threadsOverride = threads;
          // 强制下一次 _ensureLoaded 按候选线程数重新加载。
          _loaded = false;
          eng = await _ensureLoaded();
          final startedAt = _clockMs();
          var tokens = 0;
          await for (final _ in eng.generateStream(
            prompt,
            maxTokens: maxTokens,
          )) {
            tokens++;
          }
          final point = ThreadBenchmarkPoint(
            threads: threads,
            tokens: tokens,
            elapsedMs: _clockMs() - startedAt,
          );
          points.add(point);
          onCandidateDone?.call(threads, point);
          _log('perf> llm bench threads=$threads tokens=$tokens '
              'ms=${point.elapsedMs}');
        }
      } finally {
        _threadsOverride = null;
        _loaded = false;
        _idleTimer?.cancel();
        // benchmark 是重负载操作，结束后释放权重，下次翻译再加载。
        if (eng != null) {
          try {
            await eng.cleanUp();
          } catch (e) {
            _log('perf> llm bench cleanup failed: $e');
          }
        }
      }
      // 同速取线程数少者（省电少发热），留 2% 容差吸收测量抖动。
      ThreadBenchmarkPoint? best;
      for (final p in points) {
        if (best == null || p.tokensPerSec > best.tokensPerSec * 1.02) {
          best = p;
        }
      }
      _log('perf> llm bench done candidates=${points.length} '
          'best=${best?.threads}');
      return ThreadBenchmarkReport(points: points, bestThreads: best?.threads);
    });
  }

  /// 实测单个配置（性能实验台）：按该配置重载权重 → 按批宽跑完整
  /// 工作负载 → 释放权重，返回该点位耗时。
  ///
  /// 与 [benchmarkThreads] 的区别：这里的指标是**端到端段落吞吐**
  /// （一段 = 一次翻译请求），因为线程数只影响单 token 速度，而批宽
  /// 影响的是并行度——只有按「同样一份活干完用多久」量，两者才可比。
  ///
  /// 失败（该组合不被支持，例如 flash-attn 在本地量化上不可用）不抛出，
  /// 而是返回带 [LlmBenchPoint.error] 的点位，让扫描继续跑完其余组合。
  Future<LlmBenchPoint> measureTuning({
    required LlmTuning tuning,
    required List<String> workload,
    int maxTokens = 24,
  }) async {
    return await _queue.withSession(() async {
      LlmGenerationEngine? eng;
      try {
        _threadsOverride = tuning.threads;
        _flashOverride = tuning.flashAttn;
        _contextOverride = tuning.contextSize;
        _loaded = false;
        final loadStart = _clockMs();
        eng = await _ensureLoaded();
        final loadMs = _clockMs() - loadStart;

        final width = tuning.batchSize < 1 ? 1 : tuning.batchSize;
        final genStart = _clockMs();
        var chars = 0;
        var segments = 0;
        for (var i = 0; i < workload.length; i += width) {
          final chunk = workload.sublist(
            i,
            math.min(i + width, workload.length),
          );
          final outputs = await eng.generateBatch(
            chunk,
            maxTokens: maxTokens,
          );
          for (final out in outputs) {
            chars += out.length;
          }
          segments += chunk.length;
        }
        final genMs = _clockMs() - genStart;
        final point = LlmBenchPoint(
          tuning: tuning,
          segments: segments,
          chars: chars,
          loadMs: loadMs,
          genMs: genMs,
        );
        _log('perf> bench point ${tuning.label} loadMs=$loadMs genMs=$genMs '
            'segs=$segments chars=$chars');
        return point;
      } catch (e) {
        _log('perf> bench point ${tuning.label} failed: $e');
        return LlmBenchPoint.failed(tuning: tuning, error: '$e');
      } finally {
        _threadsOverride = null;
        _flashOverride = null;
        _contextOverride = null;
        _loaded = false;
        _idleTimer?.cancel();
        if (eng != null) {
          try {
            await eng.cleanUp();
          } catch (e) {
            _log('perf> llm bench cleanup failed: $e');
          }
        }
      }
    });
  }
}

/// 单个实测配置（性能实验台的输入）。
///
/// 四个维度都可在运行时改变，因此「哪种方式最快」的答案因机而异，
/// 只能在本机实测得出。
class LlmTuning {
  /// 推理线程数；null = 后端默认（llama.cpp 恒 4）。
  final int? threads;

  /// 是否启用 CPU flash-attn。
  final bool flashAttn;

  /// 上下文容量（KV cache 上限）；null = 宿主默认（4096）。
  final int? contextSize;

  /// 多序列批宽：一次 generateBatch 推进几段；1 = 逐段串行。
  final int batchSize;

  const LlmTuning({
    this.threads,
    this.flashAttn = false,
    this.contextSize,
    this.batchSize = 1,
  });

  LlmTuning copyWith({
    int? threads,
    bool? flashAttn,
    int? contextSize,
    int? batchSize,
  }) => LlmTuning(
    threads: threads ?? this.threads,
    flashAttn: flashAttn ?? this.flashAttn,
    contextSize: contextSize ?? this.contextSize,
    batchSize: batchSize ?? this.batchSize,
  );

  /// UI 展示用标签（短，放得进表格一行）。
  String get label =>
      '线程${threads ?? '默认'} · 批$batchSize · '
      'ctx${contextSize ?? '默认'} · FA${flashAttn ? '开' : '关'}';

  @override
  String toString() => 'LlmTuning($label)';
}

/// 单个配置的实测结果。
class LlmBenchPoint {
  final LlmTuning tuning;

  /// 实际完成的段数（一段 = 一次翻译请求）。
  final int segments;

  /// 生成文本总字符数（用于发现「跑满上限」的异常配置）。
  final int chars;

  /// 重载权重耗时（mmap + 上下文分配），单独记便于识别内存吃紧的配置。
  final int loadMs;

  /// 生成耗时（不含加载）。
  final int genMs;

  /// 非空 = 该组合不可用（加载或推理失败）。
  final String? error;

  const LlmBenchPoint({
    required this.tuning,
    required this.segments,
    required this.chars,
    required this.loadMs,
    required this.genMs,
    this.error,
  });

  const LlmBenchPoint.failed({required this.tuning, required this.error})
    : segments = 0,
      chars = 0,
      loadMs = 0,
      genMs = 0;

  bool get isUsable => error == null && genMs > 0 && segments > 0;

  /// 段落吞吐（段/分钟）：实验台排序用的主指标。
  double get segmentsPerMin =>
      genMs > 0 ? segments * 60000 / genMs : 0;

  /// 等效 token 速度的粗略替代（字/秒）：译文长度不一致时只作参考。
  double get charsPerSec => genMs > 0 ? chars * 1000 / genMs : 0;

  /// 单段平均耗时（毫秒）。
  double get msPerSegment => segments > 0 ? genMs / segments : 0;
}

/// 自动调优的单个实测点位。
class ThreadBenchmarkPoint {
  final int threads;

  /// 实际收到的 token 流事件数（每事件 ≈ 1 个 token，足以量化速度）。
  final int tokens;
  final int elapsedMs;

  ThreadBenchmarkPoint({
    required this.threads,
    required this.tokens,
    required this.elapsedMs,
  });

  double get tokensPerSec => elapsedMs > 0 ? tokens * 1000 / elapsedMs : 0;
}

/// 自动线程调优结果。
class ThreadBenchmarkReport {
  final List<ThreadBenchmarkPoint> points;

  /// 实测最快的线程数；全部点位失败时为 null（正常不会发生——失败直接抛出）。
  final int? bestThreads;

  const ThreadBenchmarkReport({required this.points, required this.bestThreads});
}

/// 自动调优的默认候选：1..min(核数, 6)。
///
/// 上限 6：真机实测（Redmi 24117RK2CC，1+3+4 核）7/8 线程灾难性变慢
/// （20 token 花 186s/230s，比最优慢约 70 倍，两轮稳定复现）——线程数
/// 超过物理大核数后小核加入 barrier 同步拖垮全组；参考实现
/// overlay-translator 的 llama_thread_policy.cpp 同样把推理线程封顶 6。
/// 核数不足的设备按实际核数截断。
List<int> defaultThreadCandidates() {
  final max = Platform.numberOfProcessors.clamp(1, 6);
  return [for (var i = 1; i <= max; i++) i];
}
