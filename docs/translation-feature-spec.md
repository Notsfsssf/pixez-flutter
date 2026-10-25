# 任务详情：PixEz 端侧图片翻译 + 文本翻译

> 状态：待评审（本文档为实施前规格，确认「第 13 节 待确认决策」后进入编码）  
> 版本：v1 · 2026-10-23  
> 基线：upstream 提交 406ced12（ymh0000123/pixez-flutter）  
> 许可证：GPL-3.0（所有新增源文件必须带 GPL-3.0 header，见第 12 节）

---

## 1. 背景与目标

PixEz 目前只有「把选中文本交给外部 App 翻译」的能力（`SupportorPlugin.processText` / `start`，见 `lib/supportor_plugin.dart`），依赖用户设备另装翻译 App，且只能处理可选择的纯文本。

本任务在应用内实现两类翻译能力：

| 能力 | 输入 | 处理链路 |
| --- | --- | --- |
| **图片翻译** | 插画 / 漫画图片（日文对话、旁白、拟声词） | 按用户设定分辨率解码 → 端侧 OCR → 坐标换算 → 逐块翻译 → 覆盖层贴回原图对应位置 |
| **文本翻译** | 小说正文段落、作品标题/caption、评论 | 直接送 LLM（无需 OCR）→ 段落级 / 流式译文 |

**非目标（明确排除）**

- 不支持 ugoira 动图（`illusts.type == 'ugoira'` 时隐藏翻译入口）。
- 不做视频 / 摄像头实时翻译（overlay-translator 的悬浮窗捕获语义不移植）。
- 不移植桌面 Fluent UI 树（`lib/fluent/**`）的图片翻译；仅保证不破坏其构建。
- 不做全自动批量翻译整本漫画（按图、按需触发）。

**参考项目**：https://github.com/ciddwd/overlay-translator （屏译，Kotlin/Android）。
本任务只移植其 **翻译策略层** 与 **引擎生命周期层**，不移植其悬浮窗 / 无障碍 / 截屏服务。

---

## 2. 事实核查结论（与原始任务书的差异）

以下差异已逐项核对源码 / pub.dev / HuggingFace API，实施时以本表为准：

| # | 任务书表述 | 核查结果 | 处理 |
| --- | --- | --- | --- |
| 1 | 参考文件在 `translate/LlamaEngineHolder.kt` | 实际在 `app/src/main/java/com/gameocr/app/llm/LlamaEngineHolder.kt`，同目录另有 `LlamaEngineLifecycleGate.kt` | 路径纠正 |
| 2 | 参考项目有 4 个文件 | 实际驱动校验/重试/缓存的执行体是 `translate/LocalLlamaTranslator.kt`（1221 行），`HyMt2Translator.kt` 只做策略绑定 | 追加参考文件 |
| 3 | 可选 OCR 引擎「ente mobile_ocr」 | pub.dev **不存在** `ente` 包（API 404；搜索无同名 OCR 包） | 候选改为 `flutter_paddle_ocr_v5` / `paddle_ocr_native` |
| 4 | `llamafu` 可直接 `flutter pub add` 用于 Android | `llamafu 0.1.0` 的 pub 归档内**无预编译 `.so`**、**无 `llama.cpp` 子模块**；`android/build.gradle` 用 `externalNativeBuild` + `add_subdirectory(${LLAMA_CPP_DIR})`，缺目录时 CMake 直接 FATAL | 见第 10 节风险 R1，需 spike 决策 |
| 5 | 项目为 Flutter 3.35 | `pubspec.lock` 的 `sdks` 为 `dart: ">=3.13.0 <4.0.0"` / `flutter: ">=3.47.0"`；本机仅有 `/f/Flutter/flutter` = **3.32.5 / Dart 3.8.1** | 见第 10 节风险 R4 |
| 6 | 术语表 / 背景信息结构 | 参考实现背景分三段：`Current application` / `Previous dialogue` / `Other text on the current page`；术语表行格式 `{源} translates to {译}` | 按实际格式移植 |
| 7 | 模型体积「约 1.1GB」 | HuggingFace API 实测 `Hy-MT2-1.8B-Q4_K_M.gguf` = **1,133,080,448 B（≈1080 MiB）** | 落为常量 `1133080448` |

**已确认可用的依赖版本（pub.dev 实测）**

| 包 | 最新版 | 环境约束 | 结论 |
| --- | --- | --- | --- |
| `google_mlkit_text_recognition` | 0.17.1 | sdk ^3.12.0, flutter >=3.44.0 | 与本项目 lock 兼容，采用 |
| `google_mlkit_text_recognition` | 0.16.0 | sdk >=3.8.0, flutter >=3.32.0 | 降级备选 |
| `flutter_paddle_ocr_v5` | 0.0.3 | sdk ^3.10.8, flutter >=3.3.0 | 第二引擎候选 |
| `paddle_ocr_native` | 0.1.1 | sdk ^3.12.0, flutter >=3.44.0 | 备选（插件声明需复核） |
| `llamafu` | 0.1.0 | sdk >=3.1.0, flutter >=3.10.0；**MIT** | 端侧后端候选（原生库需 vendor） |
| `llama_cpp_dart` | 0.2.2 | sdk >=3.2.0；**MIT**；Android 走 CMake，需 vendor `llama.cpp` | 备选 |
| `flutter_llama` | 1.2.1 | **NativeMindNONC（非商业许可）** | **禁止使用**（与 GPL-3.0 分发冲突） |

---

## 3. 参考实现 → Dart 移植映射表

移植原则：**逐条对齐语义，不「参考着写」**。参考项目同名测试（`app/src/test/java/com/gameocr/app/translate/*Test.kt`）即是可执行验收样本。

