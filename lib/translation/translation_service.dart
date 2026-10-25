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

/// 翻译服务组装：设置 / 引擎宿主 / 翻译器 / OCR 引擎的进程内单例。
///
/// 平台能力注入点：
/// - ML Kit OCR：[MlkitOcrEngine]（app 侧实现 OcrEngine）；
/// - 端侧 LLM：`LlmGenerationEngine` 的真实 llama.cpp FFI 实现依赖原生构建
///   （规格 §10 R1，`--dart-define=TRANSLATOR_LOCAL_LLM` 编译期开关）；
///   未启用时端侧请求抛 [TranslationException]，UI 引导切换云端引擎。
library;

import 'dart:ffi' show Abi;
import 'dart:io';

import 'package:flutter/foundation.dart' show ValueNotifier;
import 'package:pixez/er/lprinter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:translator/translator.dart';

import 'cloud_endpoint.dart';
import 'image_decode_service.dart';
import 'llama/llama_ffi_engine.dart';
import 'local_network_permission.dart';
import 'mlkit_ocr_engine.dart';
import 'platform_support.dart';
import 'translation_settings.dart';
import 'translation_store.dart';

/// `TRANSLATOR_LOCAL_LLM` 的原始字符串值（编译期注入）。
///
/// 不直接用 `bool.fromEnvironment`：它只认 `'true'`/`'false'`，
/// `--dart-define=TRANSLATOR_LOCAL_LLM=1` 会静默回退默认值 false
/// （曾导致构建带了开关端侧却始终「未编译启用」）。
const String kTranslatorLocalLlmRaw = String.fromEnvironment(
  'TRANSLATOR_LOCAL_LLM',
);

/// 端侧引擎是否在编译期启用（规格 R1-D1-C 默认 0）。`1` 与 `true` 等价。
const bool kTranslatorLocalLlmEnabled =
    kTranslatorLocalLlmRaw == '1' || kTranslatorLocalLlmRaw == 'true';

/// 端侧模型支持的 ABI：仅 64 位。armeabi-v7a 32 位地址空间 ~3GB，
/// 1GB 权重 + KV cache 极易 OOM，产品决策禁止端侧模型（只能云端 API）；
/// 该 ABI 的 APK 也不编入 llama.cpp（见 android cpp/CMakeLists.txt）。
///
/// 判定实体在 [isLocalTranslationAdapted]（同时覆盖「非 Android 平台根本
/// 没有原生库」这一层），这里只保留旧名字给已有调用点。
///
/// 注意：dart:ffi 的 [Abi] 在本 SDK 是 class 而非 enum，`Abi.current()`
/// 是 external factory 构造——不带括号取到的是构造函数本身（tear-off），
/// 与任何值比较恒 false，曾在所有设备上误报「不支持」。
bool get kLocalLlmAbiSupported => isLocalTranslationAdapted;

/// 端侧引擎不可用时的占位实现（未编译 / 32 位设备），报 [reason]。
class _UnavailableLocalEngine implements LlmGenerationEngine {
  final String reason;
  _UnavailableLocalEngine(this.reason);

  @override
  LlmEngineState get state => LlmEngineState.error;

  @override
  Future<void> loadModel(
    String modelPath, {
    required int contextSize,
    int? threads,
    bool flashAttn = false,
  }) async {
    throw LlmModelNotReadyException(reason);
  }

  @override
  Stream<String> generateStream(
    String prompt, {
    required int maxTokens,
  }) async* {
    throw LlmModelNotReadyException(reason);
  }

  @override
  Future<List<String>> generateBatch(
    List<String> prompts, {
    required int maxTokens,
  }) async {
    throw LlmModelNotReadyException(reason);
  }

  @override
  Future<void> cleanUp() async {}
}

class TranslationService with TranslationPipeline {
  TranslationService._();

  static final TranslationService instance = TranslationService._();

  TranslationSettings? _settings;
  TranslationSettings get settings => _settings!;

  final TranslationCache _cache = TranslationCache();
  LlmEngineHost? _host;
  OcrEngine? _mlkitEngine;

  /// 译文文字缩放倍率（1.0 = 自适应原样）。
  ///
  /// 用 [ValueNotifier] 而不是 settings 的 mobx Observable：译文覆盖层在
  /// 信息流卡片、详情长图、PhotoView 三处复用，外层不一定在 `Observer`
  /// 里；ValueListenableBuilder 简单直接，改完立刻重排。
  final ValueNotifier<double> translationTextScale = ValueNotifier<double>(
    1.0,
  );

