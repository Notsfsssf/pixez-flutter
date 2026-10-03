# PixEz 小说页改动说明（长按快速屏蔽 + 加载更多卡死修复）

> 基于 `0.9.109`（tag `0.9.109`，commit `0750c38b0c8aaf200e992ec9b4303f5cd6abba87`）修改，仅涉及 **3 个文件**。
> 补丁已在 0.9.109 源码上验证可干净应用（应用后与 `files/` 下的文件逐字节一致）。

**English TL;DR**

- Adds a long-press bottom sheet on novel list items to block the author (with confirm) / block the novel / copy the title. Reuses the existing `muteStore.insertBanUserId` / `insertBanIllusts` APIs — no new store methods, no new dependencies.
- Fixes "pull up to load more stops working" on novel lists: filtering moved into `NovelLightingStore`, and both `fetch()`/`next()` now keep requesting pages until enough *visible* (non-muted) items are collected. Root cause: with heavy mute rules only 1–3 items survive per page, so the list grows too little for `ClassicFooter` to leave its `done`/`infiniteOffset` zone and re-arm.
- Also removes the `_store.novels.removeWhere(...)` calls that mutated an `ObservableList` during build.

---

## 一、这个包里有什么

```
给作者的提交包/
├── README-给作者的说明.md          ← 本文件
├── files/                          ← 改动后的完整文件，可直接覆盖
│   └── lib/page/novel/
│       ├── component/novel_lighting_store.dart
│       ├── component/novel_lighting_list.dart
│       └── recom/novel_recom_page.dart
└── patches/                        ← 可 git apply 的补丁（相对仓库根目录）
    ├── ALL-changes.patch           ← 三个文件的全部改动
    ├── novel_lighting_store.dart.patch
    ├── novel_lighting_list.dart.patch
    └── novel_recom_page.dart.patch
```

**只改了这 3 个文件，没有新增任何依赖、没有改动 pubspec / 没有新增 store 接口、没有 i18n 文案生成。**

| 文件 | 功能一 长按快速屏蔽 | 功能二 加载更多修复 |
|---|---|---|
| `component/novel_lighting_store.dart` | — | **核心** |
| `recom/novel_recom_page.dart`（推荐页） | ✔ | ✔（删掉 build 期过滤） |
| `component/novel_lighting_list.dart`（排行/最新/搜索/收藏共用） | ✔ | ✔（删掉 build 期过滤） |

---

## 二、功能一：小说列表长按快速屏蔽

### 交互

在小说条目上**长按** → 震动反馈 → 弹出底部菜单：

| 菜单项 | 行为 |
|---|---|
| 屏蔽用户（复用 `I18n.block_user`） | 弹二次确认框（显示作者名 + id），确认后 `muteStore.insertBanUserId` |
| 屏蔽作品（当前为中文硬编码，见下方 i18n 说明） | 直接 `muteStore.insertBanIllusts(BanIllustIdPersist(...))` |
| 复制标题（复用 `I18n.copy`） | 复制到剪贴板 + `BotToast` 提示 |

屏蔽后列表会因已有逻辑自动刷新，条目立即消失。

### 用到的都是现成的 API

`muteStore`（`package:pixez/main.dart` 全局）、`muteStore.insertBanUserId(String id, String name)`、`muteStore.insertBanIllusts(BanIllustIdPersist)`、`BanIllustIdPersist`（`models/ban_illust_id.dart`）、`HapticUtil`（`utils/haptic_util.dart`）——**上游都已存在**，图片页/作者页也是这个用法。

### 需要新增的 import

```dart
import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/services.dart';        // Clipboard
import 'package:pixez/main.dart';              // muteStore
import 'package:pixez/models/ban_illust_id.dart';
import 'package:pixez/utils/haptic_util.dart'; // 仅 novel_lighting_list.dart 需要
```

`novel_lighting_list.dart` 需要把原来的 `import 'package:pixez/exts.dart';` 删掉（过滤搬到 store 后不再使用 `hateByUser`）。

