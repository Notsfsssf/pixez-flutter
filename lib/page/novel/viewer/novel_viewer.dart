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

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pixez/component/painter_avatar.dart';
import 'package:pixez/component/pixiv_image.dart';
import 'package:pixez/models/novel_recom_response.dart';
import 'package:pixez/page/novel/component/novel_bookmark_button.dart';
import 'package:pixez/page/novel/viewer/novel_store.dart';

class NovelViewerPage extends StatefulWidget {
  final int id;
  final Novel novel;

  const NovelViewerPage({Key key, @required this.id, @required this.novel})
      : super(key: key);

  @override
  _NovelViewerPageState createState() => _NovelViewerPageState();
}

class _NovelViewerPageState extends State<NovelViewerPage> {
  NovelStore _novelStore;
  @override
  void initState() {
    // TODO: implement initState
    _novelStore = NovelStore(widget.id);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var seriesNext = _novelStore.novelTextResponse.seriesNext;
    var seriesPrev = _novelStore.novelTextResponse.seriesPrev;
    return Scaffold(
      appBar: AppBar(
        elevation: 0.0,
        backgroundColor: Colors.transparent,
        actions: <Widget>[
          NovelBookmarkButton(
            novel: widget.novel,
          )
        ],
      ),
      extendBodyBehindAppBar: true,
      body: ListView(
        children: <Widget>[
          Container(
            height: MediaQuery.of(context).padding.top,
          ),
          Center(
              child: Container(
                  height: 160,
                  child: PixivImage(widget.novel.imageUrls.medium))),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: SelectableText(
              _novelStore.novelTextResponse.novelText,
              scrollPhysics: NeverScrollableScrollPhysics(),
            ),
          ),
          Container(
            child: ListTile(
              subtitle: Text(widget.novel.user.name),
              title: Text(widget.novel.title ?? ""),
              leading: PainterAvatar(
                url: widget.novel.user.profileImageUrls.medium,
                id: widget.novel.user.id,
                onTap: () {},
              ),
            ),
          ),
          buildListTile(seriesPrev),
          buildListTile(seriesNext),
          Container(
            height: MediaQuery.of(context).padding.bottom,
          )
        ],
      ),
    );
  }

  Widget buildListTile(Novel series) {
    return ListTile(
      title: Text(series.title ?? ""),
      onTap: () {
        Navigator.of(context, rootNavigator: true)
            .pushReplacement(MaterialPageRoute(
                builder: (BuildContext context) => NovelViewerPage(
                      id: series.id,
                      novel: series,
                    )));
      },
    );
  }
}
