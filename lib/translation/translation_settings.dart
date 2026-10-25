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

/// 翻译功能持久化设置（键名与默认值按规格 §17）。
///
/// 独立于 `lib/store/user_setting.dart`：user_setting 走 MobX codegen
/// （需要 build_runner 重新生成 .g.dart，当前开发环境无法运行，见交付说明），
/// 本类用 mobx 核心 API 手写 Observable，行为等价且不破坏现有构建。
/// API key 仅存 SharedPreferences，日志禁止打印（规格 §12）。
library;

import 'package:mobx/mobx.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 翻译引擎类型。
enum TranslationEngineType {
  /// 端侧 LLM（llama.cpp + Hy-MT2）。
  local,

  /// 云端 OpenAI 兼容接口。
  cloud,
}

/// OCR 解析引擎。
enum OcrEngineType { mlkit, paddle }

/// 模型下载源（custom 恒为最后一项，保证持久化 index 兼容）。
///
/// 前三项与历史值对齐（0=huggingface, 1=hfMirror, 2=modelScope）；
/// hfMirrorNet 于 2026-10 加入（hf-mirror.com 实测连接超时）。
enum ModelMirror { huggingface, hfMirror, modelScope, hfMirrorNet, custom }

/// 译文文字大小。
///
/// [auto] 就是原来的行为：按 OCR 框面积反解字号，框大就自动放大填满。
/// 其余档位是在这个自适应结果上再乘一个倍率——漫画的小格子里原文本来就
/// 只占几行，按面积算出来的字号在手机上偏小；放大后更好读，代价是长句
/// 会更容易被识别框裁掉尾部（用户按自己的取舍选）。
enum TranslationTextSize {
  auto(1.0, '自适应'),
  small(0.8, '小'),
  large(1.25, '大'),
  huge(1.6, '特大');

  const TranslationTextSize(this.scale, this.label);

  /// 叠加在自适应字号上的倍率（auto = 1.0，即不缩放）。
  final double scale;

  /// 设置页展示名。
  final String label;
}

class TranslationSettings {
  static const String ENGINE_KEY = 'translation_engine'; // int 0=local 1=cloud
  static const String TARGET_LANG_KEY = 'translation_target_lang'; // String
  static const String SOURCE_LANG_KEY = 'translation_source_lang'; // String
  static const String OCR_RESOLUTION_KEY =
      'translation_ocr_resolution'; // int 0..3
  static const String OCR_ENGINE_KEY =
      'translation_ocr_engine'; // int 0=mlkit 1=paddle
  static const String OCR_HIGH_RES_WARNED_KEY =
      'translation_ocr_high_res_warned'; // bool
  static const String MODEL_MIRROR_KEY =
      'translation_model_mirror'; // int 0..4（ModelMirror.index）
  static const String MODEL_MIRROR_URL_KEY =
      'translation_model_mirror_url'; // String
  static const String MODEL_DIRECT_KEY =
      'translation_model_direct'; // bool 直连下载（HF 无 SNI 通道）
  static const String CLOUD_BASE_URL_KEY =
      'translation_cloud_base_url'; // String
  static const String CLOUD_API_KEY_KEY = 'translation_cloud_api_key'; // String
  static const String CLOUD_MODEL_KEY = 'translation_cloud_model'; // String
  static const String CONTEXT_ENABLED_KEY =
      'translation_context_enabled'; // bool
  static const String GLOSSARY_KEY = 'translation_glossary'; // String 源=译 换行分隔
  static const String CACHE_ENABLE_KEY = 'translation_cache_enable'; // bool
  static const String LLM_THREADS_KEY =
      'translation_llm_threads'; // int 0=后端默认
  // 调优实测 tok/s 以 10 倍整数存（9.0 tok/s → 90）：旧版 shared_preferences
  // 的 Android setDouble 通道不可用，曾导致写入抛异常、调优结果丢失。
  static const String LLM_THREADS_BENCH_KEY =
      'translation_llm_threads_bench'; // int tok/s×10，0=未测
  // 性能实验台的三维参数（2026-10 加）：批宽 / flash-attn / 上下文容量。
  // 全部是「0 或 false 走默认」的语义，老安装升级后行为不变。
  static const String LLM_BATCH_KEY = 'translation_llm_batch'; // int 0=默认 4
  static const String LLM_FLASH_ATTN_KEY =
      'translation_llm_flash_attn'; // bool 默认 false
  static const String LLM_CTX_KEY = 'translation_llm_ctx'; // int 0=默认 4096
  static const String LLM_BENCH_SUMMARY_KEY =
      'translation_llm_bench_summary'; // String 上次扫描摘要
  // 译文文字大小档位（TranslationTextSize.index）。只影响显示、不参与推理，
  // 改完立刻重排；0 = 自适应（按识别框放大），也是老安装的默认行为。
  static const String TEXT_SIZE_KEY = 'translation_text_size'; // int 0..3