  final ImageDecodeService _decodeService = ImageDecodeService();
  ImageDecodeService get decodeService => _decodeService;

  /// 端侧模型落盘路径缓存（首次访问解析；供同步安装判定使用）。
  String? _modelPath;

  Future<void> ensureInitialized() async {
    if (_settings != null) return;
    final prefs = await SharedPreferences.getInstance();
    final s = TranslationSettings(prefs);
    await s.init();
    _settings = s;
    // 端侧后端没编进当前平台时，把停在「本地」的引擎拉回云端。
    // 设置页在未适配设备上已经禁用了模型区块，如果不在这里兜底，用户会
    // 卡在「本地引擎不可用 + 模型设置点不动」的死角里，没有任何出口。
    if (s.engine == TranslationEngineType.local && !isLocalTranslationAdapted) {
      LPrinter.d(
        'translation> 端侧引擎在当前平台不可用，自动回退云端接口',
      );
      await s.setEngine(TranslationEngineType.cloud);
    }
    translationTextScale.value = s.textScale;
    // 提前解析并缓存模型路径：host 的同步 modelPathProvider 依赖它。
    await modelSavePath;
  }

  /// 端侧模型落盘路径：`<appDocuments>/models/llm/Hy-MT2-1.8B-Q4_K_M.gguf`
  /// （规格 §9.1）。
  Future<String> get modelSavePath async {
    final cached = _modelPath;
    if (cached != null) return cached;
    final dir = await getApplicationDocumentsDirectory();
    return _modelPath =
        '${dir.path}${Platform.pathSeparator}models'
        '${Platform.pathSeparator}llm'
        '${Platform.pathSeparator}${ModelSpec.hyMt2.fileName}';
  }

  /// 端侧模型文件是否已就位（同步判定；下载/导入时已做 GGUF 校验，
  /// 这里只查文件存在性）。
  bool get isModelFileInstalled =>
      _modelPath != null && File(_modelPath!).existsSync();

  LlmEngineHost _ensureHost() {
    if (_host == null) {
      _host = LlmEngineHost(
        // 可用性分层：编译开关（TRANSLATOR_LOCAL_LLM）→ ABI（32 位禁止）
        // → llama.cpp FFI 真引擎（贪心解码，翻译要稳定）。
        engineFactory: () {
          if (!kTranslatorLocalLlmEnabled) {
            return _UnavailableLocalEngine(
              '端侧引擎未启用（需要 llama.cpp 原生构建，TRANSLATOR_LOCAL_LLM=1），'
              '请改用云端引擎',
            );
          }
          if (!kLocalLlmAbiSupported) {
            return _UnavailableLocalEngine(
              'app 正以 32 位模式运行（${Abi.current()}），端侧模型不可用；'
              '64 位设备请安装 arm64-v8a / universal 版 APK，或改用云端引擎',
            );
          }
          return LlamaFfiEngine();
        },
        // 模型文件在盘即可尝试加载；端侧后端未编译时由引擎自身报错
        // （「端侧引擎未启用…」），不再谎报「模型未安装」。
        modelPathProvider: () => isModelFileInstalled ? _modelPath : null,
        // 推理线程数走 provider：设置页调优/手改后下次 load 即生效，
        // 无需重建宿主（0 = 用 llama.cpp 默认 4 线程）。
        threadsProvider: () {
          final t = settings.llmThreads;
          return t > 0 ? t : null;
        },
        // flash-attn 同理：实验台实测后由设置决定，默认关闭。
        flashAttnProvider: () => settings.llmFlashAttn,
        // 上下文容量：实验台可能选 2048（省 ~235MB KV）或保持 4096。
        // 只在宿主首次创建时读取——改动用「实验台→应用」后需重进翻译页，
        // 该路径会重建宿主（见 TranslationService.resetHost）。
        contextSize: (_settings?.llmCtx ?? 0) > 0 ? _settings!.llmCtx : 4096,
        onLog: (m) => LPrinter.d(m),
      );
    }
    return _host!;
  }

