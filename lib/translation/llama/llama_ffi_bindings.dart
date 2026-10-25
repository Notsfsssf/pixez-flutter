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

/// `libllamashim.so` 的 FFI 绑定（5 个布局稳定的 C 函数，见
/// android/app/src/main/cpp/llama_shim.cpp）。
///
/// 不直接绑定 llama.h：其巨型 struct（llama_context_params 等）字段布局
/// 随上游版本变动，Dart 侧手写复制极易错位崩溃；C++ shim 用原生头文件
/// 承担全部复杂度。
library;

import 'dart:convert' show utf8;
import 'dart:ffi';

import 'package:ffi/ffi.dart';

typedef _LoadNative = Int32 Function(
  Pointer<Utf8>,
  Int32,
  Float,
  Float,
  Int32,
  Int32,
);
typedef _LoadDart = int Function(
  Pointer<Utf8>,
  int,
  double,
  double,
  int,
  int,
);
typedef _FreeNative = Void Function();
typedef _FreeDart = void Function();
typedef _StartNative = Int32 Function(Pointer<Utf8>);
typedef _StartDart = int Function(Pointer<Utf8>);
typedef _NextNative = Int32 Function(Pointer<Uint8>, Int32);
typedef _NextDart = int Function(Pointer<Uint8>, int);
typedef _GenerateMultiNative = Int32 Function(
  Pointer<Pointer<Utf8>>,
  Int32,
  Int32,
  Pointer<Uint8>,
  Int32,
);
typedef _GenerateMultiDart = int Function(
  Pointer<Pointer<Utf8>>,
  int,
  int,
  Pointer<Uint8>,
  int,
);

/// 多序列批量输出的分隔符（ASCII Record Separator，译文不会出现）。
const String kMultiOutputSeparator = '\x1E';

/// [LlamaFfiBindings.generateMulti] 失败，[code] 为 native 错误码
/// （-2 序列数超范围 / -3 解码失败 / -4 KV 容量不足 / -5 输出缓冲不足…）。
class LlamaMultiGenerateException implements Exception {
  final int code;
  const LlamaMultiGenerateException(this.code);

  @override
  String toString() => 'LlamaMultiGenerateException: $code';
}

class LlamaFfiBindings {
  final DynamicLibrary lib;

  LlamaFfiBindings() : lib = DynamicLibrary.open('libllamashim.so');

  late final _LoadDart _load = lib
      .lookupFunction<_LoadNative, _LoadDart>('llama_shim_load');
  late final _FreeDart _free = lib
      .lookupFunction<_FreeNative, _FreeDart>('llama_shim_free');
  late final _StartDart _start = lib
      .lookupFunction<_StartNative, _StartDart>('llama_shim_start');
  late final _NextDart _next = lib
      .lookupFunction<_NextNative, _NextDart>('llama_shim_next');
  late final _GenerateMultiDart _generateMulti = lib
      .lookupFunction<_GenerateMultiNative, _GenerateMultiDart>(
        'llama_shim_generate_multi',
      );

  /// 1 成功；0 失败（文件损坏 / 量化不支持 / 内存不足）。
  /// [threads] <= 0 用 llama.cpp 默认线程数（4）。
  /// [flashAttn] true = 启用 CPU flash-attn（部分量化/KV 类型不支持，
  /// 表现为后续 decode 失败而非 load 失败，调用方需容错）。
  int load(
    String path,
    int contextSize,
    double temp,
    double topP,
    int threads, {
    bool flashAttn = false,
  }) {
    final p = path.toNativeUtf8();
    try {
      return _load(p, contextSize, temp, topP, threads, flashAttn ? 1 : 0);
    } finally {
      malloc.free(p);
    }
  }

  void freeModel() => _free();

  /// 0 成功；-1 未加载；-2 提示词超上下文；-3 解码失败。
  int start(String prompt) {
    final p = prompt.toNativeUtf8();
    try {
      return _start(p);
    } finally {
      malloc.free(p);
    }
  }

  /// 把下一个 token 的 UTF-8 字节写入 [buf]；返回字节数；0 = 生成结束；
  /// -1 未加载；-3 解码失败；-4 缓冲区不足。
  int next(Pointer<Uint8> buf, int bufLen) => _next(buf, bufLen);

  /// 多序列批量生成（一次同步调用，native 侧共享前缀 + 并行 decode）。
  /// 返回按输入顺序的输出列表（可能含空串）；失败抛 [Exception]（携带
  /// native 错误码）。输出缓冲 [outBuf] 尺寸不足时 native 返回 -5。
  List<String> generateMulti(
    List<String> prompts,
    int maxTokens,
    Pointer<Uint8> outBuf,
    int outBufLen,
  ) {
    final arr = malloc<Pointer<Utf8>>(prompts.length);
    final owned = <Pointer<Utf8>>[];
    try {
      for (var i = 0; i < prompts.length; i++) {
        final p = prompts[i].toNativeUtf8();
        owned.add(p);
        arr[i] = p;
      }
      final rc = _generateMulti(arr, prompts.length, maxTokens, outBuf, outBufLen);
      if (rc < 0) {
        throw LlamaMultiGenerateException(rc);
      }
      // native 已写入 rc 字节（不含终止符），按 \x1E 切分各序列输出。
      // 输出是 UTF-8 字节流（中文多字节），必须走 utf8 解码而非逐字节
      // fromCharCodes（后者会把多字节序列拆成乱码）。
      final text = utf8.decode(outBuf.asTypedList(rc), allowMalformed: true);
      return text.split(kMultiOutputSeparator);
    } finally {
      for (final p in owned) {
        malloc.free(p);
      }
      malloc.free(arr);
    }
  }
}