  final SharedPreferences prefs;

  TranslationSettings(this.prefs);

  final Observable<int> _engine = Observable(0);
  final Observable<String> _targetLang = Observable('auto');
  final Observable<String> _sourceLang = Observable('auto');
  final Observable<int> _ocrResolution = Observable(0);
  final Observable<int> _ocrEngine = Observable(0);
  final Observable<bool> _ocrHighResWarned = Observable(false);
  // 默认 hfMirrorNet：2026-10 实测 hf-mirror.com 连接超时，hf-mirror.net 可用。
  final Observable<int> _modelMirror = Observable(ModelMirror.hfMirrorNet.index);
  final Observable<String> _modelMirrorUrl = Observable('');
  final Observable<bool> _modelDirect = Observable(false);
  final Observable<String> _cloudBaseUrl = Observable('');
  final Observable<String> _cloudApiKey = Observable('');
  final Observable<String> _cloudModel = Observable('');
  final Observable<bool> _contextEnabled = Observable(true);
  final Observable<String> _glossary = Observable('');
  final Observable<bool> _cacheEnable = Observable(true);
  final Observable<int> _llmThreads = Observable(0);
  // tok/s ×10 整数存储（见 LLM_THREADS_BENCH_KEY 注释）。
  final Observable<int> _llmThreadsBench = Observable(0);
  final Observable<int> _llmBatch = Observable(0);
  final Observable<bool> _llmFlashAttn = Observable(false);
  final Observable<int> _llmCtx = Observable(0);
  final Observable<String> _llmBenchSummary = Observable('');
  final Observable<int> _textSize = Observable(0);

  TranslationEngineType get engine =>
      TranslationEngineType.values[_engine.value];
  set engine(TranslationEngineType v) => _engine.value = v.index;

  String get targetLang => _targetLang.value;
  String get sourceLang => _sourceLang.value;
  int get ocrResolutionIndex => _ocrResolution.value;
  OcrEngineType get ocrEngine => OcrEngineType.values[_ocrEngine.value];
  bool get ocrHighResWarned => _ocrHighResWarned.value;
  ModelMirror get modelMirror => ModelMirror.values[_modelMirror.value];
  String get modelMirrorUrl => _modelMirrorUrl.value;
  bool get modelDirectDownload => _modelDirect.value;
  String get cloudBaseUrl => _cloudBaseUrl.value;
  String get cloudApiKey => _cloudApiKey.value;
  String get cloudModel => _cloudModel.value;
  bool get contextEnabled => _contextEnabled.value;
  String get glossary => _glossary.value;
  bool get cacheEnable => _cacheEnable.value;

  /// 端侧推理线程数；0 = 后端默认（llama.cpp 恒 4），>0 = 自动调优或手动选定。
  int get llmThreads => _llmThreads.value;

  /// 自动调优实测速度（tok/s）；0 = 未测过。
  double get llmThreadsBench => _llmThreadsBench.value / 10;

  /// 多序列批宽；0 = 默认（4）。实验台实测后可改为 1/2/4/8。
  int get llmBatch => _llmBatch.value;

