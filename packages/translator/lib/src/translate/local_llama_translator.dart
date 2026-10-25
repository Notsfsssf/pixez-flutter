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

/// 端侧 Hy-MT2 翻译器（移植自参考 LocalLlamaTranslator.kt + HyMt2Translator.kt
/// 的策略绑定面）。
///
/// 语义对齐：
/// - `validateAndRecoverOutputLocked` 三段式（Accepted / Retryable / Rejected）；
/// - 拒绝后用去背景 prompt 重试一次（`outputRecoveryPrompt`），仍拒绝置空；
/// - `Retryable` 直接用 fallbackText（不缓存）；
/// - 缓存命中也要重跑输出校验（脏缓存剔除）；
/// - 批量按段落顺序分小组（llama_shim 原生多序列并行 decode，批内共享
///   公共指令前缀），共享同一次模型加载；命中缓存直接回填不推理；每批
///   完成立即 onUpdate；单段失败置 null 不中断后续；相同 cacheKey 的源
///   合并为一次推理；批量不可用（引擎不支持 / KV 超限）自动回退逐段
///   串行；每段完成立即 onUpdate。
library;

import '../engine/llm_engine_host.dart';
import '../model/translate_request.dart';
import 'cache_key.dart';
import 'hy_mt2_output_gate.dart';
import 'hy_mt2_profile.dart';
import 'hy_mt2_prompt_policy.dart';
import 'translation_cache.dart';
import 'translator.dart';

export 'hy_mt2_output_gate.dart'
    show GeneratedAccepted, GeneratedRejected, GeneratedRetryable;

/// 校验 + 恢复后的最终输出。
class _ResolvedOutput {
  final String? text;
  final bool cacheable;

  const _ResolvedOutput(this.text, this.cacheable);

  static const failed = _ResolvedOutput(null, false);
}

/// 端侧 llama.cpp（Hy-MT2）翻译器。
class LocalLlamaTranslator implements Translator {
  /// 批量推理的分组大小（llama_shim 多序列上限 8）。
  ///
  /// 4 折中「首屏等待」与「总吞吐」：批内并行 decode 吞吐接近线性提升，
  /// 但首批译文要等整批完成才上屏。4096 上下文预算下 4 段（每段
  /// prompt + maxNewTokens）恒安全，更大的批在长 prompt 时会触发
  /// KV 超限回退。
  ///
  /// 设置页「性能实验台」实测后由 [nativeBatchSizeProvider] 覆盖；
  /// 无 provider 时用这个默认值。
  static const int _kNativeBatchSize = 4;

  final LlmEngineHost host;
  final TranslationCache cache;

  /// 日志出口（app 侧接 LPrinter）。
  final void Function(String message)? onLog;

  /// 模型是否已安装（app 侧注入；testConnection 用）。
  final bool Function() modelInstalled;

  /// 批量分组大小 provider（null = 用 [_kNativeBatchSize]）。
  /// 每次批量翻译读取，设置变更即时生效，无需重建翻译器。
  final int Function()? nativeBatchSizeProvider;

  LocalLlamaTranslator({
    required this.host,
    TranslationCache? cache,
    this.onLog,
    this.modelInstalled = _defaultModelInstalled,
    this.nativeBatchSizeProvider,
  }) : cache = cache ?? TranslationCache();

  /// 生效的批量分组大小：钳在 llama_shim 的 8 序列上限内。
  int get _batchSize {
    final v = nativeBatchSizeProvider?.call() ?? _kNativeBatchSize;
    return v < 1 ? 1 : (v > 8 ? 8 : v);
  }

  static bool _defaultModelInstalled() => true;

  void _log(String message) => onLog?.call(message);

  // ---- HyMt2Translator 策略绑定 ----

  /// Hy-MT2 无 system prompt；输出全部缓冲至校验通过。
  static const bool bufferGeneratedOutputUntilValidated = true;

  String buildUserPrompt(String source, TranslateRequest request) =>
      HyMt2PromptPolicy.build(source, request.targetLang, request.context);

  String? outputRecoveryPrompt(
    String source,
    String rejectedUserPrompt,
    TranslateRequest request,
  ) => HyMt2OutputGate.recoveryPrompt(source, rejectedUserPrompt, request);

  /// 输出校验（生成边界 + 九类渗透检测）。
  GeneratedOutputValidation outputValidation(
    String source,
    String output,
    String userPrompt,
    TranslateRequest request,
  ) => HyMt2OutputGate.validate(source, output, userPrompt);

