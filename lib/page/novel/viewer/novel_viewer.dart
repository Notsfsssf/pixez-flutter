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

import 'dart:convert';
import 'dart:io';

import 'package:bot_toast/bot_toast.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:mobx/mobx.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pixez/component/painter_avatar.dart';
import 'package:pixez/component/pixiv_image.dart';
import 'package:pixez/component/selectable_html.dart';
import 'package:pixez/er/leader.dart';
import 'package:pixez/er/lprinter.dart';
import 'package:pixez/exts.dart';
import 'package:pixez/i18n.dart';
import 'package:pixez/main.dart';
import 'package:pixez/models/ban_tag.dart';
import 'package:pixez/models/novel_recom_response.dart';
import 'package:pixez/models/novel_web_response.dart';
import 'package:pixez/page/comment/comment_page.dart';
import 'package:pixez/page/novel/component/novel_bookmark_button.dart';
import 'package:pixez/page/novel/search/novel_result_page.dart';
import 'package:pixez/page/novel/series/novel_series_page.dart';
import 'package:pixez/page/novel/user/novel_users_page.dart';
import 'package:pixez/page/novel/viewer/image_text.dart';
import 'package:pixez/page/novel/viewer/novel_store.dart';
import 'package:pixez/saf_plugin.dart';
import 'package:pixez/supportor_plugin.dart';
import 'package:pixez/translation/novel_translation_store.dart';
import 'package:pixez/translation/translation_service.dart';
import 'package:pixez/translation/widgets/text_translation_entry.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path/path.dart' as Path;

class NovelViewerPage extends StatefulWidget {
  final int id;
  final NovelStore? novelStore;

  const NovelViewerPage({Key? key, required this.id, this.novelStore})
    : super(key: key);

  @override
  _NovelViewerPageState createState() => _NovelViewerPageState();
}

class _NovelViewerPageState extends State<NovelViewerPage> {
  ScrollController? _controller;
  late NovelStore _novelStore;
  ReactionDisposer? _offsetDisposer;
  double _localOffset = 0.0;
  bool supportTranslate = false;
  String _selectedText = "";
  NovelSpansGenerator novelSpansGenerator = NovelSpansGenerator();

  /// 小说段落翻译状态（规格 §8.2，不持久化）。
  final NovelTranslationStore _translationStore = NovelTranslationStore();

  /// normal 段落的 (spanIndex, text) 列表（其它类型跳过）。
  List<(int, String)> _translatableParagraphs() {
    final result = <(int, String)>[];
    final spans = _novelStore.spans;
    for (var i = 0; i < spans.length; i++) {
      final span = spans[i];
      if (span.type != NovelSpansType.normal) continue;
      final text = span.text.trim();
      if (text.isEmpty) continue;
      result.add((i, text));
    }
    return result;
  }

  Future<void> _toggleNovelTranslation() async {
    if (_translationStore.translating.value) return;
    final willEnable = !_translationStore.enabled.value;
    TranslationService.instance.prewarm(); // 进入翻译时预热（规格 §8.2）
    await _translationStore.toggle(_translatableParagraphs());
    if (!mounted || !willEnable) return;
    // 失败必须说出来：以前只写 log，用户看到的就是「转圈结束、正文没变」。
    final error = _translationStore.lastError.value;
    if (error != null) {
      BotToast.showText(text: error);
    } else {
      // 说明「原文已被替换」：否则用户会以为只是加了一层、找不到原文去哪了。
      BotToast.showText(
        text: '已翻译 ${_translationStore.translatedCount.value} 段，正文已替换为译文',
      );
    }
  }

  Future<void> initMethod() async {
    if (!Platform.isAndroid) return;
    bool results = await SupportorPlugin.processText();
    if (mounted) {
      setState(() {
        supportTranslate = results;
      });
    }
  }

