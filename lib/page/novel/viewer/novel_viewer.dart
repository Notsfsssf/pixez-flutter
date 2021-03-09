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
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:pixez/component/painter_avatar.dart';
import 'package:pixez/component/pixiv_image.dart';
import 'package:pixez/component/text_selection_toolbar.dart';
import 'package:pixez/i18n.dart';
import 'package:pixez/models/novel_recom_response.dart';
import 'package:pixez/page/novel/component/novel_bookmark_button.dart';
import 'package:pixez/page/novel/user/novel_user_page.dart';
import 'package:pixez/page/novel/viewer/image_text.dart';
import 'package:pixez/page/novel/viewer/novel_store.dart';
import 'package:share/share.dart';

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
    _controller?.dispose();
    super.dispose();
  }

  final double leading = 0.9;
  final double textLineHeight = 2;
  final double fontSize = 16;

  @override
  Widget build(BuildContext context) {
    return Observer(
      builder: (context) {
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
          return Scaffold(
            appBar: AppBar(
              elevation: 0.0,
              backgroundColor: Colors.transparent,
              actions: <Widget>[
                NovelBookmarkButton(
                  novel: _novelStore.novel!,
                ),
                IconButton(
                    icon: Icon(Icons.share),
                    onPressed: () {
                      Share.share(
                          "https://www.pixiv.net/novel/show.php?id=${widget.id}");
                    }),
                IconButton(
                  icon: Icon(Icons.more_vert),
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
                        child: PixivImage(_novelStore.novel!.imageUrls.medium))),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ExtendedText(
                    _novelStore.novelTextResponse!.novelText,
                    textSelectionControls: TranslateTextSelectionControls(),
                    selectionEnabled: true,
                    specialTextSpanBuilder: NovelSpecialTextSpanBuilder(),
                    style: Theme.of(context).textTheme.bodyText1,
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
                  title: Text(_novelStore.novel!.title ?? ""),
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

  Widget buildListTile(Novel? series) {
    if (series == null)
      return ListTile(
        title: Text("no more"),
      );
    return ListTile(
      title: Text(series.title ?? ""),
      onTap: () {
        Navigator.of(context, rootNavigator: true)
            .pushReplacement(MaterialPageRoute(
                builder: (BuildContext context) => NovelViewerPage(
                      id: series.id,
                      novelStore: NovelStore(series.id, series),
                    )));
      },
    );
  }
}