  /// 生成结果的引擎侧清理：剥单个无害列表前缀（背景模式）。
  String normalizeGeneratedOutput(
    String source,
    String output,
    String userPrompt,
    TranslateRequest request,
  ) => HyMt2OutputGate.normalize(source, output, userPrompt);

  String _cacheKey(
    String source,
    TranslateRequest request,
    String userPrompt,
  ) => LocalLlamaTranslationCacheKey.build(
    cache: cache,
    source: source,
    model: HyMt2Profile.modelName,
    sourceLang: request.sourceLang,
    targetLang: request.targetLang,
    maxNewTokens: request.maxNewTokens,
    systemPrompt: request.systemPrompt,
    userPrompt: userPrompt,
  );

  // ---- Translator 接口 ----

  @override
  Future<String?> translate(String source, TranslateRequest request) async {
    if (source.trim().isEmpty) return null;
    final userPrompt = buildUserPrompt(source, request);
    final key = _cacheKey(source, request, userPrompt);

    final cached = validatedCachedOutput(source, userPrompt, key, request);
    if (cached != null) {
      _log(
        'perf> llm cache hit kind=hy_mt2 mode=full inputChars=${source.length}',
      );
      return cached;
    }

    final generated = await host.generate(
      userPrompt,
      maxTokens: request.maxNewTokens,
    );
    final resolved = await validateAndRecoverOutput(
      source: source,
      userPrompt: userPrompt,
      generated: generated,
      request: request,
    );
    if (resolved.text != null && resolved.cacheable) {
      cache.put(key, resolved.text!, request);
    }
    return resolved.text;
  }

  @override
  Stream<String> translateStream(
    String source,
    TranslateRequest request,
  ) async* {
    if (source.trim().isEmpty) return;
    final userPrompt = buildUserPrompt(source, request);
    final key = _cacheKey(source, request, userPrompt);

    final cached = validatedCachedOutput(source, userPrompt, key, request);
    if (cached != null) {
      yield cached;
      return;
    }

    // bufferGeneratedOutputUntilValidated = true：token 全部缓冲，
    // 生成 + 校验通过后才一次性上屏（避免半截译文 / 渗透内容闪现）。
    final buffer = StringBuffer();
    await for (final token in host.generateStream(
      userPrompt,
      maxTokens: request.maxNewTokens,
    )) {
      buffer.write(token);
    }
    final generated = buffer.toString().trim();
    final resolved = await validateAndRecoverOutput(
      source: source,
      userPrompt: userPrompt,
      generated: generated.isEmpty ? null : generated,
      request: request,
    );
    if (resolved.text != null) yield resolved.text!;
    if (resolved.text != null && resolved.cacheable) {
      cache.put(key, resolved.text!, request);
    }
  }

  @override
  Future<List<String?>> translateBatch(
    List<String> sources,
    TranslateRequest request,
  ) => translateBatchIncremental(sources, request, (_, __) {});

