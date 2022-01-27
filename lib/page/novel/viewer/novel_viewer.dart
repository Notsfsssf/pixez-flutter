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

import 'package:extended_text/extended_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:pixez/component/painter_avatar.dart';
import 'package:pixez/component/pixiv_image.dart';
import 'package:pixez/component/text_selection_toolbar.dart';
import 'package:pixez/er/leader.dart';
import 'package:pixez/i18n.dart';
import 'package:pixez/main.dart';
import 'package:pixez/models/novel_recom_response.dart';
import 'package:pixez/models/novel_text_response.dart';
import 'package:pixez/page/comment/comment_page.dart';
import 'package:pixez/page/novel/component/novel_bookmark_button.dart';
import 'package:pixez/page/novel/user/novel_user_page.dart';
import 'package:pixez/page/novel/viewer/image_text.dart';
import 'package:pixez/page/novel/viewer/novel_store.dart';
import 'package:share_plus/share_plus.dart';

class NovelViewerPage extends StatefulWidget {
  final int id;
  final NovelStore? novelStore;

  const NovelViewerPage({Key? key, required this.id, this.novelStore})
      : super(key: key);

  @override
  _NovelViewerPageState createState() => _NovelViewerPageState();
}

class _NovelViewerPageState extends State<NovelViewerPage> {
  late ScrollController _controller;
  late NovelStore _novelStore;

  @override
  void initState() {
    _novelStore = widget.novelStore ?? NovelStore(widget.id, null);
    _novelStore.fetch();
    _controller = ScrollController();
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
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
        _textStyle = userSetting.novelTextStyle;
        if (_novelStore.errorMessage != null) {
          return Scaffold(
            appBar: AppBar(
              elevation: 0.0,
              backgroundColor: Colors.transparent,
            ),
            extendBody: true,
            extendBodyBehindAppBar: true,
            body: SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(':(',
                        style: Theme.of(context).textTheme.headline4),
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
              _textStyle ?? Theme.of(context).textTheme.bodyText1!.copyWith();
          return Scaffold(
            appBar: AppBar(
              elevation: 0.0,
              leading: IconButton(
                icon: Icon(
                  Icons.arrow_back,
                  color: Theme.of(context).textTheme.bodyText1!.color,
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              title: Text(
                  _novelStore.novelTextResponse!.novelText.length.toString()),
              backgroundColor: Colors.transparent,
              actions: <Widget>[
                NovelBookmarkButton(
                  novel: _novelStore.novel!,
                ),
                IconButton(
                    icon: Icon(
                      Icons.settings,
                      color: Theme.of(context).textTheme.bodyText1!.color,
                    ),
                    onPressed: () async {
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
                                        child: Text(_textStyle!.fontSize!
                                            .toInt()
                                            .toString()),
                                        margin: EdgeInsets.only(left: 16),
                                      ),
                                      Expanded(
                                          child: Slider(
                                              value: _textStyle!.fontSize! / 32,
                                              onChanged: (v) {
                                                setB(() {
                                                  _textStyle = _textStyle!
                                                      .copyWith(
                                                          fontSize: v * 32);
                                                });
                                                userSetting
                                                    .setNovelFontsizeWithoutSave(
                                                        v * 32);
                                              })),
                                    ],
                                  )
                                ],
                              ));
                            });
                          });
                      userSetting.setNovelFontsize(_textStyle!.fontSize!);
                    }),
                IconButton(
                    icon: Icon(
                      Icons.share,
                      color: Theme.of(context).textTheme.bodyText1!.color,
                    ),
                    onPressed: () {
                      Share.share(
                          "https://www.pixiv.net/novel/show.php?id=${widget.id}");
                    }),
                IconButton(
                  icon: Icon(
                    Icons.more_vert,
                    color: Theme.of(context).textTheme.bodyText1!.color,
                  ),
                  onPressed: () {
                    _showMessage(context);
                  },
                )
              ],
            ),
            extendBodyBehindAppBar: true,
            body: ListView(
              padding: EdgeInsets.all(0.0),
              controller: _controller,
              children: <Widget>[
                Container(
                  height: MediaQuery.of(context).padding.top + 100,
                ),
                Center(
                    child: Container(
                        height: 160,
                        child:
                            PixivImage(_novelStore.novel!.imageUrls.medium))),
                Padding(
                  padding: const EdgeInsets.only(
                      left: 16.0, right: 16.0, top: 12.0, bottom: 8.0),
                  child: Text(
                    "${_novelStore.novel!.title}",
                    style: Theme.of(context).textTheme.subtitle1,
                  ),
                ),
                //MARK DETAIL NUM,
                _buildNumItem(
                    _novelStore.novelTextResponse!, _novelStore.novel!),
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
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(
                    "${_novelStore.novel!.createDate}",
                    style: Theme.of(context).textTheme.overline,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ExtendedText(
                    _novelStore.novelTextResponse!.novelText,
                    selectionControls: TranslateTextSelectionControls(),
                    selectionEnabled: true,
                    specialTextSpanBuilder: NovelSpecialTextSpanBuilder(),
                    style: _textStyle,
                  ),
                ),
                Container(
                  height: 10,
                ),
              ],
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

  Widget _buildNumItem(NovelTextResponse resp, Novel novel) {
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
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(16.0))),
        builder: (context) {
          return SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                ListTile(
                  subtitle: Text(_novelStore.novel!.user.name),
                  title: Text(_novelStore.novel!.title),
                  leading: PainterAvatar(
                    url: _novelStore.novel!.user.profileImageUrls.medium,
                    id: _novelStore.novel!.user.id,
                    onTap: () {
                      Navigator.of(context)
                          .push(MaterialPageRoute(builder: (context) {
                        return NovelUserPage(
                          id: _novelStore.novel!.user.id,
                        );
                      }));
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text('Pre'),
                ),
                buildListTile(_novelStore.novelTextResponse!.seriesPrev),
                Divider(),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text('Next'),
                ),
                buildListTile(_novelStore.novelTextResponse!.seriesNext),
              ],
            ),
          );
        });
  }

  Widget buildListTile(TextNovel? series) {
    if (series == null || series.title == null || series.id == null)
      return ListTile(
        title: Text("no more"),
      );
    return ListTile(
      title: Text(series.title!),
      onTap: () {
        Navigator.of(context, rootNavigator: true)
            .pushReplacement(MaterialPageRoute(
                builder: (BuildContext context) => NovelViewerPage(
                      id: series.id!,
                      novelStore: NovelStore(series.id!, null),
                    )));
      },
    );
  }
}
