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

/// 测试用 Fake 引擎（共享）。
library;

import 'dart:async';

import 'package:translator/src/engine/llm_engine_host.dart';

/// 可脚本化的假推理引擎：按注册顺序弹出响应，记录全部调用。
class FakeEngine implements LlmGenerationEngine {
  @override
  LlmEngineState state = LlmEngineState.unloaded;

  int loadCount = 0;
  int cleanUpCount = 0;
  final List<String> prompts = [];
  final List<int> maxTokensSeen = [];

  /// 每次 loadModel 收到的线程数（null = 后端默认），benchmark 测试断言用。
  final List<int?> threadsSeen = [];

  /// 每次调用的响应（按顺序弹出）；响应为 null 时抛错（未预期调用）。
  final List<String?> script = [];

  /// [script] 为空时的新增响应（连续可复用）。
  String? defaultResponse;

  /// 非空时 [generateBatch] 抛出该异常（测调用方回退逐段串行）。
  Object? batchFailure;

  /// 每次 load 时的 flash-attn 取值（断言配置覆盖生效）。
  final List<bool> flashAttnSeen = [];

  /// 每次 generateBatch 收到的 prompt 组（断言分组用）。
  final List<List<String>> batchPromptsSeen = [];

  void enqueue(String response) => script.add(response);

  @override
  Future<void> loadModel(
    String modelPath, {
    required int contextSize,
    int? threads,
    bool flashAttn = false,
  }) async {
    loadCount++;
    threadsSeen.add(threads);
    // 性能实验台会按维度切换 FA，记录以便断言覆盖确实生效。
    flashAttnSeen.add(flashAttn);
    state = LlmEngineState.ready;
  }

  @override
  Stream<String> generateStream(
    String prompt, {
    required int maxTokens,
  }) async* {
    prompts.add(prompt);
    maxTokensSeen.add(maxTokens);
    final response = script.isNotEmpty ? script.removeAt(0) : defaultResponse;
    if (response == null) {
      throw StateError(
        'FakeEngine: unexpected prompt call #${prompts.length}: $prompt',
      );
    }
    for (final token in response.split('')) {
      yield token;
    }
  }

  @override
  Future<List<String>> generateBatch(
    List<String> prompts, {
    required int maxTokens,
  }) async {
    if (batchFailure != null) {
      throw batchFailure!;
    }
    batchPromptsSeen.add(prompts);
    return [
      for (final _ in prompts)
        (script.isNotEmpty ? script.removeAt(0) : defaultResponse) ?? '',
    ];
  }

  @override
  Future<void> cleanUp() async {
    cleanUpCount++;
    state = LlmEngineState.unloaded;
  }
}