  @override
  Future<List<String?>> translateBatchIncremental(
    List<String> sources,
    TranslateRequest request,
    void Function(int index, String? text) onUpdate,
  ) async {
    if (sources.isEmpty) return const [];

    final results = List<String?>.filled(sources.length, null);
    final emitted = List<bool>.filled(sources.length, false);
    void publish(int index, String? text) {
      if (index < 0 || index >= results.length || emitted[index]) return;
      emitted[index] = true;
      onUpdate(index, text);
    }

    // 相同 cacheKey 的源合并为一次推理（对齐参考 BatchPending.resultIndexes）。
    final pendingByKey = <String, _BatchPending>{};
    var cacheHits = 0;
    for (var index = 0; index < sources.length; index++) {
      final source = sources[index];
      if (source.trim().isEmpty) {
        publish(index, null);
        continue;
      }
      final individualPrompt = buildUserPrompt(source, request);
      final key = _cacheKey(source, request, individualPrompt);
      final cached = validatedCachedOutput(
        source,
        individualPrompt,
        key,
        request,
      );
      if (cached != null) {
        results[index] = cached;
        cacheHits++;
        publish(index, cached);
      } else {
        pendingByKey
            .putIfAbsent(
              key,
              () => _BatchPending(source, individualPrompt, key),
            )
            .resultIndexes
            .add(index);
      }
    }
    if (pendingByKey.isEmpty) {
      _log('perf> llm native batch plan unique=0 cacheHits=$cacheHits');
      return results;
    }

    // 分组大小本方法内固定（设置若在推理中途变更，不至于同一轮里跳变）。
    final batchWidth = _batchSize;
    _log(
      'perf> llm native batch plan kind=hy_mt2 segments=${sources.length} '
      'unique=${pendingByKey.length} cacheHits=$cacheHits '
      'mode=native_batch B=$batchWidth',
    );

    // 分小组批量推理（llama_shim 多序列并行 decode）：一批完成即发布
    // 该批全部段落（保持渐进上屏）。批内失败（引擎不支持 / KV 超限 /
    // 输出缓冲不足）回退该批逐段串行，正确性不缩水。
    final items = pendingByKey.values.toList();
    final recoveries = <_BatchRecovery>[];
    // 端侧图片翻译的段落都很短：512 上限只为兜底，一旦结束符判不出来就会
    // 每段跑满上限（真机 4 段 × 512 token ≈ 141 秒）。这里收紧到 256，
    // 仍未触发的异常段由输出校验判 reject 后走恢复流程。
    final batchMaxTokens =
        request.maxNewTokens > 256 ? 256 : request.maxNewTokens;
    final totalBatches = (items.length + batchWidth - 1) ~/ batchWidth;
    for (var i = 0; i < items.length; i += batchWidth) {
      final group = items.skip(i).take(batchWidth).toList();
      final batchNo = i ~/ batchWidth + 1;
      final startedAt = DateTime.now();
      _log(
        'perf> llm batch start $batchNo/$totalBatches '
        'count=${group.length} maxTokens=$batchMaxTokens',
      );
      List<String>? outputs;
      try {
        outputs = await host.generateBatch(
          group.map((e) => e.individualPrompt).toList(),
          maxTokens: batchMaxTokens,
        );
      } catch (e) {
        _log(
          'perf> llm native batch failed fallback=serial '
          'batch=${group.length} error=$e',
        );
      }
      if (outputs != null && outputs.length == group.length) {
        // 输出字符数用于判断结束符是否生效：正常一段几十字符，跑满上限
        // 会出现数百字符的重复文本。
        final chars = outputs.map((e) => e.trim().length).toList();
        _log(
          'perf> llm batch done $batchNo/$totalBatches '
          'ms=${DateTime.now().difference(startedAt).inMilliseconds} '
          'chars=$chars',
        );
        for (var j = 0; j < group.length; j++) {
          final text = outputs[j].trim();
          _acceptBatchResultOrQueueRecovery(
            item: group[j],
            translated: text.isEmpty ? null : text,
            results: results,
            request: request,
            publish: publish,
            recoveries: recoveries,
          );
        }
      } else {
        // 回退逐段串行：每段打印耗时，便于对比批量收益。
        for (final item in group) {
          final serialStart = DateTime.now();
          final translated = await host.generate(
            item.individualPrompt,
            maxTokens: batchMaxTokens,
          );
          _log(
            'perf> llm serial done ms='
            '${DateTime.now().difference(serialStart).inMilliseconds} '
            'chars=${translated?.trim().length ?? 0}',
          );
          _acceptBatchResultOrQueueRecovery(
            item: item,
            translated: translated,
            results: results,
            request: request,
            publish: publish,
            recoveries: recoveries,
          );
        }
      }
    }

    // 输出策略恢复：拒绝项用去背景 prompt 重试一次。
    for (final recovery in recoveries) {
      final translated = await _recoverRejectedOutput(
        source: recovery.item.source,
        rejectedUserPrompt: recovery.item.individualPrompt,
        rejection: recovery.rejection,
        request: request,
      );
      _applyBatchResult(
        item: recovery.item,
        translated: translated.text,
        results: results,
        request: request,
        publish: publish,
        cacheable: translated.cacheable,
      );
    }
    await host.touch();
    return results;
  }

  @override
  Future<TestResult> testConnection(TranslateRequest request) async {
    try {
      if (!modelInstalled()) {
        return const TestResult(success: false, message: '模型未安装');
      }
      await host.prewarm(maxTokens: 1);
      return const TestResult(
        success: true,
        message: '模型已加载: ${HyMt2Profile.modelFile}',
      );
    } catch (e) {
      return TestResult(success: false, message: '$e');
    }
  }

  @override
  Future<void> dispose() => host.shutdown();

  // ---- 内部实现（对齐参考私有方法） ----