### 核心代码（两个文件一致）

```dart
// 条目 InkWell 内
onLongPress: () {
  HapticUtil.heavy();
  _showNovelItemMenu(context, novel);
},

// 底部菜单
void _showNovelItemMenu(BuildContext context, Novel novel) {
  HapticUtil.heavy();
  showModalBottomSheet<void>(
    context: context,
    builder: (BuildContext sheetContext) {
      return SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(novel.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(sheetContext).textTheme.titleMedium),
            ),
            ListTile(
              leading: const Icon(Icons.person_off_outlined),
              title: Text('${I18n.of(sheetContext).block_user}'),
              subtitle: Text('${novel.user.name}'),
              onTap: () {
                Navigator.pop(sheetContext);
                _confirmAndMuteAuthor(context, novel);
              },
            ),
            ListTile(
              leading: const Icon(Icons.image_not_supported_outlined),
              title: Text('屏蔽作品'),
              subtitle: Text('#${novel.id}'),
              onTap: () {
                Navigator.pop(sheetContext);
                _muteNovel(context, novel);
              },
            ),
            ListTile(
              leading: const Icon(Icons.copy_outlined),
              title: Text(I18n.of(sheetContext).copy),
              onTap: () {
                Clipboard.setData(ClipboardData(text: novel.title));
                BotToast.showText(text: I18n.of(sheetContext).copied_to_clipboard);
                Navigator.pop(sheetContext);
              },
            ),
          ],
        ),
      );
    },
  );
}

Future<void> _confirmAndMuteAuthor(BuildContext context, Novel novel) async {
  final result = await showDialog(
    context: context,
    builder: (dialogContext) {
      return AlertDialog(
        title: Text('${I18n.of(dialogContext).block_user}?'),
        content: Text('${novel.user.name} (${novel.user.id})'),
        actions: <Widget>[
          TextButton(
            child: Text(I18n.of(dialogContext).cancel),
            onPressed: () => Navigator.pop(dialogContext),
          ),
          TextButton(
            child: Text(I18n.of(dialogContext).ok),
            onPressed: () => Navigator.pop(dialogContext, "OK"),
          ),
        ],
      );
    },
  );
  if (result == "OK") {
    await muteStore.insertBanUserId(novel.user.id.toString(), novel.user.name);
    BotToast.showText(text: '已屏蔽作者: ${novel.user.name}');
  }
}

Future<void> _muteNovel(BuildContext context, Novel novel) async {
  await muteStore.insertBanIllusts(
      BanIllustIdPersist(illustId: novel.id.toString(), name: novel.title));
  BotToast.showText(text: '已屏蔽作品: ${novel.title}');
}
```

### 关于文案（待作者决定）

为不引入 `gen-l10n` 重新生成，本地版本对新增文案使用了中文硬编码，建议上游改为 i18n：

- 可复用：`block_user`、`cancel`、`ok`、`copy`、`copied_to_clipboard`
- 建议新增：`block_novel`（屏蔽作品）、`blocked_user` / `blocked_novel`（屏蔽成功提示，可带占位符）

---

## 三、功能二：小说列表"上滑不再加载 / 下拉也恢复不了"修复

### 复现条件

屏蔽标签/作者较多时（实测推荐页每页 30 条里只有 **1~3 条**能通过过滤）：

1. 打开小说页 → 一直上滑；
2. 底部转圈、显示"加载中"，然后停在 footer 的 **"Succeeded"**；
3. 之后**怎么滑都不再加载新内容**，下拉刷新也只能恢复一次，继续滑又卡住。

### 根因

`easy_refresh` 的 `ClassicFooter`：