| Kotlin 参考文件 | 职责 | Dart 目标文件 | 移植要点 |
| --- | --- | --- | --- |
| `translate/HyMt2PromptPolicy.kt` | 官方 prompt 模板 | `lib/src/translate/hy_mt2_prompt_policy.dart` | 38 项语言名表、`auto→zh-CN`、`zh-tw/hk/mo/hant→Traditional Chinese`、有/无背景两套模板、术语表前缀、`isBackgroundPrompt` |
| `translate/HyMt2OutputPolicy.kt` | 输出校验（上下文渗透检测） | `lib/src/translate/hy_mt2_output_policy.dart` | 9 个 Reason + `normalizeHarmlessSingleItemPrefix` + NFKC 归一 |
| `translate/HyMt2GenerationBoundaryPolicy.kt` | 每段最大输出行数 | `lib/src/translate/hy_mt2_generation_boundary_policy.dart` | `源行数 + 1`（仅背景模式生效，否则 0 = 不限） |
| `translate/HyMt2Translator.kt` | 策略绑定 | `lib/src/translate/hy_mt2_profile.dart` | `bufferGeneratedOutputUntilValidated = true`、`runtimePrompt` 直通、拒绝后走去背景 prompt 重试一次 |
| `translate/LocalLlamaTranslator.kt` | 生成 + 校验 + 重试 + 缓存 + 批量 | `lib/src/translate/local_llama_translator.dart` | `validateAndRecoverOutputLocked` 三段式（Accepted / Retryable / Rejected）、`terminalFallback`、批量增量回调 |
| `translate/LocalLlamaTranslationCacheKey.kt` | 缓存键 | `lib/src/translate/cache_key.dart` | `model` \| `targetLang` \| `promptHash` \| `sourceHash` \| `sourceLen` + prompt 指纹 |
| `translate/TranslationCache.kt` | LRU 缓存 | `lib/src/translate/translation_cache.dart` | access-order LRU，容量 256，缓存命中也要重校验 |
| `llm/LlamaEngineHolder.kt` | 引擎单例 + 空闲卸载 | `lib/src/engine/llm_engine_host.dart` | 单实例、`initLock`、5 分钟空闲卸载、`touch`、Error 态自愈、`cleanUp` 不 destroy |
| `llm/LlamaEngineLifecycleGate.kt` | 推理串行 | `lib/src/engine/inference_queue.dart` | Isolate 单线程消息队列即天然串行 |
| `translate/LocalLlmPrewarmPolicy.kt` | 预热决策 | `lib/src/engine/prewarm_policy.dart` | 仅当「路由到端侧」且「模型已安装」才预热 |
| `llm/LlmModelInstaller.kt` | 模型下载/校验/导入 | `lib/src/model/model_installer.dart` | GGUF magic + `max(4MiB, 标称×80%)`、`.tmp` 续传、镜像回退、本地导入 |
| `ocr/OcrEngine.kt` + `ocr/TextBlock.kt` | OCR 抽象 | `lib/src/ocr/ocr_engine.dart`、`lib/src/model/text_block.dart` | 接口 + 文本块（多边形 / 置信度 / 朝向） |
| `overlay/OverlayPresentationGeometry.kt` | 坐标系换算 | `lib/src/geometry/rect_mapper.dart` | 解码坐标 ↔ 原图坐标 ↔ 显示坐标 |

**不移植**：`Sakura*`、`BaiduFanyi`、`DeepL`、`Tencent`、`NiuTrans`、`Volc`、`Youdao`、`Anthropic` 等其它引擎；`MangaOcr*` 的分割 / 气泡检测整套（PP-OCRv5 后端已内含检测）。

---

## 4. 总体架构

```text
pixez (app)                              packages/translator (纯 Dart, 可 dart test)
┌──────────────────────────┐             ┌────────────────────────────────────────┐
│ lib/translation/         │             │ lib/translator.dart          (导出面)  │
│  image_decode_service    │──ui.Image──▶│  src/model/       text_block, ocr_res   │
│  translation_store (MobX)│             │  src/ocr/         ocr_engine (abstract) │
│  widgets/translation_*   │             │                   mlkit / paddle (注入) │
│  model_download_service  │             │  src/translate/   translator (abstract) │
│  settings (userSetting)  │             │                   hy_mt2_*_policy      │
└──────────────────────────┘             │                   openai_compatible     │
        │ 平台实现注入                    │                   translation_cache     │
        ▼                                │  src/engine/      llm_engine_host       │
android/ ios/  (ML Kit / ONNX)           │                   inference_queue       │
                                         │  src/geometry/    rect_mapper           │
                                         │  src/pipeline/    image_translator      │
                                         │                   text_translator       │
                                         └────────────────────────────────────────┘
```

**分层硬约束**

1. `packages/translator` **不得** 依赖 `flutter` / `plugin_platform_interface` / `path_provider`，只允许 `dio`（下载）、`crypto`（哈希）、`meta`。目的：无 Flutter 环境也能 `dart test`。
2. `packages/translator` **不得** 引用 `package:pixez/**`（避免循环依赖，便于日后单独提 PR）。
3. 平台相关（ML Kit / ONNX / llama.cpp FFI / 文件路径）全部通过 **接口 + app 侧实现** 注入。
4. UI 状态用 MobX store，业务状态机放 `packages/translator`（纯 Dart，可单测）。

### 4.1 核心接口

```dart
// packages/translator/lib/src/ocr/ocr_engine.dart
abstract class OcrEngine {
  /// 在已解码的位图上识别文本。实现方必须保证不阻塞 Dart 主 Isolate。
  Future<List<TextBlock>> recognize(DecodedImage image, {OcrOptions? options});
  Future<void> close();
}

// packages/translator/lib/src/model/text_block.dart
class TextBlock {
  final String text;
  /// 多边形，坐标系 = 传入 DecodedImage 的像素坐标系，按阅读顺序给出 4 点。
  final List<Offset2D> polygon;
  final double confidence; // 0..1
  final TextOrientation orientation;
  Rect2D get boundingBox; // polygon 的轴对齐外接矩形

  /// 换算到另一坐标系：out = in * scale（x / y 分别缩放）。
  TextBlock scaled(double scaleX, double scaleY);
}

// packages/translator/lib/src/translate/translator.dart
abstract class Translator {
  /// 非流式。空输入返回 null；失败抛 TranslationException。
  Future<String?> translate(String source, TranslateRequest request);

  /// 流式：每次发射「当前累计完整译文」（便于 UI 整体 setText）。
  Stream<String> translateStream(String source, TranslateRequest request);

  /// 批量：返回与 sources 等长列表，失败项用 null 占位，不影响其它项。
  Future<List<String?>> translateBatch(List<String> sources, TranslateRequest request);

  /// 批量 + 完成即回调（用于图片翻译逐块上屏）。
  Future<List<String?>> translateBatchIncremental(
    List<String> sources,
    TranslateRequest request,
    void Function(int index, String? text) onUpdate,
  );

  Future<TestResult> testConnection(TranslateRequest request);
  Future<void> dispose();
}
```