  /// 当前选择的翻译引擎。
  Translator _buildTranslator() {
    final s = settings;
    if (s.engine == TranslationEngineType.cloud) {
      final baseUrl = normalizeCloudBaseUrl(s.cloudBaseUrl);
      if (baseUrl == null) {
        throw TranslationException(
          '云端接口地址无效或未填写。请到「翻译设置 → 云端接口」填写，'
          '例如 http://192.168.1.5:8080/v1（局域网可直接用 http）',
          code: 'BAD_BASE_URL',
        );
      }
      return OpenAiCompatibleTranslator(
        config: OpenAiCompatibleConfig(
          baseUrl: baseUrl,
          apiKey: s.cloudApiKey,
          model: s.cloudModel,
        ),
        cache: _cache,
      );
    }
    return LocalLlamaTranslator(
      host: _ensureHost(),
      cache: _cache,
      // 安装态查磁盘文件，与设置页 isInstalled 口径一致；
      // 编译期开关（TRANSLATOR_LOCAL_LLM）只影响引擎可用性，在加载阶段报错。
      modelInstalled: () => isModelFileInstalled,
      // 批宽由实验台实测决定（0 = 默认 4）；每次批量翻译现读，无需重建。
      nativeBatchSizeProvider: () => s.llmBatch,
      onLog: (m) => LPrinter.d(m),
    );
  }

  /// 丢弃当前端侧宿主（下次翻译按新配置重建）。
  ///
  /// 上下文容量 / 线程数是宿主构建与 load 期参数，实验台点「应用」后必须
  /// 换掉宿主，否则新容量不会生效。云端引擎不受影响。
  Future<void> resetHost() async {
    final host = _host;
    _host = null;
    if (host == null) return;
    try {
      await host.shutdown();
    } catch (e) {
      LPrinter.d('perf> llm host shutdown failed: $e');
    }
  }

  /// 图片翻译管线（含当前 OCR 引擎与翻译引擎）。
  Future<ImageTranslator> get imageTranslator async {
    await ensureInitialized();
    await _ensureCloudLocalNetworkPermission();
    final ocrEngine = settings.ocrEngine == OcrEngineType.paddle
        ? throw UnimplementedError('PP-OCRv5 引擎待接入（规格 D4：留接口后补）')
        : (_mlkitEngine ??= MlkitOcrEngine());
    return ImageTranslator(
      ocrEngine: ocrEngine,
      translator: _buildTranslator(),
    );
  }

  /// 文本翻译管线。
  Future<TextTranslator> getTextTranslator() async {
    await ensureInitialized();
    await _ensureCloudLocalNetworkPermission();
    return TextTranslator(translator: _buildTranslator());
  }

  /// 云端接口是否指向局域网 / 本机。
  bool isCloudEndpointLocal() {
    final baseUrl = normalizeCloudBaseUrl(settings.cloudBaseUrl);
    if (baseUrl == null) return false;
    return isLocalNetworkHost(Uri.tryParse(baseUrl)?.host ?? '');
  }

  /// Android 17（API 37）默认拦截局域网访问，指向局域网的云端接口
  /// 必须先拿到 `ACCESS_LOCAL_NETWORK` 运行时权限，否则连接直接被系统拒绝。
  Future<void> _ensureCloudLocalNetworkPermission() async {
    if (settings.engine != TranslationEngineType.cloud) return;
    if (!isCloudEndpointLocal()) return;
    if (await ensureLocalNetworkPermission()) return;
    throw TranslationException(
      'Android 17 需要「本地网络」权限才能访问局域网接口。'
      '请到系统设置 → 应用 → PixEz → 权限 → 附近设备 / 本地网络 中开启，'
      '或重新填写接口地址时按提示授权',
      code: 'LOCAL_NETWORK_DENIED',
    );
  }

  /// 从设置构建翻译请求（目标语言 / 缓存开关 / 术语表 / 同页上下文）。
  Future<TranslateRequest> buildRequest({
    List<String> currentPage = const [],
  }) async {
    await ensureInitialized();
    final s = settings;
    final terms = s
        .parseGlossary()
        .map((t) => RuntimeGlossaryTerm(t.source, t.target))
        .toList();
    return TranslateRequest(
      sourceLang: s.sourceLang,
      targetLang: s.targetLang,
      systemPrompt: null,
      useCache: s.cacheEnable,
      context: RuntimePromptContext(currentPage: currentPage, glossary: terms),
    );
  }

  /// 清空译文缓存（设置页「清除缓存」，规格 §8.5）。
  void clearCache() => _cache.clear();

