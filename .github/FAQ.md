<img src="https://raw.githubusercontent.com/Romani-Archman/pixez-flutter/master/android/app/src/main/res/mipmap-xxhdpi/ic_launcher_round.png" alt="logo" width="144" height="144" align="right">

# PixEz Flutter | 使用指南 & 常见问题

如果你在使用过程中遇到了问题，请认真阅读。

## 目录

  * [声明，以及 Pix-EzViewer（旧原生版）](#声明)
  * [如何下载最新版](#如何下载最新版)
  * [无法登录](#登录问题)
  * [怎么全是英文？](#切换语言)
  * [下载图片](#下载图片)
  * [保存路径问题](#下载图片)
  * [保存格式](#保存格式)
  * [我是异形屏](#屏幕问题)
  * [以图搜图](#以图搜图)
  * [我想 GHS](#GHS)
  * [关于直连](#关于直连和令人迷惑的选项)
  * [其他问题](#其他问题)

## 声明

首先需要说明：这是 PixEz（Flutter 版）的 FAQ。

本教程并不是 Pix-Ezviewer（也就是旧原生版）的教程。目前 Pix-Ezviewer 已经停止维护。~~由 [ultranity](https://github.com/ultranity) 继续维护~~也停止维护了，全面转换到 Flutter 版。

如果你正在使用旧的原生版本，并且希望继续使用下去，你应该首先切换到新维护者的版本（需要卸载重装，因为签名变化）。 ~~同时，有关任何的错误回报，你都应当联系新维护者。~~ 如果遇到问题的话，就自求多福吧（

如果你是接手版之前的最后钉子户，由于现在旧版直连早已崩坏，请「不启用直连」之后退出登录，再重新登录。钉子户由于苟延残喘不想迁移新版造成的任何问题，开发者不负责解答哦。

如果你正在使用旧的原生版本，并且希望更换到现在的 Flutter 版，请往下读。

## 如何下载最新版

下载渠道在 [README 页](https://github.com/Notsfsssf/pixez-flutter#%E4%B8%8B%E8%BD%BD) 里已经说明，不过在这里再复读一次吧。

|系统|应用市场|GitHub|云盘|
|:---:|:---:|:---:|:---:|
|Android|[Google Play](https://play.google.com/store/apps/details?id=com.perol.play.pixez)|[Release](https://github.com/Notsfsssf/pixez-flutter/releases)|[蓝奏云](https://wwa.lanzous.com/b0ded45id)<br />**临时，不推荐**|
|iOS|[App Store](https://apps.apple.com/cn/app/pixez/id1494435126)|/|/|

对于国内网络，从 GitHub 下载 APK 可能会有一点困难，但还请尽量这样做（如果不能使用 Google Play 的话）。

## 登录问题

如果你有账号，登录即可。  

如果你没有账号，但是又不想走繁琐的注册流程，则可以点击「没有账号？」，按流程简单操作之后 app 会为你建立一个全新的 pixiv 账号。

**注册后，请到 设置 -> 账户信息 查看你的用户名和密码，以备稍后登录。**

如果你在登录过程中遇到密码错误问题，本教程不会帮你解决。你应当自行打开 pixiv 网站进行相关的密码找回操作。

如果你无法登录，请检查网络是否正常、软件版本是否最新。自查后如仍有问题请联系开发者。

如果你无法登录，并且错误代码为`103`，具体显示为`103:pixiv ID、またはメールアドレス、 パスワードが 正しいかチェックしてください。`。存在两种可能性：

- 账号密码填写错误。
- 如果确认账号密码完全正确，即代表密码可能太简单，无法使用API接口登录，这个是 pixiv 服务端的限制，恕 Pixez 无能为力，请前往官网修改密码为更强密码后再尝试登录。

## 切换语言

如果当前界面全是英文，并且你不会英语，请点击右下角的 Settings 并选择 Preferences，在打开的页面中选择 `zh-CN` 并重新打开本应用便可。

~~（但愿不会发生这种情况）~~

## 下载图片

下载按钮不外显，而是通过长按操作来实现。在主界面瀑布流长按对应插画，会自动下载该插画的所有分 p（如有）；而在插画详情界面长按插画，对于多 p 插画则可手动选择想要下载的分 p。

### 选择储存目录

从即将发布的 Android 11 开始，系统引入了新的存储机制：分区存储。为了更好地适配存储的变化，在 0.1.9 及之后的版本开始，PixEz 开始使用存储访问框架（SAF）来访问文件。这种方式的优点是：存储操作原生化，并且不需要请求敏感的存储权限；当然，缺点也就是需要用户进行手动的目录选择。

（了解更多详情轻点 [国内](https://developer.android.google.cn/training/data-storage/shared/documents-files) 或 [国外](https://developer.android.com/training/data-storage/shared/documents-files)）

**Update!** 为了适应各种魔改而不能正常使用 SAF 的国产系统，新版已经同时支持使用 SAF 模式或传统模式选择存储目录。

如果你使用的魔改系统在使用 SAF 模式时遇到了困难，请使用传统模式（需要存储权限；请放心，本应用不会产生垃圾文件）；如果你有意挣扎（不建议），请打开下面折叠的文本。

<details>
<summary>在被阉割的国产系统中尝试 SAF 模式</summary>

有一个只有国内环境才有的致命问题：部分魔改过度的系统阉割了这个功能。

一般来说，只要你的手机没有阉割系统的「文件」应用（包名为 `com.android.documentsui`），你应该都能在点击「确认」之后正常来到这个应用。

如果很不幸，你的系统阉割了这个应用，你或许可以尝试 [安装](https://cdn.jsdelivr.net/gh/Romani-Archman/mycdn@master/img/DocumentsUI.apk) 一个小工具来曲线救国（仅限 Android 9 以上）。

如果此应用并非被阉割，而只是被停用了，你可以尝试在设置中搜索「文件」应用，在详情中启用应用，或是使用 ADB 来启用（具体步骤请自行百度）。
</details>

我们推荐选择的路径是 `Pictures/PixEz` ，当然一般来说这个路径不会从一开始就存在，所以往往文件夹需要自己来创建。

#### SAF 模式

具体一点的操作方式如下：

1. 点击右上角的三个点，选择「显示内部存储空间 (Show internal storage)」（如果是「隐藏内部存储空间 (Hide internal Storage)」则无需再点选
2. 打开左侧栏，找到你的手机内部存储空间（一般为手机图标 + 手机型号，可用空间 XX GB）
3. 找到 `Pictures` 目录，如果你还没有 `PixEz` 目录则从右上角的三个点中选择「新建文件夹」
进入刚建立的 `PixEz` 目录，点击下面的「选择」

注意，保存路径不能包含 `Download` (下载)目录，所以最好选择 `Pictures/PixEz` 路径。

另外，**请不要删除这个文件夹**（主动删除或使用空文件夹清理等功能误删）——删除之后，应用本身没有再次创建文件夹的权限，会导致之后保存图片失败。解决方法也很简单，重新建立文件夹即可。

|![Preview](https://cdn.jsdelivr.net/gh/Romani-Archman/mycdn@1.3/img/1.jpg) | ![Preview](https://cdn.jsdelivr.net/gh/Romani-Archman/mycdn@1.3/img/2.jpg) | ![Preview](https://cdn.jsdelivr.net/gh/Romani-Archman/mycdn@1.3/img/3.jpg) | ![Preview](https://cdn.jsdelivr.net/gh/Romani-Archman/mycdn@1.3/img/4.jpg) | ![Preview](https://cdn.jsdelivr.net/gh/Romani-Archman/mycdn@1.3/img/5.jpg) |
|:---:|:---:|:---:|:---:|:---:|

#### 传统模式

我们同样推荐选择保存在 `Pictures/PixEz` （完整路径可能是 `/storage/emulated/0/Pictures/PixEz`）下。

你可以点击右上角的图标来创建文件夹，点击最上面的 `↑ ...` 来返回上一层，最后记得右下角确认。

### 修改路径

如果后期你想修改保存路径，在设置页面中点击偏好设置 - 平台特殊设置，点击「保存路径」重新选择即可。

### 动图

动图的播放按钮在详情页图片下方，点击之后便会开始获取动图内容并加载播放。

动图的保存一样是长按，此时会提示是否合成动图。开始时会有 toast 提示（encoding），结束时同样有 toast 提示（encode success）。

## 保存格式

在设置页面中点击偏好设置 - 平台特殊设置，便可以看到「保存格式」选项，可以参考下面的参数来修改保存名称。

e.g. {illust_id}_p{part} 即「插画ID\_p第几张」

## 屏幕问题

如果是异形屏的话，在设置 - 偏好设置里勾选「异形屏」即可。此时在详情界面，插画不会被铺到状态栏。

（但愿你们不会专门来看这个问题）

## 以图搜图

目前的版本中，以图搜图在设置页面的右上角🔍中；以后可能会移动到搜索页面 - 点击🔍，再点击右下角浮动按钮的位置……（放到搜索的大类下面才更加正常不是吗.jpg）

## GHS

~~你就那么想 GHS 么！~~

如果一张图你看不了，可能有这么些情况：

### 原画师把图删了 / 设为隐藏了

这种情况，我们表示爱莫能助… 建议利用搜索引擎的快照等尝试恢复。

### 图是 R18 的，但是你账号没开查看 R18

例如这样：

![Preview](https://github.com/Notsfsssf/pixez-flutter/raw/master/.github/Not-Unlocked.jpg)

请这样操作：

在 网页端（电脑或手机）登录 pixiv，找到「用户设置」-「浏览限制」，将「限制浏览的作品（R-18）」改为「显示作品」，保存设置。

随后开启本应用设置 - 偏好设置中「H是可以的! (‾﹃‾)」（这会移除小图为 R18 时用于替代小图的「H是不行的」表情包），就可以啦。

## 关于直连和令人迷惑的选项

本应用所实现的在墙娘法力范围内直连 pixiv，**并非是使用 / 内置了代理**，而是使用了小技巧瞒天过海躲过了墙娘的 SNI 嗅探。

不过，受限于运营商等因素，直连的速度可能会比较慢，同时也有一部分自备梯子的同学想关闭直连。

关闭直连这样操作即可：请开启本应用设置 - 偏好设置中「不要绕过 SNI 嗅探」，就可以关闭直连啦，同时可以小小加快启动速度。

对于这个选项的解释：字面意思，打开为不绕过（即需要科学上网，关闭内置直连魔法），关闭为绕过（默认状态，启用内置魔法）。

## 其他问题

大多数选项都在设置中，建议汝仔细去找而不是什么问题都去问咱。

### 上架又下架是怎么一回事儿？

简单的来说，就是 Play 不知道发了什么神经下架了原生版之后，又在 Flutter 版上架之后将 Flutter 版下架。嘛，虽然现在历经波折，Flutter 版还是在 Play 上架了！

### 更多别的问题

如果你有什么好的建议，可以提 Issue，或者去 [README](https://github.com/Notsfsssf/pixez-flutter) 中提到的 Telegram 群组里反馈。如果是下载问题，就去企鹅群：1005400557

提问前最好阅读[《提问的智慧》](http://archman.fun/2020/09/24/%E6%8F%90%E9%97%AE%E7%9A%84%E6%99%BA%E6%85%A7/)，拒绝 TCP 三次握手式提问，以及 DDoS 式轰炸提问。大多数群员都是友好的，希望你也能同样友好，互相理解最好啦。

## iOS开发编译问题

### 问题1

`Target of URI hasn't been generated: '****.g.dart'.Try running the generator that will generate the file referenced by the URI.`

这个项目使用的是`json_serializable`进行json转model，所以项目拉取下来后，需要自己执行一下命令行：

```shell
flutter pub get 
flutter pub upgrade
flutter pub upgrade --major-versions
flutter pub run build_runner build --delete-conflicting-outputs
```

### 问题2

`AppLocalization class not found when trying to run the app flutter`

这个问题，我处理起来比较简单，直接关闭VSCode，然后再打开即可。

`After that, I tried to close my IDE(Android studio) and open it again, and the issue was cleared!`

[Stack Overflow的引用](https://stackoverflow.com/questions/64574620/target-of-uri-doesnt-exist-packageflutter-gen-gen-l10n-gallery-localizations)

### 问题3

`Could not run build/ios/iphoneos/Runner.app Try launching Xcode and selecting "Product > Run" to fix the problem: open ios/Runner.xcworkspace`

这个问题我处理了很久，表现的情况也非常奇葩，我使用Xcode进行编译运行没有问题，但是只要通过VSCode进行编辑就报这个错。

然后我就做了这样一件事情：

```shell
flutter clean
```

然后进行重新编译，进行尝试就好了，当然我的这个方法并不适合所有的开发者。

最后可能会在VSCode进行编译的时候，`pod install`失败，请尝试直接打开ios这个文件夹，通过命令行工具直接进行`pod install`。

### 问题4

由于是iOS工程，所以项目里面的team和Boundle id可能都需要自己重新配置一下，甚至可能那个子工程都需要进行删除，因为一旦换了team，可能就没有能力去扩展子工程了。

### iOS的问题后续

根据我目前review code的情况看，这个App其实主要还是针对安卓端做了适配，其实针对iOS的优化还是比较薄弱的，我尽可能的进行修复吧。

### 本FAQ被以下人数阅读,谢谢你们的配合:)

![:PixezFAQ](https://count.getloli.com/get/@:PixezFAQ?theme=rule34)