### 4.2 数据流

```text
图片翻译：
  URL ──(pixivCacheManager / DioCacheManager + Hoster.header)──▶ bytes(原始文件)
      ──(ui.instantiateImageCodec(targetWidth|targetHeight))──▶ frame
      ──(toByteData)──▶ Uint8List(PNG) + 解码尺寸   ← 立刻 dispose frame/image
      ──(OcrEngine.recognize)──▶ List<TextBlock>    ← 坐标系 = 解码像素
      ──(RectMapper: × scaleX/scaleY)──▶ List<TextBlock>  ← 坐标系 = 原图像素
      ──(translateBatchIncremental)──▶ 逐块译文
      ──(PhotoView.customChild childSize=原图尺寸 + Stack/Positioned)──▶ 覆盖显示

文本翻译（小说）：
  NovelStore.spans (List<NovelSpansData>) ──逐段──▶ translateStream
      ──▶ 累积译文 ──▶ 段落下方插入 / 替换
```

---

## 5. OCR 分辨率策略（用户可配置）

### 5.1 定义

```dart
enum OcrResolution {
  low,      // 长边 960  —— 默认
  medium,   // 长边 1600
  high,     // 长边 2400
  original, // 不缩放（null）
}

extension OcrResolutionX on OcrResolution {
  int? get maxLongSide => switch (this) {
    OcrResolution.low => 960,
    OcrResolution.medium => 1600,
    OcrResolution.high => 2400,
    OcrResolution.original => null,
  };

  bool get needsMemoryWarning =>
      this == OcrResolution.high || this == OcrResolution.original;

  /// 返回 (targetWidth, targetHeight)，只填长边，另一维交给解码器等比推导。
  (int?, int?) decodeTarget(int originalWidth, int originalHeight) {
    final maxSide = maxLongSide;
    if (maxSide == null) return (null, null);
    if (originalWidth >= originalHeight) {
      return originalWidth <= maxSide ? (null, null) : (maxSide, null);
    }
    return originalHeight <= maxSide ? (null, null) : (null, maxSide);
  }
}
```

### 5.2 硬性实现要求

1. **禁止「先解全尺寸再缩小」**：把 `targetWidth` / `targetHeight` 传给 `ui.instantiateImageCodec`，让解码阶段就完成缩放（峰值内存 ≈ 目标尺寸 × 4B）。

```dart
final codec = await ui.instantiateImageCodec(
  bytes,
  targetWidth: target.width,  // 二者只给一个，另一个自动等比
  targetHeight: target.height,
);
final frame = await codec.getNextFrame();
final image = frame.image;
final png = await image.toByteData(format: ui.ImageByteFormat.png);
final decodedW = image.width, decodedH = image.height;
image.dispose();  // 关键：取完 PNG 立刻释放，不与 OCR / LLM 争大位图
codec.dispose();
```

2. **缩放比**：`scaleX = originalWidth / decodedWidth`、`scaleY = originalHeight / decodedHeight`（**分别计算**，避免非整数比累积误差）。OCR 文本块坐标乘 `scaleX/scaleY` 回到原图坐标系。
3. **覆盖层与 OCR 分辨率解耦**：覆盖层工作在 **原图像素坐标系**（`PhotoView.customChild(childSize: Size(originW, originH))`），不依赖本次 OCR 使用的分辨率。
4. **用完即释**：OCR 完成后立即释放解码位图；**不得**在 LLM 推理期间同时持有大位图（PNG bytes 用完置空，覆盖层只持有 `List<TextBlock>` 与译文）。
5. **低内存提示**：`high` / `original` 且设备总内存 < 4GB 时弹一次性提示（键 `translation_ocr_high_res_warned`）。Android 读 `/proc/meminfo` 的 `MemTotal`；iOS 不可达时不提示并在 README 说明。
6. **ugoira 排除**：`illusts.type == 'ugoira'` 时不渲染翻译按钮（`lib/page/picture/illust_lighting_page.dart` 已对 ugoira 分流）。

### 5.3 四档设定与预期

| 档位 | 长边 | 适用 | 代价 |
| --- | --- | --- | --- |
| 低 960 | 960 | 默认；大图省内存、解码快 | 小字识别率下降 |
| 中 1600 | 1600 | 漫画对话的精度/速度平衡点 | 中等 |
| 高 2400 | 2400 | 小字 / 密集文本 | 内存与耗时约 2.25× 于中档 |
| 原图 | 原尺寸 | 仅高端设备 | 4000×4000 ≈ 64MB 位图，可能 OOM；必须警告 |

---

## 6. 翻译策略层（移植细节）

### 6.1 Prompt 模板（逐字对齐）

**无背景 / 无术语表**

```text
Translate the following text into {TargetLanguageName}. Note that you should only output the translated result without any additional explanation:
{source}
```

**无背景 / 有术语表**（`should` → `must ONLY`）

```text
Reference the following translations:
{源1} translates to {译1}
{源2} translates to {译2}

Translate the following text into {TargetLanguageName}. Note that you must ONLY output the translated result without any additional explanation:
{source}
```

**有背景**

```text
[Background Information]
Current application: {app}

Previous dialogue:
Source: {前文原文1}
Translation: {前文译文1}

Other text on the current page:
{同页其他原文1}

Please translate the following text into {TargetLanguageName}, taking the provided background information into consideration.
[Source Text]
{source}
```

**判定**：`isBackgroundPrompt(prompt)` = 同时包含 `[Background Information]\n` 与 `[Source Text]\n`。
**去背景重试** = 把 `currentApplication / currentPage / previousFrame` 置空后重新 `build`（术语表保留）。