- 触发自动加载依赖 `infiniteOffset`（默认 **70px**）：只有当滚动位置**离开底部的距离 ≥ 70px** 时，footer 才会从 `done` 态重新变回可触发状态（见 `indicator_notifier.dart` 中 `FooterNotifier._updateMode` / `edgeOffset`）；
- 上游 `next()` 一次 `onLoad` 只请求**一页**，过滤后只新增 1~3 条；
- 列表只长高一丁点，用户仍停留在底部 70px 以内 → footer 一直保持 `done`（界面显示 "Succeeded"）→ 永不再触发 `onLoad`。

这是"**列表增量太小 + 触发器需要离开触发区**"两个条件叠加的结果，只有在屏蔽规则较重时才会命中，所以平时不容易发现。

### 修复思路

把过滤从页面 build 期搬到 **store 期**，并让一次 `onRefresh` / `onLoad` **持续取页直到攒够可见项**：

```
取一页 → 过滤被屏蔽项 → 数一数够不够 8 条
   ├── 够了            → 一次性交给列表
   └── 不够            → 继续取下一页（最多 10 页）
                          ├── 攒够 → 交给列表
                          ├── nextUrl 空了 → 如实告知"没有更多"
                          └── 10 页仍为 0 → 判定失败，交用户重试
```

两个参数（`novel_lighting_store.dart`）：

```dart
/// 单次 onRefresh / onLoad 内至少收集这么多条“可见（未被屏蔽）”的小说再交给列表。
static const int _minVisibleTarget = 8;

/// 单次 onRefresh / onLoad 内最多连续取页数，避免屏蔽规则过重时长时间空转。
static const int _maxRounds = 10;
```

### 关键代码

`fetch()`（下拉刷新）：

```dart
final collected = novelRecomResponse.novels
    .where((element) => !element.hateByUser())
    .toList();

int round = 0;
while (collected.length < _minVisibleTarget &&
    round < _maxRounds &&
    nextUrl != null &&
    nextUrl!.isNotEmpty) {
  round++;
  try {
    final Response nextResponse = await _client.getNext(nextUrl!);
    final NovelRecomResponse nextPayload =
        NovelRecomResponse.fromJson(nextResponse.data);
    nextUrl = nextPayload.nextUrl;
    collected.addAll(nextPayload.novels
        .where((element) => !element.hateByUser())
        .toList());
  } catch (e) {
    break; // 续取失败不视为整体失败，已收集到的照常展示
  }
}

this.novels.clear();
this.novels.addAll(collected.map((element) => NovelStore(element.id, element)));
controller.finishRefresh(IndicatorResult.success);
```

`next()`（加载更多）——重点是**无论哪种情况都必须调用 `finishLoad`**，避免 footer 卡在中间态：

```dart
final collected = <Novel>[];
int round = 0;
while (round < _maxRounds && collected.length < _minVisibleTarget) {
  if (nextUrl == null || nextUrl!.isEmpty) break;
  round++;
  try {
    final Response response = await _client.getNext(nextUrl!);
    final NovelRecomResponse novelRecomResponse =
        NovelRecomResponse.fromJson(response.data);
    nextUrl = novelRecomResponse.nextUrl;
    collected.addAll(novelRecomResponse.novels
        .where((element) => !element.hateByUser())
        .toList());
  } catch (e) {
    break;
  }
}

if (collected.isNotEmpty) {
  novels.addAll(collected.map((element) => NovelStore(element.id, element)));
}

if (nextUrl == null || nextUrl!.isEmpty) {
  controller.finishLoad(IndicatorResult.noMore);   // 真的到底了
} else if (collected.isNotEmpty) {
  controller.finishLoad(IndicatorResult.success);  // 正常放出内容
} else {
  controller.finishLoad(IndicatorResult.fail);     // 连续取页无可见项，交用户重试
}
```

| 分支 | 条件 | 结果 |
|---|---|---|
| `noMore` | `nextUrl` 为空 | 有内容也展示，同时显示"没有更多" |
| `success` | 取到 ≥1 条可见内容 | 正常加载完成 |
| `fail` | 取满 `_maxRounds` 页仍 0 条可见内容 | 显示失败，用户再滑可重试 |

### 同时删除的页面期过滤（两个页面文件）