  @override
  void initState() {
    _novelStore = widget.novelStore ?? NovelStore(widget.id, null);
    _translationStore.resetFor(widget.id);
    _offsetDisposer = reaction((_) => _novelStore.bookedOffset, (_) {
      LPrinter.d("jump to ${_novelStore.bookedOffset}");
      _controller?.jumpTo(_novelStore.bookedOffset);
    });
    _novelStore.fetch();
    super.initState();
    initMethod();
  }

  @override
  void dispose() {
    _offsetDisposer?.call();
    if (_novelStore.positionBooked) {
      _novelStore.bookPosition(_localOffset);
    }
    _controller?.dispose();
    super.dispose();
  }

  final double leading = 0.9;
  final double textLineHeight = 2;
  final double fontSize = 16;
  TextStyle? _textStyle;

  @override
  Widget build(BuildContext context) {
    return Observer(
      builder: (context) {
        _textStyle = Theme.of(
          context,
        ).textTheme.bodyLarge!.copyWith(fontSize: userSetting.novelFontsize);
        if (_novelStore.errorMessage != null) {
          return _buildErrorContent(context);
        }
        if (_novelStore.novelTextResponse != null &&
            _novelStore.novel != null) {
          _textStyle =
              _textStyle ?? Theme.of(context).textTheme.bodyLarge!.copyWith();
          if (_controller == null) {
            LPrinter.d("init Controller ${_novelStore.bookedOffset}");
            _controller = ScrollController(
              initialScrollOffset: _novelStore.bookedOffset,
            );
            _controller?.addListener(() {
              if (_controller!.hasClients) _localOffset = _controller!.offset;
            });
          }
          return Scaffold(
            appBar: _buildAppbar(context),
            extendBodyBehindAppBar: true,
            body: _buildBody(context),
          );
        }
        return Scaffold(
          appBar: AppBar(elevation: 0.0, backgroundColor: Colors.transparent),
          body: Container(child: Center(child: CircularProgressIndicator())),
        );
      },
    );
  }