**语言名表（38 项，官方英文名）**：Chinese、Traditional Chinese、English、Japanese、Korean、French、Portuguese、Spanish、Turkish、Russian、Arabic、Thai、Italian、German、Vietnamese、Malay、Indonesian、Filipino、Hindi、Polish、Czech、Dutch、Khmer、Burmese、Persian、Gujarati、Urdu、Telugu、Marathi、Hebrew、Bengali、Tamil、Ukrainian、Tibetan、Kazakh、Mongolian、Uyghur、Cantonese。

**归一化**：trim 后为空或 `auto` → `zh-CN`；`_` → `-`；`zh-tw|zh-hk|zh-mo|zh-hant → Traditional Chinese`；`zh|zh-cn|zh-sg|zh-hans → Chinese`；其余先查全名、再查主语言、最后退化为原串。

### 6.2 输出校验（9 类拒绝）

| Reason | 触发条件 |
| --- | --- |
| `NATIVE_LINE_LIMIT` | 输出含引擎行数超限哨兵且源文本不含 |
| `MULTI_SECTION_ECHO` | 背景模式下同时出现两个 header，且至少一个源文本里没有 |
| `BACKGROUND_HEADER_ECHO` | 输出出现 `[Background Information]`（或【背景信息】）而源文本没有 |
| `SOURCE_HEADER_ECHO` | 输出出现 `[Source Text]`（或【待翻译文本】）而源文本没有 |
| `TRANSLATION_INSTRUCTION_ECHO` | 输出复读翻译指令句（中英两种模板）而源文本没有 |
| `MULTI_ITEM_OUTPUT` | 列表项数 ≥2 且多于源；或单行源产出 ≥3 行且 > 源行数×2 |
| `UNEXPECTED_ITEM_PREFIX` | 源无列表项，输出首行却是列表项 |
| `PUNCTUATION_SOURCE_EXPANSION` | 源仅标点，输出含字母 / 数字 |
| `SHORT_SOURCE_CONTEXT_EXPANSION` | 源 1–2 码点，输出 > 源×8 + 8 码点 |

**归一化**：`normalizeHarmlessSingleItemPrefix` —— 仅背景模式、源无列表项、输出单行时，剥掉单个列表标记（`^(\d{1,3}[.)、．:：]|[-*•])\s+(.+?)\s*$`），剥离后必须重新通过全部校验才采纳。

**处理策略**：`Rejected` → 用去背景 prompt 重试 1 次；仍拒绝 → 该段置空（保留原文显示）。`Retryable` → 直接用 fallbackText（不缓存）。

### 6.3 生成边界

`maxOutputLines(source, requestHadBackground)`：无背景 → `0`（不限）；有背景 → `源非空行数 + 1`。超限即 `NATIVE_LINE_LIMIT` 拒绝。

### 6.4 流式上屏规则

端侧引擎开启 `bufferGeneratedOutputUntilValidated = true`：**token 先缓冲，全部生成 + 校验通过后才一次性上屏**（避免半截译文或渗透内容闪现）。云端 OpenAI 兼容引擎按 `streamValidated` 决定是否逐 token 上屏（默认缓冲）。

### 6.5 缓存

- 键：`model` | `targetLang.lowercase` | `promptHash` | `sourceHash` | `sourceLen`
- prompt 指纹：`sourceLang={..}|targetLang={..}|maxNewTokens={n}|system={..}|user={..}`
- 容量 256，access-order LRU；**缓存命中也要重跑输出校验**（脏缓存剔除）。
- 开发者选项可禁用缓存。

---

## 7. 端侧引擎生命周期（Isolate 等价实现）

### 7.1 结构

```dart
class LlmEngineHost {
  // 常驻 Isolate，内部持有唯一 Llamafu 实例；消息队列天然串行 == LifecycleGate
  Future<void> prewarm({String source = 'こんにちは', int maxTokens = 1});
  Future<String> generate(String prompt, {required int maxTokens});
  Stream<String> generateStream(String prompt, {required int maxTokens});
  Future<void> touch();   // 每次成功翻译后调用，重置空闲计时
  Future<void> unload();  // cleanUp（释放权重 + KV），Isolate 保留
  Future<void> shutdown();
  Stream<EngineState> get state;
}
```

### 7.2 必须实现的行为（对齐 `LlamaEngineHolder`）

1. **进程内单实例**：权重只加载一份；切换模型先 `unload()` 再 `load()`。
2. **推理强制串行**：Isolate 消息队列串行；并发调用排队而非并发执行。
3. **空闲 5 分钟卸载**：`IDLE_TIMEOUT_MS = 5 * 60 * 1000`；每次 `touch()` 重置；到点校验真实空闲时长（`now - lastUseAt >= timeout`）后 `unload()`；**只 cleanUp 不 destroy**（destroy 后无法再 load）。
4. **预热**：进入图片 / 小说翻译页时 `prewarm()`（短句 + `maxTokens=1`）；已加载则 `touch()` 复用。
5. **Error 态自愈**：加载前检查状态，若上次失败处于 Error，先 `cleanUp()` 再 load。
6. **低内存提示**：权重 ≈1080 MiB + KV（`contextSize=2048` 约 128–256 MiB）。总内存 < 6GB 或可用内存不足时明确提示并建议云端引擎。
7. **日志可验证**：加载 / 卸载必须打日志（`LPrinter.d`）：`perf> llm load kind=.. loadMs=.. fileMb=..`、`perf> llm idle 300123ms, unloading`、`perf> llm unloaded`。验收 A2 以日志为准。

### 7.3 批量翻译（llamafu 无原生多序列）

按段落顺序 **串行循环**，每段独立 prompt、共享同一次模型加载；命中缓存直接回填不推理；每段完成后立即 `onUpdate(index, text)` 逐块上屏；单段失败置 null 不中断后续。

---

## 8. UI 集成

### 8.1 图片查看页 —— 图片翻译

**落点**：`lib/page/zoom/photo_zoom_page.dart`（移动端 Material，`PhotoView` / `PhotoViewGallery`）。