  /// 是否启用 flash-attn；默认关闭（端侧短文本 decode 更快）。
  bool get llmFlashAttn => _llmFlashAttn.value;

  /// 上下文容量；0 = 默认（4096）。实验台可试 2048 以省内存。
  int get llmCtx => _llmCtx.value;

  /// 上次性能实验台摘要（人类可读，直接显示在设置页副标题）。
  String get llmBenchSummary => _llmBenchSummary.value;

  /// 译文文字大小档位；[TranslationTextSize.auto] = 按识别框自适应放大。
  TranslationTextSize get textSize =>
      TranslationTextSize.values[_textSize.value.clamp(
        0,
        TranslationTextSize.values.length - 1,
      )];

  /// 叠加在自适应字号上的倍率（auto = 1.0）。
  double get textScale => textSize.scale;

  /// 从 SharedPreferences 读入（与 UserSetting.init 风格一致）。
  Future<void> init() async {
    _engine.value = prefs.getInt(ENGINE_KEY) ?? 0;
    _targetLang.value = prefs.getString(TARGET_LANG_KEY) ?? 'auto';
    _sourceLang.value = prefs.getString(SOURCE_LANG_KEY) ?? 'auto';
    _ocrResolution.value = prefs.getInt(OCR_RESOLUTION_KEY) ?? 0;
    _ocrEngine.value = prefs.getInt(OCR_ENGINE_KEY) ?? 0;
    _ocrHighResWarned.value = prefs.getBool(OCR_HIGH_RES_WARNED_KEY) ?? false;
    _modelMirror.value =
        prefs.getInt(MODEL_MIRROR_KEY) ?? ModelMirror.hfMirrorNet.index;
    _modelMirrorUrl.value = prefs.getString(MODEL_MIRROR_URL_KEY) ?? '';
    _modelDirect.value = prefs.getBool(MODEL_DIRECT_KEY) ?? false;
    _cloudBaseUrl.value = prefs.getString(CLOUD_BASE_URL_KEY) ?? '';
    _cloudApiKey.value = prefs.getString(CLOUD_API_KEY_KEY) ?? '';
    _cloudModel.value = prefs.getString(CLOUD_MODEL_KEY) ?? '';
    _contextEnabled.value = prefs.getBool(CONTEXT_ENABLED_KEY) ?? true;
    _glossary.value = prefs.getString(GLOSSARY_KEY) ?? '';
    _cacheEnable.value = prefs.getBool(CACHE_ENABLE_KEY) ?? true;
    _llmThreads.value = prefs.getInt(LLM_THREADS_KEY) ?? 0;
    _llmThreadsBench.value = prefs.getInt(LLM_THREADS_BENCH_KEY) ?? 0;
    _llmBatch.value = prefs.getInt(LLM_BATCH_KEY) ?? 0;
    _llmFlashAttn.value = prefs.getBool(LLM_FLASH_ATTN_KEY) ?? false;
    _llmCtx.value = prefs.getInt(LLM_CTX_KEY) ?? 0;
    _llmBenchSummary.value = prefs.getString(LLM_BENCH_SUMMARY_KEY) ?? '';
    _textSize.value = prefs.getInt(TEXT_SIZE_KEY) ?? 0;
  }

  Future<void> setEngine(TranslationEngineType v) async {
    await prefs.setInt(ENGINE_KEY, v.index);
    _engine.value = v.index;
  }

  Future<void> setTargetLang(String v) async {
    await prefs.setString(TARGET_LANG_KEY, v);
    _targetLang.value = v;
  }

  Future<void> setSourceLang(String v) async {
    await prefs.setString(SOURCE_LANG_KEY, v);
    _sourceLang.value = v;
  }

  Future<void> setOcrResolutionIndex(int v) async {
    await prefs.setInt(OCR_RESOLUTION_KEY, v);
    _ocrResolution.value = v;
  }

  Future<void> setOcrEngine(OcrEngineType v) async {
    await prefs.setInt(OCR_ENGINE_KEY, v.index);
    _ocrEngine.value = v.index;
  }