  Scaffold _buildErrorContent(BuildContext context) {
    return Scaffold(
      appBar: AppBar(elevation: 0.0),
      extendBody: true,
      extendBodyBehindAppBar: true,
      body: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Container(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Center(
                  child: Text(
                    ':(',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                _novelStore.fetch();
              },
              child: Text(I18n.of(context).retry),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text('${_novelStore.errorMessage}'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    return ListView.builder(
      padding: EdgeInsets.all(0),
      controller: _controller,
      itemBuilder: (context, index) {
        if (index == 0) {
          return _buildHeader(context);
        } else if (index == _novelStore.spans.length + 1) {
          return _buildCommentButton(context);
        } else if (index == _novelStore.spans.length + 2) {
          return Container(height: 10 + MediaQuery.of(context).padding.bottom);
        } else {
          return _buildSpanText(context, index - 1, _novelStore.spans);
        }
      },
      itemCount: 3 + _novelStore.spans.length,
    );
  }

  AppBar _buildAppbar(BuildContext context) {
    return AppBar(
      elevation: 0.0,
      leading: IconButton(
        icon: Icon(
          Icons.arrow_back,
          color: Theme.of(context).textTheme.bodyLarge!.color,
        ),
        onPressed: () {
          Navigator.of(context).pop();
        },
      ),
      // 翻译中把「字数」换成进度：整章逐段翻译要跑几分钟，只转圈看不出
      // 到底有没有在动、还剩多少。
      title: Observer(
        builder: (context) {
          final style = Theme.of(context).textTheme.bodyLarge;
          if (!_translationStore.translating.value) {
            return Text(
              _novelStore.novelTextResponse!.text.length.toString(),
              style: style,
            );
          }
          final done = _translationStore.translatedCount.value;
          final total = _translationStore.totalCount.value;
          return Text('翻译中 $done/$total', style: style);
        },
      ),
      backgroundColor: Colors.transparent,
      actions: <Widget>[
        Observer(
          builder: (context) => IconButton(
            tooltip: I18n.of(context).translation,
            onPressed: _toggleNovelTranslation,
            icon: _translationStore.translating.value
                ? SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Icon(
                    Icons.translate,
                    color: Theme.of(context)
                        .textTheme
                        .bodyLarge!
                        .color!
                        .withAlpha(
                          _translationStore.enabled.value ? 225 : 120,
                        ),
                  ),
          ),
        ),
        Observer(
          builder: (context) {
            if (!_translationStore.enabled.value) return SizedBox.shrink();
            return IconButton(
              tooltip: _translationStore.showOnlyTranslation.value
                  ? I18n.of(context).translation_show_source
                  : I18n.of(context).translation_show_translation,
              onPressed: _translationStore.toggleShowMode,
              icon: Icon(
                _translationStore.showOnlyTranslation.value
                    ? Icons.subject
                    : Icons.notes,
                color: Theme.of(context).textTheme.bodyLarge!.color,
              ),
            );
          },
        ),
        NovelBookmarkButton(novel: _novelStore.novel!),
        IconButton(
          onPressed: () {
            if (_novelStore.positionBooked)
              _novelStore.deleteBookPosition();
            else
              _novelStore.bookPosition(_controller!.offset);
          },
          icon: Icon(Icons.history),
          color: Theme.of(context).textTheme.bodyLarge!.color!.withAlpha(
            _novelStore.positionBooked ? 225 : 120,
          ),
        ),
        Builder(
          builder: (context) {
            return IconButton(
              icon: Icon(
                Icons.more_vert,
                color: Theme.of(context).textTheme.bodyLarge!.color,
              ),
              onPressed: () {
                _showMessage(context);
              },
            );
          },
        ),
      ],
    );
  }

  Widget _buildSpanText(
    BuildContext context,
    int index,
    List<NovelSpansData> spanDatas,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Observer(
        builder: (context) {
          final enabled = _translationStore.enabled.value;
          final translated =
              enabled ? _translationStore.translations[index] : null;
          final hasTranslation = translated != null && translated.isNotEmpty;
          // 替换模式（默认）：译文顶掉原文，页面上只剩中文——开翻译就是为了
          // 读懂，把日文继续留在上面容易被当成「没翻成功」。
          // 对照模式：原文在上、译文在下，中间一条细线分隔。
          final replace = _translationStore.showOnlyTranslation.value;
          if (hasTranslation && replace) {
            return _translatedText(translated);
          }
          if (hasTranslation) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _spanRichText(context, spanDatas[index]),
                Padding(
                  padding: const EdgeInsets.only(top: 4.0),
                  child: Divider(height: 1.0, thickness: 0.5),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 4.0),
                  child: _translatedText(translated),
                ),
              ],
            );
          }
          return _spanRichText(context, spanDatas[index]);
        },
      ),
    );
  }

  /// 译文正文：字号跟随「小说字号」设置，可长按选中复制。
  Widget _translatedText(String text) {
    return SelectionArea(
      child: Text(
        text,
        style: _textStyle,
        textHeightBehavior: TextHeightBehavior(
          applyHeightToLastDescent: true,
        ),
      ),
    );
  }

  Widget _spanRichText(BuildContext context, NovelSpansData spanData) {
    return SelectionArea(
      onSelectionChanged: (value) {
        _selectedText = value?.plainText ?? "";
      },
      contextMenuBuilder: (context, editableTextState) {
        return _buildSelectionMenu(editableTextState, context);
      },
      child: Text.rich(
        novelSpansGenerator.novelSpansDatatoInlineSpan(
          context,
          spanData,
        ),
        style: _textStyle,
        textHeightBehavior: TextHeightBehavior(
          applyHeightToLastDescent: true,
        ),
      ),
    );
  }

  Widget _buildCommentButton(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
      child: Center(
        child: TextButton(
          onPressed: () {
            Leader.push(
              context,
              CommentPage(id: _novelStore.id, type: CommentArtWorkType.NOVEL),
            );
          },
          child: Text(
            '${I18n.of(context).view_comment}(${_novelStore.novel?.totalComments ?? 0})',
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
      child: Column(
        children: [
          Container(height: 100),
          Center(
            child: Container(
              height: 160,
              child: PixivImage(_novelStore.novel!.imageUrls.medium),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(
              left: 16.0,
              right: 16.0,
              top: 12.0,
              bottom: 8.0,
            ),
            child: Text(
              "${_novelStore.novel!.title}",
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          if (_novelStore.novel?.series.id != null)
            Padding(
              padding: const EdgeInsets.only(
                left: 16.0,
                right: 16.0,
                top: 0.0,
                bottom: 0.0,
              ),
              child: InkWell(
                onTap: () {
                  Leader.push(
                    context,
                    NovelSeriesPage(_novelStore.novel!.series.id!),
                  );
                },
                child: Text(
                  "Series:${_novelStore.novel!.series.title}",
                  style: Theme.of(context).textTheme.titleSmall,
                ),
              ),
            ),
          //MARK DETAIL NUM,
          _buildNumItem(_novelStore.novel!),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              "${_novelStore.novel!.createDate}",
              style: Theme.of(context).textTheme.labelSmall,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(
              vertical: 8.0,
              horizontal: 16.0,
            ),
            child: Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 2,
              runSpacing: 0,
              children: [
                if (_novelStore.novel!.NovelAIType == 2)
                  Text(
                    "${I18n.of(context).ai_generated}",
                    style: Theme.of(context).textTheme.bodySmall!.copyWith(
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                  ),
                for (var f in _novelStore.novel!.tags) buildRow(context, f),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                // 简介也接翻译：译文直接替换 HTML 原文（与正文同一套交互——
                // 点了就换，不再「原文 + 译文」叠两层）。
                child: TextTranslationEntry(
                  source: _novelStore.novel?.caption ?? "",
                  textColor: _textStyle?.color,
                  original: SelectionArea(
                    onSelectionChanged: (value) {
                      _selectedText = value?.plainText ?? "";
                    },
                    contextMenuBuilder: (context, editableTextState) {
                      return _buildSelectionMenu(editableTextState, context);
                    },
                    child: SelectableHtml(
                      data: _novelStore.novel?.caption ?? "",
                    ),
                  ),
                ),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Leader.push(
                context,
                CommentPage(id: _novelStore.id, type: CommentArtWorkType.NOVEL),
              );
            },
            child: Text(
              '${I18n.of(context).view_comment}(${_novelStore.novel?.totalComments ?? 0})',
            ),
          ),
        ],
      ),
    );
  }

  AdaptiveTextSelectionToolbar _buildSelectionMenu(
    SelectableRegionState editableTextState,
    BuildContext context,
  ) {
    final List<ContextMenuButtonItem> buttonItems =
        editableTextState.contextMenuButtonItems;
    if (supportTranslate) {
      buttonItems.insert(
        buttonItems.length,
        ContextMenuButtonItem(
          label: I18n.of(context).translate,
          onPressed: () async {
            final selectionText = _selectedText;
            if (Platform.isIOS) {
              final box = context.findRenderObject() as RenderBox?;
              final pos = box != null
                  ? box.localToGlobal(Offset.zero) & box.size
                  : null;
              SharePlus.instance.share(
                ShareParams(text: selectionText, sharePositionOrigin: pos),
              );
              return;
            }
            await SupportorPlugin.start(selectionText);
            ContextMenuController.removeAny();
          },
        ),
      );
    }
    return AdaptiveTextSelectionToolbar.buttonItems(
      anchors: editableTextState.contextMenuAnchors,
      buttonItems: buttonItems,
    );
  }

  Future<void> _showSettings(BuildContext context) async {
    await showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setB) {
            return SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Container(
                        child: Icon(Icons.text_fields),
                        margin: EdgeInsets.only(left: 16),
                      ),
                      Container(
                        child: Text(_textStyle!.fontSize!.toInt().toString()),
                        margin: EdgeInsets.only(left: 16),
                      ),
                      Expanded(
                        child: Slider(
                          value: _textStyle!.fontSize! / 32,
                          onChanged: (v) {
                            setB(() {
                              _textStyle = _textStyle!.copyWith(
                                fontSize: v * 32,
                              );
                            });
                            userSetting.setNovelFontsizeWithoutSave(v * 32);
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
    userSetting.setNovelFontsize(_textStyle!.fontSize!);
  }

  Future _longPressTag(BuildContext context, Tag f) async {
    switch (await showDialog(
      context: context,
      builder: (BuildContext context) {
        return SimpleDialog(
          title: Text(f.name),
          children: <Widget>[
            SimpleDialogOption(
              onPressed: () {
                Navigator.pop(context, 0);
              },
              child: Text(I18n.of(context).ban),
            ),
            SimpleDialogOption(
              onPressed: () {
                Navigator.pop(context, 2);
              },
              child: Text(I18n.of(context).copy),
            ),
          ],
        );
      },
    )) {
      case 0:
        {
          await muteStore.insertBanTag(
            BanTagPersist(name: f.name, translateName: f.translatedName ?? ""),
          );
          Navigator.of(context).pop();
        }
        break;
      case 2:
        {
          await Clipboard.setData(ClipboardData(text: f.name));
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              duration: Duration(seconds: 1),
              content: Text(I18n.of(context).copied_to_clipboard),
            ),
          );
        }
    }
  }

  Widget buildRow(BuildContext context, Tag f) {
    return GestureDetector(
      onLongPress: () async {
        _longPressTag(context, f);
      },
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) {
              return NovelResultPage(
                word: f.name,
                translatedName: f.translatedName ?? "",
              );
            },
          ),
        );
      },
      child: RichText(
        textAlign: TextAlign.center,
        text: TextSpan(
          text: "#${f.name}",
          children: [
            TextSpan(text: " ", style: Theme.of(context).textTheme.bodySmall),
            TextSpan(
              text: "${f.translatedName ?? "~"}",
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
          style: Theme.of(context).textTheme.bodySmall!.copyWith(
            color: Theme.of(context).colorScheme.secondary,
          ),
        ),
      ),
    );
  }

  Widget _buildNumItem(Novel novel) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4),
      child: Wrap(
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 2,
        runSpacing: 0,
        children: [
          Text(I18n.of(context).total_bookmark),
          Text(
            "${novel.totalBookmarks}",
            style: TextStyle(color: Theme.of(context).colorScheme.primary),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: Text(I18n.of(context).total_view),
          ),
          Text(
            "${novel.totalView}",
            style: TextStyle(color: Theme.of(context).colorScheme.primary),
          ),
        ],
      ),
    );
  }

  Future _showMessage(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.0)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              ListTile(
                subtitle: Text(_novelStore.novel!.user.name, maxLines: 2),
                title: Text(_novelStore.novel!.title, maxLines: 2),
                leading: Container(
                  child: PainterAvatar(
                    url: _novelStore.novel!.user.profileImageUrls.medium,
                    id: _novelStore.novel!.user.id,
                    size: Size(40, 40),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) {
                            return NovelUsersPage(
                              id: _novelStore.novel!.user.id,
                            );
                          },
                        ),
                      );
                    },
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(I18n.of(context).pre),
              ),
              buildListTile(
                _novelStore.novelTextResponse!.seriesNavigation?.prevNovel,
              ),
              Divider(),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(I18n.of(context).next),
              ),
              buildListTile(
                _novelStore.novelTextResponse!.seriesNavigation?.nextNovel,
              ),
              if (Platform.isAndroid)
                ListTile(
                  title: Text(I18n.of(context).export),
                  leading: Icon(Icons.folder_zip),
                  onTap: () {
                    _export();
                  },
                ),
              ListTile(
                title: Text(I18n.of(context).setting),
                leading: Icon(Icons.settings),
                onTap: () {
                  Navigator.of(context).pop();
                  _showSettings(context);
                },
              ),
              Builder(
                builder: (context) {
                  return ListTile(
                    title: Text(I18n.of(context).share),
                    leading: Icon(Icons.share),
                    onTap: () {
                      Navigator.of(context).pop();
                      final box = context.findRenderObject() as RenderBox?;
                      final pos = box != null
                          ? box.localToGlobal(Offset.zero) & box.size
                          : null;
                      final link =
                          "https://www.pixiv.net/novel/show.php?id=${widget.id}";
                      SharePlus.instance.share(
                        ShareParams(text: link, sharePositionOrigin: pos),
                      );
                    },
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget buildListTile(PrevNovel? series) {
    if (series == null) return ListTile(title: Text("no more"));
    return ListTile(
      title: Text(
        series.title ?? series.contentOrder,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
      enabled: series.viewable,
      onTap: series.viewable
          ? () {
              Navigator.of(context, rootNavigator: true).pushReplacement(
                MaterialPageRoute(
                  builder: (BuildContext context) => NovelViewerPage(
                    id: series.id,
                    novelStore: NovelStore(series.id, null),
                  ),
                ),
              );
            }
          : null,
    );
  }

  void _export() async {
    if (_novelStore.novelTextResponse == null) return;
    if (Platform.isAndroid) {
      // final path = await getExternalStorageDirectory();
      // if (path == null) return;
      // final dirPath = Path.join(path.path, "novel_export");
      // final dir = Directory(dirPath);
      // if (!dir.existsSync()) {
      //   dir.createSync(recursive: true);
      // }
      // final allPath = Path.join(dirPath, "All");
      // final allDir = Directory(allPath);
      // if (!allDir.existsSync()) {
      //   allDir.createSync(recursive: true);
      // }
      // final novelDirPath =
      //     Path.join(dirPath, _novelStore.novel!.title.trim().toLegal());
      // final novelDir = Directory(novelDirPath);
      // if (!novelDir.existsSync()) {
      //   novelDir.createSync(recursive: true);
      // }
      // final fileInAllPath = Path.join(
      //     allPath, "${_novelStore.novel!.title.trim().toLegal()}.txt");
      // final filePath = Path.join(novelDirPath, "${_novelStore.novel!.id}.txt");
      // final resultFile = File(filePath);
      // final data = _novelStore.novelTextResponse!.text;
      // resultFile.writeAsStringSync(data);
      // File(fileInAllPath).writeAsStringSync(data);
      // BotToast.showText(text: "export ${filePath}");
      final data = _novelStore.novelTextResponse!.text;
      final uri = await SAFPlugin.createFile(
        "${_novelStore.novel!.title.trim().toLegal()}.txt",
        "application/txt",
      );
      await SAFPlugin.writeUri(uri!, utf8.encode(data));
      BotToast.showText(text: "export success");
    } else if (Platform.isIOS) {
      final path = await getApplicationDocumentsDirectory();
      final dirPath = Path.join(path.path, "novel_export");
      final dir = Directory(dirPath);
      if (!dir.existsSync()) {
        dir.createSync(recursive: true);
      }
      final allPath = Path.join(dirPath, "All");
      final allDir = Directory(allPath);
      if (!allDir.existsSync()) {
        allDir.createSync(recursive: true);
      }
      final novelDirPath = Path.join(
        dirPath,
        _novelStore.novel!.title.trim().toLegal(),
      );
      final novelDir = Directory(novelDirPath);
      if (!novelDir.existsSync()) {
        novelDir.createSync(recursive: true);
      }
      final fileInAllPath = Path.join(
        allPath,
        "${_novelStore.novel!.title.trim().toLegal()}.txt",
      );
      final filePath = Path.join(novelDirPath, "${_novelStore.novel!.id}.txt");
      final resultFile = File(filePath);
      final data = _novelStore.novelTextResponse!.text;
      resultFile.writeAsStringSync(data);
      File(fileInAllPath).writeAsStringSync(data);
      LPrinter.d("path: $filePath");
      BotToast.showText(text: "export ${filePath}");
    }
  }
}