- 底部工具栏新增「翻译」按钮（`Icons.translate`），`illusts.type == 'ugoira'` 时隐藏。
- 流程：按钮转 loading → `ImageDecodeService.decode(url, resolution)` → `OcrEngine.recognize` → `translateBatchIncremental` → 逐块贴出。
- **覆盖层（关键）**：`photo_view 0.15.0` 已确认支持 `PhotoView.customChild(child:, childSize:)` 与 `PhotoViewGalleryPageOptions.customChild(...)`：

```dart
PhotoView.customChild(
  childSize: Size(originalWidth.toDouble(), originalHeight.toDouble()),
  initialScale: PhotoViewComputedScale.contained,
  child: Stack(children: [
    Image(image: PixivProvider.url(url), fit: BoxFit.fill),
    for (final b in blocks)
      Positioned(
        left: b.boundingBox.left,
        top: b.boundingBox.top,
        width: b.boundingBox.width,
        height: b.boundingBox.height,
        child: IgnorePointer(child: TranslationBlockView(block: b)),
      ),
  ]),
)
```

  `childSize` 固定为**原图尺寸**，覆盖层坐标即原图坐标 → 缩放 / 平移跟随 PhotoView 变换，与 OCR 分辨率完全解耦；`IgnorePointer` 保证手势不被拦截。

- 译文块样式：圆角 8、背景 `Colors.black.withValues(alpha: 0.55)`、白色文字；字号 `clamp(blockHeight * 0.62, 8, 64)`；`maxLines` 由块高 / 行高估算，超出裁剪。
- 交互：底部「译文 / 原文」全局切换；单块点击切换该块；长按显示原文。
- 状态：`TranslatedImageState { idle, decoding, ocr, translating, done, error }` + 进度（已译块数 / 总块数）。

### 8.2 小说阅读页 —— 段落流式翻译

**落点**：`lib/page/novel/viewer/novel_viewer.dart`、`novel_store.dart`。

- `AppBar` 增加翻译开关（`IconButton(Icons.translate)`），状态存 `TranslationStore`（不持久化）。
- 段落来自 `_novelStore.spans`（`List<NovelSpansData>`，仅 `NovelSpansType.normal` 参与，其它跳过）。
- 逐段 `translateStream` 累积上屏；`onUpdate(index, text)` 更新对应段落。
- 显示模式：`对照`（原文 + 译文）/ `仅译文`，AppBar 切换。
- 进入页面 `prewarm()`；`dispose` 不主动卸载（交给 5 分钟空闲）。
- 结果按 `novelId + spanIndex + 目标语言` 记入内存缓存。

### 8.3 caption 翻译

**落点**：`lib/page/picture/illust_detail_content.dart` → `_buildCaptionArea`。

- caption 卡片右上角加翻译图标；点击原地展开译文区（沿用 `SelectableHtml` 渲染，只读）；再次点击折叠。

### 8.4 评论翻译

**落点**：`lib/page/comment/comment_page.dart` → `_buildCommentContent` / `_buildTrailingRow`。

- 每条评论 trailing 行（`reply` / `ban` / `report` 旁）加翻译入口。
- 点击：原地把该条 `CommentEmojiText` 替换为译文，并显示「原文」小按钮切回。

### 8.5 设置页

**落点**：`lib/page/hello/setting/setting_page.dart`（`app_data` 项后插入「翻译」入口）→ 新页面 `lib/page/hello/setting/setting_translate_page.dart`。

| 分组 | 项 | 类型 | 默认 |
| --- | --- | --- | --- |
| 引擎 | 翻译引擎 | 端侧 LLM / 云端 OpenAI 兼容 | 端侧 |
| 引擎 | 端侧模型状态 | 已安装 / 未安装（下载入口） | — |
| 语言 | 目标语言 | 列表（38 项官方名） | 跟随系统 → zh-CN |
| 语言 | 源语言 | 自动 / 指定 | 自动 |
| **OCR** | **OCR 分辨率** | **低 960 / 中 1600 / 高 2400 / 原图** | **低** |
| OCR | OCR 引擎 | ML Kit / Paddle（可选） | ML Kit |
| 模型 | 模型下载管理 | 进度 / 暂停 / 删除 / 导入本地 GGUF | — |
| 模型 | 下载源 | huggingface.co / hf-mirror.com / 自定义 URL | hf-mirror |
| 云端 | baseURL / key / model | 文本输入（key 用密码框） | 空 |
| 云端 | 测试连接 | 按钮 → 结果提示 | — |
| 上下文 | 使用同页上下文 | 开关 | 开（图片） |
| 上下文 | 术语表 | 多行编辑（`源=译` 每行一条） | 空 |
| 缓存 | 启用译文缓存 | 开关 | 开 |
| 缓存 | 清除缓存 | 按钮 | — |

`high` / `original` 首次选择弹一次性提示（`translation_ocr_high_res_warned`）。

### 8.6 国际化

新增字符串 **必须同时** 写入 `lib/l10n/intl_en_US.arb` 与 `lib/l10n/intl_zh_CN.arb`（当前各 354 键，保持键集一致）。生成物 `lib/src/generated/i18n/` 已被 `.gitignore` 忽略，需 `flutter gen-l10n`。

新增键（37 条，沿用现有 snake_case 风格）：

```text
translation, translation_engine, translation_engine_local, translation_engine_cloud,
translation_target_language, translation_source_language, translation_auto,
translation_ocr_resolution, translation_ocr_low, translation_ocr_medium,
translation_ocr_high, translation_ocr_original, translation_ocr_high_warning,
translation_ocr_engine,
translation_model_download, translation_model_installed, translation_model_missing,
translation_model_size, translation_model_downloading, translation_model_delete,
translation_model_import, translation_model_mirror, translation_model_mirror_custom,
translation_cloud_base_url, translation_cloud_api_key, translation_cloud_model,
translation_test_connection, translation_context_enabled, translation_glossary,
translation_cache_enable, translation_cache_clear,
translation_show_source, translation_show_translation, translation_translating,
translation_failed, translation_no_text_found, translation_not_supported_ugoira
```

