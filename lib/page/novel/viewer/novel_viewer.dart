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
import 'package:flutter/material.dart';
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
        _textStyle = Theme.of(context).textTheme.bodyLarge!.copyWith(
              fontSize: userSetting.novelFontsize,
            );
        if (_novelStore.errorMessage != null) {
          return Scaffold(
            appBar: AppBar(
              elevation: 0.0,
            ),
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
                        child: Text(':(',
                            style: Theme.of(context).textTheme.headlineMedium),
                      ),
                    ),
                  ),
                  TextButton(
                      onPressed: () {
                        _novelStore.fetch();
                      },
                      child: Text(I18n.of(context).retry)),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text('${_novelStore.errorMessage}'),
                  )
                ],
              ),
            ),
          );
        }
        if (_novelStore.novelTextResponse != null &&
            _novelStore.novel != null) {
          _textStyle =
              _textStyle ?? Theme.of(context).textTheme.bodyLarge!.copyWith();
          if (_controller == null) {
            LPrinter.d("init Controller ${_novelStore.bookedOffset}");
            _controller =
                ScrollController(initialScrollOffset: _novelStore.bookedOffset);
            _controller?.addListener(() {
              if (_controller!.hasClients) _localOffset = _controller!.offset;
            });
          }
          return Container(
            child: Scaffold(
              appBar: AppBar(
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
                title: Text(
                  _novelStore.novelTextResponse!.text.length.toString(),
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                backgroundColor: Colors.transparent,
                actions: <Widget>[
                  NovelBookmarkButton(
                    novel: _novelStore.novel!,
                  ),
                  IconButton(
                    onPressed: () {
                      if (_novelStore.positionBooked)
                        _novelStore.deleteBookPosition();
                      else
                        _novelStore.bookPosition(_controller!.offset);
                    },
                    icon: Icon(Icons.history),
                    color: Theme.of(context)
                        .textTheme
                        .bodyLarge!
                        .color!
                        .withAlpha(_novelStore.positionBooked ? 225 : 120),
                  ),
                  Builder(builder: (context) {
                    return IconButton(
                      icon: Icon(
                        Icons.more_vert,
                        color: Theme.of(context).textTheme.bodyLarge!.color,
                      ),
                      onPressed: () {
                        _showMessage(context);
                      },
                    );
                  })
                ],
              ),
              extendBodyBehindAppBar: true,
              body: ListView.builder(
                  padding: EdgeInsets.all(0),
                  controller: _controller,
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      return _buildHeader(context);
                    } else if (index == _novelStore.spans.length + 1) {
                      return Container(
                          height: 10 + MediaQuery.of(context).padding.bottom);
                    } else {
                      return _buildSpanText(
                          context, index - 1, _novelStore.spans);
                    }
                  },
                  itemCount: 2 + _novelStore.spans.length),
            ),
          );
        }
        return Scaffold(
          appBar: AppBar(
            elevation: 0.0,
            backgroundColor: Colors.transparent,
          ),
          body: Container(
            child: Center(
              child: CircularProgressIndicator(),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSpanText(
      BuildContext context, int index, List<NovelSpansData> spanDatas) {
    return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: SelectionArea(
          onSelectionChanged: (value) {
            _selectedText = value?.plainText ?? "";
          },
          contextMenuBuilder: (context, editableTextState) {
            return _buildSelectionMenu(editableTextState, context);
          },
          child: Text.rich(
            novelSpansGenerator.novelSpansDatatoInlineSpan(
                context, spanDatas[index]),
            style: _textStyle,
            textHeightBehavior:
                TextHeightBehavior(applyHeightToLastDescent: true),
          ),
        ));
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
      child: Column(
        children: [
          Container(
            height: 100,
          ),
          Center(
              child: Container(
                  height: 160,
                  child: PixivImage(_novelStore.novel!.imageUrls.medium))),
          Padding(
            padding: const EdgeInsets.only(
                left: 16.0, right: 16.0, top: 12.0, bottom: 8.0),
            child: Text(
              "${_novelStore.novel!.title}",
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          if (_novelStore.novel?.series.id != null)
            Padding(
              padding: const EdgeInsets.only(
                  left: 16.0, right: 16.0, top: 0.0, bottom: 0.0),
              child: InkWell(
                onTap: () {
                  Leader.push(
                      context, NovelSeriesPage(_novelStore.novel!.series.id!));
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
              padding:
                  const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
              child: Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 2,
                runSpacing: 0,
                children: [
                  if (_novelStore.novel!.NovelAIType == 2)
                    Text("${I18n.of(context).ai_generated}",
                        style: Theme.of(context).textTheme.bodySmall!.copyWith(
                            color: Theme.of(context).colorScheme.secondary)),
                  for (var f in _novelStore.novel!.tags) buildRow(context, f)
                ],
              )),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: SelectionArea(
                  onSelectionChanged: (value) {
                    _selectedText = value?.plainText ?? "";
                  },
                  contextMenuBuilder: (context, editableTextState) {
                    return _buildSelectionMenu(editableTextState, context);
                  },
                  child: SelectableHtml(data: _novelStore.novel?.caption ?? ""),
                ),
              ),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0)),
            ),
          ),
          TextButton(
              onPressed: () {
                Leader.push(
                    context,
                    CommentPage(
                      id: _novelStore.id,
                      type: CommentArtWorkType.NOVEL,
                    ));
              },
              child: Text(I18n.of(context).view_comment)),
        ],
      ),
    );
  }

  AdaptiveTextSelectionToolbar _buildSelectionMenu(
      SelectableRegionState editableTextState, BuildContext context) {
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
              Share.share(selectionText, sharePositionOrigin: pos);
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
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(16),
          ),
        ),
        builder: (context) {
          return StatefulBuilder(builder: (context, setB) {
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
                                _textStyle =
                                    _textStyle!.copyWith(fontSize: v * 32);
                              });
                              userSetting.setNovelFontsizeWithoutSave(v * 32);
                            })),
                  ],
                )
              ],
            ));
          });
        });
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
        })) {
      case 0:
        {
          await muteStore.insertBanTag(BanTagPersist(
              name: f.name, translateName: f.translatedName ?? ""));
          Navigator.of(context).pop();
        }
        break;
      case 2:
        {
          await Clipboard.setData(ClipboardData(text: f.name));
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            duration: Duration(seconds: 1),
            content: Text(I18n.of(context).copied_to_clipboard),
          ));
        }
    }
  }

  Widget buildRow(BuildContext context, Tag f) {
    return GestureDetector(
      onLongPress: () async {
        _longPressTag(context, f);
      },
      onTap: () {
        Navigator.of(context).push(MaterialPageRoute(builder: (context) {
          return NovelResultPage(
            word: f.name,
            translatedName: f.translatedName ?? "",
          );
        }));
      },
      child: RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
              text: "#${f.name}",
              children: [
                TextSpan(
                  text: " ",
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                TextSpan(
                    text: "${f.translatedName ?? "~"}",
                    style: Theme.of(context).textTheme.bodySmall)
              ],
              style: Theme.of(context)
                  .textTheme
                  .bodySmall!
                  .copyWith(color: Theme.of(context).colorScheme.secondary))),
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
            borderRadius: BorderRadius.vertical(top: Radius.circular(16.0))),
        builder: (context) {
          return SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                ListTile(
                  subtitle: Text(
                    _novelStore.novel!.user.name,
                    maxLines: 2,
                  ),
                  title: Text(
                    _novelStore.novel!.title,
                    maxLines: 2,
                  ),
                  leading: Container(
                    child: PainterAvatar(
                      url: _novelStore.novel!.user.profileImageUrls.medium,
                      id: _novelStore.novel!.user.id,
                      size: Size(40, 40),
                      onTap: () {
                        Navigator.of(context)
                            .push(MaterialPageRoute(builder: (context) {
                          return NovelUsersPage(
                            id: _novelStore.novel!.user.id,
                          );
                        }));
                      },
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(I18n.of(context).pre),
                ),
                buildListTile(
                    _novelStore.novelTextResponse!.seriesNavigation?.prevNovel),
                Divider(),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(I18n.of(context).next),
                ),
                buildListTile(
                    _novelStore.novelTextResponse!.seriesNavigation?.nextNovel),
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
                  leading: Icon(
                    Icons.settings,
                  ),
                  onTap: () {
                    Navigator.of(context).pop();
                    _showSettings(context);
                  },
                ),
                ListTile(
                  title: Text(I18n.of(context).share),
                  leading: Icon(
                    Icons.share,
                  ),
                  onTap: () {
                    Navigator.of(context).pop();
                    Share.share(
                        "https://www.pixiv.net/novel/show.php?id=${widget.id}");
                  },
                ),
              ],
            ),
          );
        });
  }

  Widget buildListTile(PrevNovel? series) {
    if (series == null)
      return ListTile(
        title: Text("no more"),
      );
    return ListTile(
      title: Text(series.title, maxLines: 2, overflow: TextOverflow.ellipsis),
      onTap: () {
        Navigator.of(context, rootNavigator: true)
            .pushReplacement(MaterialPageRoute(
                builder: (BuildContext context) => NovelViewerPage(
                      id: series.id,
                      novelStore: NovelStore(series.id, null),
                    )));
      },
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
          "application/txt");
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
      final novelDirPath =
          Path.join(dirPath, _novelStore.novel!.title.trim().toLegal());
      final novelDir = Directory(novelDirPath);
      if (!novelDir.existsSync()) {
        novelDir.createSync(recursive: true);
      }
      final fileInAllPath = Path.join(
          allPath, "${_novelStore.novel!.title.trim().toLegal()}.txt");
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