  /// 缓存命中也要重跑输出校验；校验失败剔除脏缓存（规格 §6.5）。
  String? validatedCachedOutput(
    String source,
    String userPrompt,
    String cacheKey,
    TranslateRequest request,
  ) {
    final cached = cache.get(cacheKey, request);
    if (cached == null) return null;
    final normalizedCached = normalizeGeneratedOutput(
      source,
      cached,
      userPrompt,
      request,
    );
    final validation = outputValidation(
      source,
      normalizedCached,
      userPrompt,
      request,
    );
    switch (validation) {
      case GeneratedAccepted():
        return normalizedCached;
      case GeneratedRetryable():
      case GeneratedRejected():
        cache.remove(cacheKey);
        _logOutputPolicyRejection(
          'cache',
          source,
          normalizedCached,
          validation,
        );
        return null;
    }
  }

  /// 三段式：Accepted / Retryable（fallbackText 不缓存）/ Rejected（重试一次，
  /// 仍拒绝置空）。
  Future<_ResolvedOutput> validateAndRecoverOutput({
    required String source,
    required String userPrompt,
    required String? generated,
    required TranslateRequest request,
  }) async {
    final normalizedGenerated = generated == null
        ? null
        : normalizeGeneratedOutput(source, generated, userPrompt, request);
    if (normalizedGenerated == null) {
      if (!request.retryFailedTranslation) return _ResolvedOutput.failed;
      return _recoverRejectedOutput(
        source: source,
        rejectedUserPrompt: userPrompt,
        rejection: const GeneratedRejected('EMPTY'),
        request: request,
      );
    }
    final validation = outputValidation(
      source,
      normalizedGenerated,
      userPrompt,
      request,
    );
    switch (validation) {
      case GeneratedAccepted():
        return _ResolvedOutput(normalizedGenerated, true);
      case GeneratedRetryable(:final reason):
        _logOutputPolicyRejection(
          'initial-retryable',
          source,
          normalizedGenerated,
          validation,
        );
        if (request.retryFailedTranslation) {
          return _recoverRejectedOutput(
            source: source,
            rejectedUserPrompt: userPrompt,
            rejection: validation,
            request: request,
          );
        }
        _logPreservedSource(reason, source, 'initial');
        return _ResolvedOutput(validation.fallbackText, false);
      case GeneratedRejected(:final reason):
        _logOutputPolicyRejection(
          'initial',
          source,
          normalizedGenerated,
          validation,
        );
        if (request.retryFailedTranslation) {
          return _recoverRejectedOutput(
            source: source,
            rejectedUserPrompt: userPrompt,
            rejection: validation,
            request: request,
          );
        }
        _log(
          'perf> llm output policy retry skipped kind=hy_mt2 reason=$reason '
          'inputChars=${source.length} setting=disabled',
        );
        return _ResolvedOutput.failed;
    }
  }

  void _acceptBatchResultOrQueueRecovery({
    required _BatchPending item,
    required String? translated,
    required List<String?> results,
    required TranslateRequest request,
    required void Function(int, String?) publish,
    required List<_BatchRecovery> recoveries,
  }) {
    final normalizedTranslated = translated == null
        ? null
        : normalizeGeneratedOutput(
            item.source,
            translated,
            item.individualPrompt,
            request,
          );
    if (normalizedTranslated == null) {
      if (request.retryFailedTranslation) {
        recoveries.add(_BatchRecovery(item, const GeneratedRejected('EMPTY')));
      } else {
        _applyBatchResult(
          item: item,
          translated: null,
          results: results,
          request: request,
          publish: publish,
        );
      }
      return;
    }
    final validation = outputValidation(
      item.source,
      normalizedTranslated,
      item.individualPrompt,
      request,
    );
    switch (validation) {
      case GeneratedAccepted():
        _applyBatchResult(
          item: item,
          translated: normalizedTranslated,
          results: results,
          request: request,
          publish: publish,
        );
      case GeneratedRetryable():
        _logOutputPolicyRejection(
          'batch-initial-retryable',
          item.source,
          normalizedTranslated,
          validation,
        );
        if (request.retryFailedTranslation) {
          recoveries.add(_BatchRecovery(item, validation));
        } else {
          _logPreservedSource(validation.reason, item.source, 'batch-initial');
          _applyBatchResult(
            item: item,
            translated: validation.fallbackText,
            results: results,
            request: request,
            publish: publish,
            cacheable: false,
          );
        }
      case GeneratedRejected():
        _logOutputPolicyRejection(
          'batch-initial',
          item.source,
          normalizedTranslated,
          validation,
        );
        if (request.retryFailedTranslation) {
          recoveries.add(_BatchRecovery(item, validation));
        } else {
          _applyBatchResult(
            item: item,
            translated: null,
            results: results,
            request: request,
            publish: publish,
          );
        }
    }
  }