---

## 9. 模型下载与校验

### 9.1 模型清单

| 字段 | 值 |
| --- | --- |
| 仓库 | `tencent/Hy-MT2-1.8B-GGUF` |
| 文件 | `Hy-MT2-1.8B-Q4_K_M.gguf` |
| 体积 | `1,133,080,448` B（≈1080 MiB） |
| HF 直链 | `https://huggingface.co/tencent/Hy-MT2-1.8B-GGUF/resolve/main/Hy-MT2-1.8B-Q4_K_M.gguf` |
| 镜像 | `https://hf-mirror.com/tencent/Hy-MT2-1.8B-GGUF/resolve/main/Hy-MT2-1.8B-Q4_K_M.gguf` |
| 落盘 | `<appDocuments>/models/llm/Hy-MT2-1.8B-Q4_K_M.gguf`（临时 `.tmp`） |
| 许可证 | 以 HF 仓库 `LICENSE.txt` 为准；下载页需展示来源与许可 |

### 9.2 下载实现（dio）

1. **断点续传**：先取 `Content-Length`；若 `.tmp` 存在则 `Range: bytes={tmpLen}-`；`206` 追加写，`200` 覆盖写。
2. **重定向**：HF `resolve` 会 302 到 CDN，需 `followRedirects: true` + `maxRedirects >= 8`。
3. **进度**：`ResponseType.stream` 累积计数，节流 1MiB 上报，回报 `(downloaded, total, speedBps)`。
4. **取消**：`CancelToken`；取消后保留 `.tmp` 以便续传。
5. **镜像回退**：所选源失败（非取消）→ 提示并允许切另一个源；**不自动静默切换**（让用户知道哪个源挂了）。
6. **校验（必须）**：
   - 前 4 字节 == `GGUF`（0x47 0x47 0x55 0x46）；
   - 文件长度 ≥ `max(4 MiB, 1133080448 × 80%)` = `906,464,358` B；
   - 通过后 `rename` 为正式文件名；失败删除 `.tmp` 并报错。
7. **本地导入**：`file_picker` 选 `.gguf` → 复制到模型目录 → 同一校验 → 提示结果。
8. **删除**：同时删正式文件与 `.tmp`。
9. **不硬编码任何密钥**；HF 公开仓库无需 token（如需，走设置页输入字段，且不写日志）。

---

## 10. 风险与缓解

| ID | 风险 | 影响 | 缓解 |
| --- | --- | --- | --- |
| R1 | `llamafu` pub 包无预编译 `.so`、无 `llama.cpp` 子模块，Android 构建 CMake 直接 FATAL | 端侧引擎**开箱不可用** | **Phase 3 首日 spike**：① 在 `android/` 建 `third_party/llama.cpp` 并注入 `LLAMA_CPP_DIR`（体积 / 构建时长增加）；② 改用 `llama_cpp_dart`（同样需 vendor，Android CMake 更完整）；③ 端侧后端用 `--dart-define=TRANSLATOR_LOCAL_LLM=0` 编译期关闭，先交付 OCR + 云端。**默认走 ③ 保底 + ① 尽力** |
| R2 | iOS 端 1080 MiB 权重 + KV，易触 jetsam | iOS 崩溃 | iOS 默认只允许云端引擎；若启用端侧，`contextSize=1024` + 明确提示，并在 README 记为已知限制 |
| R3 | ML Kit 日文竖排 / 漫画字体识别率不稳 | 译文错位或漏块 | 保留 PP-OCRv5 第二引擎；OCR 结果为空时提示「未识别到文字」；UI 允许切档重试 |
| R4 | 本机仅有 Flutter 3.32.5，项目要求 3.47.0+ | 无法 `flutter analyze` / 构建 / 验收 | 装 Flutter 3.47.x（走代理）后再进 Phase 0；纯 Dart 部分可先用 Dart 3.8.1 跑 `dart test`（包约束放宽到 `>=3.8.0`） |
| R5 | 解码 + OCR 峰值内存 | OOM（尤其「原图」档） | 解码即缩放、位图用完即 `dispose`、PNG bytes 用完置空、文档与 UI 双重警告 |
| R6 | 主线程卡顿 | 违反性能红线 | OCR 走原生线程、LLM 走 Isolate、解码走引擎线程；覆盖层用 `RepaintBoundary` 隔离；Phase 7 用 `--profile` + `--trace-skia` 验证 |
| R7 | 输出「上下文渗透」污染译文 | 体验崩坏 | 完整移植 9 类校验 + 去背景重试 + 失败置空（宁可显示原文） |
| R8 | 与 GPL-3.0 冲突的依赖 | 许可问题 | **禁用** `flutter_llama`（NONC）；`llamafu` / `llama_cpp_dart`（MIT）兼容 |
| R9 | l10n 生成物未入库 | `I18n.of(context).translation` 编译失败 | 改完 arb 必须跑 `flutter gen-l10n`；CI 需补该步骤 |
| R10 | MobX store 需 codegen | 编译失败 | 新增 `.g.dart` 走 `dart run build_runner build`（CI 已跑） |

---

## 11. 分阶段任务（每阶段独立可验收）

### Phase 0 · 骨架与基线（0.5 天）
- 新建 `packages/translator/`：`pubspec.yaml`（`sdk: '>=3.8.0 <4.0.0'`，依赖仅 `dio` / `crypto` / `meta`）、`analysis_options.yaml`、`lib/translator.dart`、`README.md`。
- 骨架文件（空实现 + TODO）：`model/text_block.dart`、`model/ocr_resolution.dart`、`ocr/ocr_engine.dart`、`translate/translator.dart`。
- **验收**：`cd packages/translator && dart pub get && dart analyze` 无 error。