  Future<void> setOcrHighResWarned(bool v) async {
    await prefs.setBool(OCR_HIGH_RES_WARNED_KEY, v);
    _ocrHighResWarned.value = v;
  }

  Future<void> setModelMirror(ModelMirror v) async {
    await prefs.setInt(MODEL_MIRROR_KEY, v.index);
    _modelMirror.value = v.index;
  }

  Future<void> setModelMirrorUrl(String v) async {
    await prefs.setString(MODEL_MIRROR_URL_KEY, v);
    _modelMirrorUrl.value = v;
  }

  Future<void> setModelDirectDownload(bool v) async {
    await prefs.setBool(MODEL_DIRECT_KEY, v);
    _modelDirect.value = v;
  }

  Future<void> setCloudBaseUrl(String v) async {
    await prefs.setString(CLOUD_BASE_URL_KEY, v);
    _cloudBaseUrl.value = v;
  }

  Future<void> setCloudApiKey(String v) async {
    await prefs.setString(CLOUD_API_KEY_KEY, v);
    _cloudApiKey.value = v;
  }

  Future<void> setCloudModel(String v) async {
    await prefs.setString(CLOUD_MODEL_KEY, v);
    _cloudModel.value = v;
  }

  Future<void> setContextEnabled(bool v) async {
    await prefs.setBool(CONTEXT_ENABLED_KEY, v);
    _contextEnabled.value = v;
  }

  Future<void> setGlossary(String v) async {
    await prefs.setString(GLOSSARY_KEY, v);
    _glossary.value = v;
  }

  Future<void> setCacheEnable(bool v) async {
    await prefs.setBool(CACHE_ENABLE_KEY, v);
    _cacheEnable.value = v;
  }

  Future<void> setLlmThreads(int v) async {
    await prefs.setInt(LLM_THREADS_KEY, v);
    // 被 Observer 观察的 Observable 必须在 action 内赋值，否则 mobx 抛
    // 「modification outside of Action」——曾导致 prefs 写成功、Observable
    // 与 UI 停留旧值，调优结果丢失。
    runInAction(() => _llmThreads.value = v);
  }

  Future<void> setLlmThreadsBench(double tokensPerSec) async {
    final v = (tokensPerSec * 10).round();
    await prefs.setInt(LLM_THREADS_BENCH_KEY, v);
    runInAction(() => _llmThreadsBench.value = v);
  }

  Future<void> setLlmBatch(int v) async {
    await prefs.setInt(LLM_BATCH_KEY, v);
    runInAction(() => _llmBatch.value = v);
  }

  Future<void> setLlmFlashAttn(bool v) async {
    await prefs.setBool(LLM_FLASH_ATTN_KEY, v);
    runInAction(() => _llmFlashAttn.value = v);
  }

  Future<void> setLlmCtx(int v) async {
    await prefs.setInt(LLM_CTX_KEY, v);
    runInAction(() => _llmCtx.value = v);
  }

  Future<void> setLlmBenchSummary(String v) async {
    await prefs.setString(LLM_BENCH_SUMMARY_KEY, v);
    runInAction(() => _llmBenchSummary.value = v);
  }

  Future<void> setTextSize(TranslationTextSize v) async {
    await prefs.setInt(TEXT_SIZE_KEY, v.index);
    runInAction(() => _textSize.value = v.index);
  }

  /// 解析术语表文本（`源=译` 每行一条）。
  List<({String source, String target})> parseGlossary() {
    final terms = <({String source, String target})>[];
    for (final line in glossary.split('\n')) {
      final trimmed = line.trim();
      if (trimmed.isEmpty) continue;
      final idx = trimmed.indexOf('=');
      if (idx <= 0 || idx >= trimmed.length - 1) continue;
      final source = trimmed.substring(0, idx).trim();
      final target = trimmed.substring(idx + 1).trim();
      if (source.isEmpty || target.isEmpty) continue;
      terms.add((source: source, target: target));
    }
    return terms;
  }
}