  /// 恢复：outputRecoveryPrompt 不可用 → fail-closed（terminalFallback）；
  /// 重试生成 → 校验通过可缓存；仍拒绝 → 置空（对齐 recoverRejectedOutputLocked）。
  Future<_ResolvedOutput> _recoverRejectedOutput({
    required String source,
    required String rejectedUserPrompt,
    required GeneratedOutputValidation rejection,
    required TranslateRequest request,
  }) async {
    final recoveryPrompt = outputRecoveryPrompt(
      source,
      rejectedUserPrompt,
      request,
    );
    if (recoveryPrompt == null) {
      _log(
        'perf> llm output policy fail-closed kind=hy_mt2 '
        'reason=${_rejectionReason(rejection)} inputChars=${source.length} '
        'recovery=unavailable',
      );
      return _terminalFallback(rejection, source, 'recovery-unavailable');
    }

    final rawRecovered = await host.generate(
      recoveryPrompt,
      maxTokens: request.maxNewTokens,
    );
    if (rawRecovered == null) {
      return _terminalFallback(rejection, source, 'recovery-empty');
    }
    final recovered = normalizeGeneratedOutput(
      source,
      rawRecovered,
      recoveryPrompt,
      request,
    );
    final retryValidation = outputValidation(
      source,
      recovered,
      recoveryPrompt,
      request,
    );
    switch (retryValidation) {
      case GeneratedAccepted():
        _log(
          'perf> llm output policy recovered kind=hy_mt2 '
          'reason=${_rejectionReason(rejection)} inputChars=${source.length} '
          'outputChars=${recovered.length}',
        );
        return _ResolvedOutput(recovered, true);
      case GeneratedRetryable():
        _logOutputPolicyRejection(
          'retry-retryable',
          source,
          recovered,
          retryValidation,
        );
        return _terminalFallback(retryValidation, source, 'retry');
      case GeneratedRejected():
        _logOutputPolicyRejection('retry', source, recovered, retryValidation);
        return _ResolvedOutput.failed;
    }
  }

  /// Retryable → fallbackText（保留原文展示、不缓存）；Rejected → 置空。
  _ResolvedOutput _terminalFallback(
    GeneratedOutputValidation validation,
    String source,
    String phase,
  ) {
    if (validation is GeneratedRetryable) {
      _logPreservedSource(validation.reason, source, phase);
      return _ResolvedOutput(validation.fallbackText, false);
    }
    return _ResolvedOutput.failed;
  }

  void _applyBatchResult({
    required _BatchPending item,
    required String? translated,
    required List<String?> results,
    required TranslateRequest request,
    required void Function(int, String?) publish,
    bool cacheable = true,
  }) {
    if (translated != null && cacheable) {
      cache.put(item.cacheKey, translated, request);
    }
    for (final index in item.resultIndexes) {
      results[index] = translated;
      publish(index, translated);
    }
  }

  void _logOutputPolicyRejection(
    String phase,
    String source,
    String output,
    GeneratedOutputValidation rejection,
  ) {
    _log(
      'perf> llm output policy rejected kind=hy_mt2 phase=$phase '
      'reason=${_rejectionReason(rejection)} inputChars=${source.length} '
      'outputChars=${output.length}',
    );
  }

  void _logPreservedSource(String reason, String source, String phase) {
    _log(
      'perf> llm output policy preserve source kind=hy_mt2 phase=$phase '
      'reason=$reason inputChars=${source.length} cacheable=false',
    );
  }

  String _rejectionReason(GeneratedOutputValidation rejection) =>
      switch (rejection) {
        GeneratedRetryable(:final reason) => reason,
        GeneratedRejected(:final reason) => reason,
        _ => 'ACCEPTED',
      };
}

class _BatchPending {
  final String source;
  final String individualPrompt;
  final String cacheKey;
  final List<int> resultIndexes = [];

  _BatchPending(this.source, this.individualPrompt, this.cacheKey);
}

class _BatchRecovery {
  final _BatchPending item;
  final GeneratedOutputValidation rejection;

  const _BatchRecovery(this.item, this.rejection);
}
