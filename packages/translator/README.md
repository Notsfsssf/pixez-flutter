# translator

PixEz 翻译功能的纯 Dart 层（图片翻译 + 文本翻译）。

- **无 Flutter 依赖**：仅 `dio` / `crypto` / `meta`，可用 `dart test` 独立测试。
- **平台能力接口注入**：ML Kit / PP-OCRv5 OCR、llama.cpp FFI、文件路径由 app 侧（`lib/translation/`）实现。
- **许可证**：GPL-3.0（与 PixEz 主仓库一致）。

## 结构

```
lib/
  translator.dart            导出面
  src/
    model/                   TextBlock / OcrResolution / TranslateRequest / 模型安装
    ocr/                     OcrEngine 抽象（实现注入）
    translate/               Translator 抽象、Hy-MT2 策略、端侧 / 云端引擎
    engine/                  端侧 LLM Isolate 宿主、推理队列、预热策略
    geometry/                坐标换算
    pipeline/                图片 / 文本翻译管线
```

## 开发

```bash
cd packages/translator
dart pub get
dart analyze
dart test
```

## 已知限制

- **端侧 LLM 后端默认编译期关闭**（规格 §10 R1-D1-C 保底）：llama.cpp FFI 实现需要
  原生构建（`llamafu` 无预编译 `.so`），当前 app 以 `--dart-define=TRANSLATOR_LOCAL_LLM=0`
  构建；本包的 `LlmGenerationEngine` 抽象、`LlmEngineHost` 生命周期（空闲 5 分钟卸载 /
  串行推理 / Error 自愈）与 `LocalLlamaTranslator` 策略层均已就绪并有单测覆盖，
  接入原生后端只需实现 `LlmGenerationEngine` 注入。
- NFKC 归一化用 Python unicodedata 生成的逐码点映射表近似（`nfkcNormalize`），
  与 ICU 完整实现的差异仅限 combining mark 重排，不影响输出检测语义。
- 翻译缓存为内存 LRU（进程生命周期内有效），未做持久化。
