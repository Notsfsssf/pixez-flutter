<img src="./android/app/src/main/res/mipmap-xxhdpi/ic_launcher_round.png" alt="logo" width="144" height="144" align="right" />

# PixEz Flutter ![](https://camo.githubusercontent.com/f2b4fa6779c8a4825e0e7347076746a2047ed100/68747470733a2f2f696d672e736869656c64732e696f2f62616467652f6c6963656e73652d47504c2d2d332e302d6f72616e67652e737667)

[English README Here](./.github/README_en.md)<br />
[README Bahasa Indonesia klik disini](./.github/README_id.md)

使用 Flutter 编写的 pixiv 第三方客户端。

同样支持中国大陆地区直连。

🎵 Mili - In Hell We Live, Lament 🎵 

# 下载

推荐渠道顺序为从左到右。

|系统|应用市场|GitHub|云盘|
|:---:|:---:|:---:|:---:|
|Android|[Google Play](https://play.google.com/store/apps/details?id=com.perol.play.pixez)|[Release](https://github.com/Notsfsssf/pixez-flutter/releases/latest)|[蓝奏云](https://wwa.lanzoui.com/b0ded45id)<br />**临时，不推荐**|
|iOS|[App Store(美区)](https://apps.apple.com/us/app/pixez/id1494435126)|[Action Ipa](https://github.com/Notsfsssf/pixez-flutter/actions/workflows/build_ios.yml)|/|
|Windows|/|[Nightly MSIX](https://github.com/Notsfsssf/pixez-flutter/actions/workflows/build_windows.yml)|/|

# 预览

|![Preview](./.github/preview/2.jpg) | ![Preview](./.github/preview/1.jpg) | 
|:-------------------:|:------------------------:|

# 关于项目 / About Repository

如你所见，Flutter 是一个能够帮助开发者快速开发界面的框架。

拥有的 Hot Reload 热重载，可以极大缩减 debug 成本，所见即所得，快速交流；

利用 PlatformChannel，可以为不同平台编写不同的平台特性的独有功能；

应用使用了 `mobx`，`flutter_bloc` (逐步弃用)，`provider` 进行状态管理，`custompainter` 来播放 ugoira。

# 翻译功能 / Translation

内置端侧 / 云端双引擎的图片与文本翻译（纯 Dart 核心在 [`packages/translator`](./packages/translator)，规格见 `docs/translation-feature-spec.md`）：

- **图片翻译**：图片查看页点击翻译按钮，端侧 OCR（ML Kit，日 / 中文）识别文本块后由 LLM 翻译，译文以覆盖层贴回原图位置，支持整图译文与单块原文切换。
- **文本翻译**：小说阅读页段落流式翻译（逐段上屏 / 对照模式），以及作品 caption 与评论区单段翻译。
- **离线可用**：选择端侧引擎并下载模型后，断网状态下图片 / 文本翻译均可工作。
- **OCR 分辨率四档**（设置 → 翻译）：见下表，默认「低 960」。

| 档位 | 长边 | 适用 | 代价 |
| --- | --- | --- | --- |
| 低 960 | 960 | 默认；大图省内存、解码快 | 小字识别率下降 |
| 中 1600 | 1600 | 漫画对话的精度 / 速度平衡点 | 中等 |
| 高 2400 | 2400 | 小字 / 密集文本 | 内存与耗时约 2.25× 于中档 |
| 原图 | 原尺寸 | 仅高端设备 | 4000×4000 ≈ 64MB 位图，可能 OOM |

**端侧模型**：[tencent/Hy-MT2-1.8B-GGUF](https://huggingface.co/tencent/Hy-MT2-1.8B-GGUF)（`Hy-MT2-1.8B-Q4_K_M.gguf`，1,133,080,448 B ≈ 1080 MiB），许可证以该仓库 `LICENSE.txt` 为准；国内可在设置中切换 hf-mirror.com 镜像或自定义 URL 下载（支持断点续传，首次翻译前需下载约 1.1GB，建议 WiFi）。云引擎走任意 OpenAI 兼容接口，无需下载模型。

## 已知限制

- **端侧推理后端默认关闭**：依赖 llama.cpp 原生构建（Android CMake / iOS），当前发布版以 `--dart-define=TRANSLATOR_LOCAL_LLM=0` 编译期关闭（规格 R1-D1-C 保底），端侧引擎选择后不可用，请使用云端引擎；启用需自行 vendor llama.cpp 并以 `=1` 构建。
- **iOS 内存**：1080MiB 权重 + KV 缓存易触发 jetsam，建议 iOS 使用云端引擎。
- **低端设备**：「高 2400」/「原图」档有 OOM 风险（首次选择有一次性警告）；设备总内存 < 4GB 时请使用低 / 中档（iOS 无法读取总内存，不弹该提示）。
- **漫画 OCR 识别率**：ML Kit 对竖排文字 / 漫画字体识别率有限，可切档重试；PP-OCRv5 第二引擎为预留接口、待接入。
- 首次翻译需下载模型（约 1.1GB），建议 WiFi。

## 贡献 / Contribute

本项目目前的贡献者列表如下：

<table>
  <tr>
    <td align="center"><a href="https://github.com/Notsfsssf"><img src="https://avatars3.githubusercontent.com/u/16934707?v=4" width="100px;" alt=""/><br /><sub><b>Perol_Notsfsssf</b></sub></a><br /><a href="https://github.com/Skimige/pixez-flutter/commits?author=Notsfsssf" title="Code">💻</a></td>
    <td align="center"><a href="https://xyx.moe"><img src="https://avatars3.githubusercontent.com/u/9017470?v=4" width="100px;" alt=""/><br /><sub><b>Skimige</b></sub></a><br /><a href="https://github.com/Skimige/pixez-flutter/commits?author=Skimige" title="Documentation">📖</a></td>
    <td align="center"><a href="https://github.com/TragicLifeHu"><img src="https://avatars3.githubusercontent.com/u/16817202?v=4" width="100px;" alt=""/><br /><sub><b>Tragic Life</b></sub></a><br /><a href="#translation-TragicLifeHu" title="Translation">🌍 (zh_TW)</a></td>
    <td align="center"><a href="http://ivtune.net"><img src="https://avatars0.githubusercontent.com/u/54385201?v=4" width="100px;" alt=""/><br /><sub><b>karin722</b></sub></a><br /><a href="#translation-karin722" title="Translation">🌍 (ja)</a></td>
    <td align="center"><a href="http://archman.fun"><img src="https://avatars0.githubusercontent.com/u/68731023?v=4" width="100px;" alt=""/><br /><sub><b>Romani-Archman</b></sub></a><br /><a href="https://github.com/Skimige/pixez-flutter/commits?author=Romani-Archman" title="Documentation">📖</a></td>
    <td align="center"><a href="https://github.com/itzXian"><img src="https://avatars1.githubusercontent.com/u/34748039?v=4" width="100px;" alt=""/><br /><sub><b>Xian</b></sub></a><br /><a href="#translation-itzXian" title="Translation">🌍 (en_US)</a></td>
    <td align="center"><a href="https://github.com/ReikiAigawara"><img src="https://avatars1.githubusercontent.com/u/66962815?v=4" width="100px;" alt=""/><br /><sub><b>Reiki Aigawara</b></sub></a><br /><a href="#translation-ReikiAigawara" title="Translation">🌍 (id_ID)</a></td>
  </tr>
</table>

如果你是有能人士，愿意为本项目贡献代码，请不要犹豫提交 Pull Request 吧！

本应用也使用了 `intl` 进行国际化，欢迎贡献[翻译](lib/l10n/intl_en_US.arb)！

觉得有些地方设计的不妥？同样欢迎分享设计。

## 常见问题及交流反馈

[使用指南 & 常见问题在这里](.github/FAQ.md)，反馈问题 / 加群询问之前请先看！（特别是旧原生版用户）

邮件反馈：PxezFeedback@outlook.com

也可以在 Telegram 群交流反馈：[@PixEzViewer](https://t.me/PixEzChannel)

Discord: [@PixEz](https://discord.gg/Em9AeJbg)

也可以进企鹅群交流经验或者反馈：815791942（闲聊为主）