```dart
// novel_lighting_list.dart / novel_recom_page.dart
- _store.novels.removeWhere((element) => element.novel?.hateByUser() == true);
```

这行是在 **build 过程中修改 `ObservableList`**（在 `Observer` 的 builder 里），属于"build 期改状态"，容易引发多余重建/索引越界；过滤搬到 store 后它也没有存在意义，因此删除。删除后页面列表直接用 `_store.novels`，`childCount` / `itemCount` 用 `_store.novels.length`。

### 行为与代价

- 屏蔽规则轻或无屏蔽时：一页就够 8 条，**不会多请求**，行为与原来一致；
- 屏蔽规则重时：一次加载最多多请求 9 页（内存/流量略增），换来的是**永远不再卡死**；
- 若希望更保守，`_minVisibleTarget` 可下调到 5~6，或把 `_maxRounds` 降到 5。

### 其他可选做法（欢迎作者判断）

1. 减小 footer 的 `infiniteOffset`（甚至 0）——能让 footer 立即重新武装，但会变成"贴底就连续自动加载"，体验上更激进；
2. 在 store 暴露 `hasMore` / `visibleCount`，由页面层决定何时 `finishLoad` —— 改动更大，但状态更显式。

本补丁选择了改动最小、且对无屏蔽用户零影响的方案。

---

## 四、顺带的两个小改动（与上面两个功能无强关联，可自行取舍）

| 位置 | 改动 | 说明 |
|---|---|---|
| `novel_recom_page.dart` | `_buildItem(context, novel, index)` → `_buildItem(context, novelStore)` | 纯重构：去掉重复的 `_store.novels[index]` 取用，`NovelViewerPage` 直接拿同一个 `NovelStore` 实例。不影响行为，可丢弃。 |
| `novel_recom_page.dart` | 列表区由 `if (_store.novels.isNotEmpty) _buildSliverList()` 改为**三分支**：`errorMessage != null` → 错误占位（含重试按钮）／`novels.isNotEmpty` → 列表／否则 → 加载中 | 加载失败时给出重试入口，而不是空白页。属于体验优化，可丢弃。 |

---

## 五、**不包含**的内容（避免误会）

以下几项是本机个人构建需要的，**与本次两个功能无关，请不要合入**：

- Android 构建用的阿里云 Maven 镜像（`android/build.gradle.kts`、`settings.gradle.kts`、`plugins/rhttp/.../build.gradle.kts`）；
- 发布签名配置（`android/key.properties`、`*.jks`）、`cargokit` 预编译开关、`gradle.properties` 里的构建加速开关；
- 屏蔽数据导出/导入增强、快速屏蔽以外的其他本地功能；
- 排查期间临时使用的 `novel_debug_log.dart`（屏幕日志面板）——**已从提交的 3 个文件中完全移除**，本补丁不包含该文件。

`files/` 下的三个文件已确认不含任何调试代码。

---

## 六、如何应用

**方式 A：打补丁（推荐，相对仓库根目录）**

```bash
git apply -p1 给作者的提交包/patches/ALL-changes.patch
# 或只取某个文件
git apply -p1 给作者的提交包/patches/novel_lighting_store.dart.patch
```

**方式 B：直接覆盖文件**

把 `files/lib/page/novel/...` 三个文件复制到仓库对应路径即可。

> 如果只想采用其中一个功能：功能二只需要 `novel_lighting_store.dart` + 两个页面文件里删除 `removeWhere` 那几行；功能一只需要两个页面文件里的 `onLongPress` + 三个方法 + 相关 import。

**验证方式**

1. 屏蔽大量标签/作者；2. 打开小说页（推荐页与搜索结果页都试）；3. 一直上滑——应能持续加载出新内容，不再停在 "Succeeded"；4. 长按任一条目——应出现屏蔽菜单。

---

## 七、许可证

本项目为 GPL-3.0，本改动按同一许可证提供，欢迎作者自由采用、修改或拆分。