  /// 云端接口测试连接（设置页「测试连接」按钮，规格 §8.5）。
  Future<TestResult> testCloudConnection() async {
    await ensureInitialized();
    final s = settings;
    final baseUrl = normalizeCloudBaseUrl(s.cloudBaseUrl);
    if (baseUrl == null) {
      return const TestResult(
        success: false,
        message: '接口地址无效或未填写，例如 http://192.168.1.5:8080/v1',
      );
    }
    // 指向局域网时先要权限：Android 17 会直接拒绝未授权的本地 TCP 连接，
    // 不先申请的话用户只会看到一句「网络错误」，完全无法定位。
    if (isLocalNetworkHost(Uri.tryParse(baseUrl)?.host ?? '') &&
        !await ensureLocalNetworkPermission()) {
      return const TestResult(
        success: false,
        message: '需要「本地网络」权限：请到系统设置 → 应用 → PixEz → 权限 → '
            '附近设备 / 本地网络 中开启后重试',
      );
    }
    final translator = OpenAiCompatibleTranslator(
      config: OpenAiCompatibleConfig(
        baseUrl: baseUrl,
        apiKey: s.cloudApiKey,
        model: s.cloudModel,
      ),
    );
    try {
      return await translator.testConnection(
        TranslateRequest(targetLang: s.targetLang),
      );
    } finally {
      await translator.dispose();
    }
  }

  /// 进入翻译页时预热端侧引擎（仅当路由到端侧且模型已安装，规格 §7.2）。
  Future<void> prewarm() async {
    await ensureInitialized();
    if (settings.engine != TranslationEngineType.local) return;
    final decision = decidePrewarm(
      routedToLocalModel: settings.engine == TranslationEngineType.local,
      modelInstalled: isModelFileInstalled && kLocalLlmAbiSupported,
    );
    if (decision != PrewarmDecision.prewarm) return;
    try {
      await _ensureHost().prewarm();
    } catch (e) {
      LPrinter.d('perf> llm prewarm skipped: $e');
    }
  }

  /// 性能实验台：四维坐标下降扫描（批宽 → 线程 → 上下文 → flash-attn）。
  ///
  /// 为什么不是全组合：线程 6 × 批宽 4 × ctx 2 × FA 2 = 96 组，每组都要
  /// 重载一次权重（真机 2~5 秒），全跑完十几分钟——手机上不可接受。
  /// 坐标下降用 14 组就能定位到同一最优解，而且能逐维看出「哪个参数
  /// 真的有用」（表里每段一组，用户能看见线程 2→4 到底提升了多少）。
  ///
  /// 指标是**段/分钟**而非 tok/s：线程数只影响单 token 速度，批宽影响的是
  /// 并行度，只有「同样一份活干完用多久」才让两者可比。
  Future<LlmTuningScan> benchmarkTunings({
    void Function(int done, int total, String stage, LlmTuning tuning)?
    onPointStart,
    void Function(LlmBenchPoint point)? onPointDone,
  }) async {
    await ensureInitialized();
    if (!isModelFileInstalled) {
      throw TranslationException('端侧模型未安装，请先下载或导入模型后再实测');
    }
    // 4 段短句 ≈ 一页漫画的对白量：足够体现并行收益，又不至于让每个
    // 点位跑上一分钟。
    final prompts = [
      for (final source in _kBenchSources)
        HyMt2PromptPolicy.build(
          source,
          'zh-Hans',
          const RuntimePromptContext(currentPage: [], glossary: []),
        ),
    ];

    const batchCandidates = <int>[1, 2, 4, 8];
    final threadCandidates = defaultThreadCandidates();
    const ctxCandidates = <int>[4096, 2048];
    const faCandidates = <bool>[false, true];
    final total =
        batchCandidates.length +
        threadCandidates.length +
        ctxCandidates.length +
        faCandidates.length;

    final points = <LlmBenchPoint>[];
    final host = _ensureHost();

    Future<LlmBenchPoint> run(String stage, LlmTuning tuning) async {
      onPointStart?.call(points.length + 1, total, stage, tuning);
      final point = await host.measureTuning(
        tuning: tuning,
        workload: prompts,
        maxTokens: 24,
      );
      points.add(point);
      onPointDone?.call(point);
      return point;
    }

    // 起点用当前设置：让「实测结果 vs 现状」可比。
    var current = LlmTuning(
      threads: settings.llmThreads > 0 ? settings.llmThreads : null,
      flashAttn: settings.llmFlashAttn,
      contextSize: settings.llmCtx > 0 ? settings.llmCtx : 4096,
      batchSize: settings.llmBatch > 0 ? settings.llmBatch : 4,
    );

    // 单维扫描：其余维度固定为 current，选出该维最优后写回 current。
    // 全维都失败（如连续 OOM）时保持原值，不让扫描把配置弄坏。
    Future<void> sweep(
      String stage,
      List<LlmTuning> Function(LlmTuning base) variants,
    ) async {
      // 逐点串行：推理队列本身就串行，Future.wait 只会让进度条瞬间跳到
      // 该维的终点，看不出正在测哪个参数。
      final results = <LlmBenchPoint>[];
      for (final v in variants(current)) {
        results.add(await run(stage, v));
      }
      final best = _pickBest(results);
      if (best != null) current = best.tuning;
    }

    await sweep(
      '批宽',
      (base) => [for (final b in batchCandidates) base.copyWith(batchSize: b)],
    );
    await sweep(
      '线程数',
      (base) => [for (final t in threadCandidates) base.copyWith(threads: t)],
    );
    await sweep(
      '上下文',
      (base) => [for (final c in ctxCandidates) base.copyWith(contextSize: c)],
    );
    await sweep(
      'FlashAttn',
      (base) => [for (final f in faCandidates) base.copyWith(flashAttn: f)],
    );

    // 末轮确认：坐标下降的最终组合可能和任一单维最优都不同（维度间有
    // 交互），补测一次给出真实预期值。
    final confirm = await run('确认', current);
    final best = confirm.isUsable ? confirm : _pickBest(points);
    LPrinter.d(
      'perf> bench scan done points=${points.length} best=${best?.tuning} '
      'segPerMin=${best?.segmentsPerMin.toStringAsFixed(1)}',
    );
    return LlmTuningScan(points: points, best: best);
  }