### Phase 1 · 策略层移植（1 天）
- `hy_mt2_prompt_policy.dart` / `hy_mt2_output_policy.dart` / `hy_mt2_generation_boundary_policy.dart` / `cache_key.dart` / `translation_cache.dart`。
- 测试：`test/hy_mt2_prompt_policy_test.dart`、`test/hy_mt2_output_policy_test.dart`、`test/hy_mt2_generation_boundary_policy_test.dart`、`test/cache_key_test.dart`、`test/translation_cache_test.dart`。
- **验收**：`dart test` 全绿；覆盖 38 语言名、auto 归一、术语表前缀、背景三段、去背景、9 类拒绝各 1 例、单行列表符归一化、行数上限、缓存键等价性与命中。

### Phase 2 · OCR 与几何（1.5 天）
- `model/ocr_resolution.dart`（四档 + `decodeTarget`）、`geometry/rect_mapper.dart`（`scaleX/scaleY` 换算）、`ocr/mlkit_ocr_engine.dart`（app 侧注入）、`ocr/paddle_ocr_engine.dart`（可选）。
- 测试：`test/ocr_resolution_test.dart`（960/1600/2400/原图 × 横竖图矩阵）、`test/rect_mapper_test.dart`（四档换算回原图后误差 = 0）。
- **验收**：单测通过；同一图片四档 OCR 文本块换算回原图坐标一致（离线 fixture 断言）。

### Phase 3 · 端侧引擎（2 天，含 R1 spike）
- 首日 spike：llamafu 在 Android 上能否构建 / 加载（结论写入 README「已知限制」）。
- `engine/llm_engine_host.dart`（Isolate 常驻 + 队列 + 5 分钟空闲卸载 + prewarm + Error 自愈 + 日志）、`engine/prewarm_policy.dart`、`engine/inference_queue.dart`。
- `translate/local_llama_translator.dart`（校验 / 重试 / 缓存 / 批量串联）。
- `translate/openai_compatible_translator.dart`（SSE 流式、超时、错误映射、`testConnection`）。
- 测试：`test/local_llama_translator_test.dart`（Fake Engine 验证：拒绝→去背景重试→仍拒绝置空；缓存命中不触发推理；批量顺序与 null 占位）、`test/openai_sse_test.dart`。
- **验收**：`dart test` 全绿；Fake 引擎下批量 10 段全部回调且顺序正确；空闲计时（可注入时钟）验证 5 分钟触发一次 `unload`。

### Phase 4 · 图片翻译 UI（2 天）
- `lib/translation/image_decode_service.dart`（按档解码 + 立即 dispose）、`lib/translation/translation_store.dart`（MobX，`.g.dart` 生成）、`lib/translation/widgets/translation_overlay.dart`、`lib/translation/widgets/translation_block_view.dart`。
- 改 `lib/page/zoom/photo_zoom_page.dart`：翻译按钮 + `customChild` 覆盖层 + 译文/原文切换 + 长按看原文。
- **验收**：真机断网 + 模型已下载，一张含日文对话的漫画图完成 OCR→翻译→覆盖显示；四档切换后文本块均对齐；ugoira 页无翻译按钮。

### Phase 5 · 文本翻译 UI（2 天）
- 小说页开关 + 逐段流式 + 对照 / 仅译文；caption 翻译；评论翻译。
- **验收**：段落流式出现；退出页面 5 分钟后日志出现 `perf> llm idle ... unloading` 与 `perf> llm unloaded`；caption / 评论可译可回原文。

### Phase 6 · 设置页 + 模型下载（1.5 天）
- `lib/page/hello/setting/setting_translate_page.dart`（全部设置项）、`lib/translation/model_download_service.dart`、`lib/store/user_setting.dart` 新键与 setter、`lib/l10n/intl_{en_US,zh_CN}.arb` 37 键。
- **验收**：1080MiB 模型可断点续传（中途杀进程后继续）；删除 / 导入 / 校验（截断文件被拒）通过；「高 / 原图」提示仅弹一次。

### Phase 7 · 测试 / 文档 / 验收（1 天）
- 补 README（见第 14 节）；跑 `dart test`、`flutter analyze`、`flutter build apk --release`；记录性能数据。

---

## 12. 许可证与代码规范

- 每个新增 `.dart` 文件首行加与仓库一致的 GPL-3.0 header（复制 `lib/page/novel/viewer/novel_store.dart` 头部）。
- `packages/translator/LICENSE` 沿用 GPL-3.0 文本（复制仓库根 `LICENSE`）。
- 注释用中文（与仓库既有风格一致）。
- 不硬编码任何密钥；API key 仅存 `SharedPreferences`，日志禁止打印。
- `flutter analyze` 保持仓库现有基线（`analysis_options.yaml` 目前为空 = 默认 lint）。

---

## 13. 待确认决策（回复后开工）

| # | 决策 | 选项 | 默认建议 |
| --- | --- | --- | --- |
| D1 | llama.cpp 原生库来源（R1） | A. vendor `llama.cpp` 进 `android/` + 注入 `LLAMA_CPP_DIR`；B. 仅 CI 注入；C. 端侧后端编译期关闭，先交付 OCR + 云端 | **C 保底 + A 尽力** |
| D2 | 是否安装 Flutter 3.47+（R4） | 安装（可真正跑 analyze / build）/ 不装（只交付代码 + 纯 Dart 单测） | **安装** |
| D3 | 桌面 Fluent 树是否同步 | 同步 / 仅移动端 | **仅移动端** |
| D4 | 第二 OCR 引擎（PP-OCRv5） | Phase 2 一起接 / 留接口后补 | **留接口后补** |

---

## 14. README 补充内容（Phase 7 交付）

1. **功能说明**：图片翻译、小说 / 标题 / 评论翻译、离线可用、分辨率四档。
2. **模型来源与体积**：`tencent/Hy-MT2-1.8B-GGUF` / Q4_K_M / 1,133,080,448 B / 许可证与直链、镜像说明。
3. **OCR 分辨率选项说明**：四档精度-内存-速度取舍表（见第 5.3 节）。
4. **已知限制**：
   - iOS 内存（1080MiB 权重 + KV，建议云端）；
   - 低端机降级（「原图」档 OOM 风险；内存 <4GB 一次性警告）；
   - ML Kit 竖排漫画识别率有限，可切 PP-OCRv5；
   - 端侧后端依赖 llama.cpp 构建（若走 R1-C 则说明默认关闭）；
   - 首次翻译需下载模型（约 1.1GB），建议 WiFi。

---

## 15. 验收标准 → 验证方式

| # | 验收标准（原始） | 验证方式 |
| --- | --- | --- |
| A1 | 断网下，下载模型后一张含日文对话漫画图 OCR + 翻译全流程可用 | 飞行模式 + 已下载模型，人工走查并留存截图 |
| A2 | 小说段落流式翻译，退出 5 分钟后引擎自动卸载（日志可验证） | `adb logcat` 抓 `perf> llm idle ... unloading` / `llm unloaded`，时间差 ≥300s |
| A3 | 切换 OCR 分辨率后同一图文本块坐标均正确对齐 | 四档各跑一次截图比对 + `rect_mapper_test` 单测（换算误差 0） |
| A4 | 「低」档 4000×4000 原图翻译无卡顿（主线程无 >16ms 帧超限） | `flutter run --profile` + `--trace-skia` / DevTools Frame Chart，jank 帧数 ≈ 0 |
| A5 | 云端模式不下载模型也能工作 | 清空模型目录 + 填云端配置 → 图片 / 文本翻译均成功 |
| A6 | 单元测试通过，Android release 构建成功 | `dart test`（translator 包）+ `flutter build apk --release` |

**补充质量门**

- `dart analyze packages/translator` 0 error；
- 新增代码无 `print`（统一用 `LPrinter`）；
- 覆盖层在四档重跑不残留旧块（状态清理单测）。

---

## 16. 文件写入清单

**新增**

```text
packages/translator/pubspec.yaml
packages/translator/analysis_options.yaml
packages/translator/README.md
packages/translator/LICENSE
packages/translator/lib/translator.dart
packages/translator/lib/src/model/text_block.dart
packages/translator/lib/src/model/ocr_resolution.dart
packages/translator/lib/src/model/translate_request.dart
packages/translator/lib/src/ocr/ocr_engine.dart
packages/translator/lib/src/ocr/mlkit_ocr_engine.dart
packages/translator/lib/src/ocr/paddle_ocr_engine.dart          (可选, D4)
packages/translator/lib/src/translate/translator.dart
packages/translator/lib/src/translate/hy_mt2_prompt_policy.dart
packages/translator/lib/src/translate/hy_mt2_output_policy.dart
packages/translator/lib/src/translate/hy_mt2_generation_boundary_policy.dart
packages/translator/lib/src/translate/hy_mt2_profile.dart
packages/translator/lib/src/translate/local_llama_translator.dart
packages/translator/lib/src/translate/openai_compatible_translator.dart
packages/translator/lib/src/translate/cache_key.dart
packages/translator/lib/src/translate/translation_cache.dart
packages/translator/lib/src/engine/llm_engine_host.dart
packages/translator/lib/src/engine/inference_queue.dart
packages/translator/lib/src/engine/prewarm_policy.dart
packages/translator/lib/src/geometry/rect_mapper.dart
packages/translator/lib/src/model/model_installer.dart
packages/translator/lib/src/pipeline/image_translator.dart
packages/translator/lib/src/pipeline/text_translator.dart
packages/translator/test/*.dart                         (8 个测试文件)
lib/translation/image_decode_service.dart
lib/translation/translation_store.dart
lib/translation/translation_store.g.dart               (build_runner 生成)
lib/translation/model_download_service.dart
lib/translation/widgets/translation_overlay.dart
lib/translation/widgets/translation_block_view.dart
lib/page/hello/setting/setting_translate_page.dart
docs/translation-feature-spec.md                       (本文档)
```

**修改**

```text
pubspec.yaml                                   (+ translator 路径依赖; + mlkit 等)
lib/page/zoom/photo_zoom_page.dart             (+ 翻译按钮与覆盖层)
lib/page/novel/viewer/novel_viewer.dart        (+ 翻译开关与逐段流式)
lib/page/novel/viewer/novel_store.dart         (+ 译文状态, 可选)
lib/page/picture/illust_detail_content.dart    (+ caption 翻译入口)
lib/page/comment/comment_page.dart             (+ 评论翻译入口)
lib/page/hello/setting/setting_page.dart       (+ 「翻译」入口项)
lib/store/user_setting.dart                    (+ 设置键与 setter)
lib/l10n/intl_en_US.arb                        (+ 37 键)
lib/l10n/intl_zh_CN.arb                        (+ 37 键)
README.md                                      (+ 第 14 节内容)
android/app/build.gradle.kts                   (仅当 D1 选 A/B)
```

---

## 17. 新增持久化键（SharedPreferences）

| 键 | 类型 | 默认 |
| --- | --- | --- |
| `translation_engine` | int (0=local,1=cloud) | 0 |
| `translation_target_lang` | String | "auto" |
| `translation_source_lang` | String | "auto" |
| `translation_ocr_resolution` | int (0..3) | 0 (low) |
| `translation_ocr_engine` | int (0=mlkit,1=paddle) | 0 |
| `translation_ocr_high_res_warned` | bool | false |
| `translation_model_mirror` | int (0=hf,1=mirror,2=custom) | 1 |
| `translation_model_mirror_url` | String | "" |
| `translation_cloud_base_url` | String | "" |
| `translation_cloud_api_key` | String | "" |
| `translation_cloud_model` | String | "" |
| `translation_context_enabled` | bool | true |
| `translation_glossary` | String（`源=译` 换行分隔） | "" |
| `translation_cache_enable` | bool | true |

---

## 18. 时间估算

| 阶段 | 估时 |
| --- | --- |
| Phase 0 骨架 | 0.5 天 |
| Phase 1 策略层 | 1 天 |
| Phase 2 OCR / 几何 | 1.5 天 |
| Phase 3 端侧引擎 | 2 天 |
| Phase 4 图片翻译 UI | 2 天 |
| Phase 5 文本翻译 UI | 2 天 |
| Phase 6 设置页 / 下载 | 1.5 天 |
| Phase 7 测试 / 文档 / 构建 | 1 天 |
| **合计** | **约 11.5 天**（不含装 SDK 与 R1 spike 的不可控延迟） |