  /// 采用实测配置（落盘 + 换宿主，让上下文容量与线程数生效）。
  Future<void> applyTuning(LlmTuning tuning) async {
    await ensureInitialized();
    await settings.setLlmThreads(tuning.threads ?? 0);
    await settings.setLlmBatch(tuning.batchSize);
    await settings.setLlmFlashAttn(tuning.flashAttn);
    await settings.setLlmCtx(tuning.contextSize ?? 0);
    await resetHost();
  }

  /// 设置译文文字大小：只影响显示，不重载模型、不清缓存。
  Future<void> setTranslationTextSize(TranslationTextSize size) async {
    await ensureInitialized();
    await settings.setTextSize(size);
    translationTextScale.value = size.scale;
  }

  /// 从点位集合里挑最优：段/分钟最高；同速（2% 内）取更省电的组合
  /// （线程少 > 上下文小 > FA 关）——测量抖动不该让我们多烧电。
  static LlmBenchPoint? _pickBest(List<LlmBenchPoint> points) {
    final usable = points.where((p) => p.isUsable).toList();
    if (usable.isEmpty) return null;
    usable.sort((a, b) => b.segmentsPerMin.compareTo(a.segmentsPerMin));
    var best = usable.first;
    for (final p in usable.skip(1)) {
      if (p.segmentsPerMin < best.segmentsPerMin * 0.98) break;
      if (_cheaper(p.tuning, best.tuning)) best = p;
    }
    return best;
  }

  static bool _cheaper(LlmTuning a, LlmTuning b) {
    final at = a.threads ?? 4, bt = b.threads ?? 4;
    if (at != bt) return at < bt;
    final ac = a.contextSize ?? 4096, bc = b.contextSize ?? 4096;
    if (ac != bc) return ac < bc;
    return !a.flashAttn && b.flashAttn;
  }
}

/// 实验台样本句（长度贴近漫画短对白，4 段 ≈ 一页画面的对白量）。
const List<String> _kBenchSources = [
  'ねえ、ちょっと待ってよ！',
  '今日の放課後、屋上で待ってるから。',
  '……そんなの、知らない。',
  'もう、しょうがないなあ。',
];

/// 性能实验台的扫描结果。
class LlmTuningScan {
  final List<LlmBenchPoint> points;

  /// 实测最优组合；全部失败时为 null。
  final LlmBenchPoint? best;

  const LlmTuningScan({required this.points, required this.best});
}
