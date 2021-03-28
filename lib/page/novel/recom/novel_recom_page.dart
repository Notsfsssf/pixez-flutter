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

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:pixez/component/pixiv_image.dart';
import 'package:pixez/i18n.dart';
import 'package:pixez/models/novel_recom_response.dart';
import 'package:pixez/network/api_client.dart';
import 'package:pixez/page/novel/component/novel_bookmark_button.dart';
import 'package:pixez/page/novel/component/novel_lighting_store.dart';
import 'package:pixez/page/novel/viewer/novel_viewer.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class NovelRecomPage extends StatefulWidget {
  @override
  _NovelRecomPageState createState() => _NovelRecomPageState();
}

class _NovelRecomPageState extends State<NovelRecomPage> {
  late NovelLightingStore _store;
  late RefreshController _easyRefreshController;

  @override
  void initState() {
    _easyRefreshController = RefreshController(initialRefresh: true);
    _store = NovelLightingStore(
        () => apiClient.getNovelRecommended(), _easyRefreshController);
    super.initState();
  }

  @override
  void dispose() {
    _easyRefreshController.dispose();
    super.dispose();
  }

  Widget _buildFirstRow(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Container(
            child: Padding(
              child: Text(
                I18n.of(context).recommend,
                style: TextStyle(
                    color: Theme.of(context).textTheme.headline6!.color),
              ),
              padding: EdgeInsets.only(left: 8.0, bottom: 10.0),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Observer(builder: (context) {
      return SmartRefresher(
        enablePullDown: true,
        onRefresh: () => _store.fetch(),
        onLoading: () => _store.next(),
        enablePullUp: true,
        controller: _easyRefreshController,
        header: Platform.isAndroid
            ? MaterialClassicHeader(
                color: Theme.of(context).accentColor,
              )
            : ClassicHeader(),
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              elevation: 0.0,
              titleSpacing: 0.0,
              automaticallyImplyLeading: false,
              backgroundColor: Colors.transparent,
              title: _buildFirstRow(context),
            ),
            if (_store.novels.isNotEmpty)
              SliverList(
                  delegate: SliverChildBuilderDelegate(
                      (BuildContext context, int index) {
                Novel novel = _store.novels[index].novel!;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: InkWell(
                    onTap: () {
                      Navigator.of(context, rootNavigator: true).push(
                          MaterialPageRoute(
                              builder: (BuildContext context) =>
                                  NovelViewerPage(
                                    id: novel.id,
                                    novelStore: _store.novels[index],
                                  )));
                    },
                    child: Card(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            flex: 5,
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 8.0),
                                  child: PixivImage(
                                    novel.imageUrls.medium,
                                    width: 80,
                                  ),
                                ),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.only(
                                            top: 8.0, left: 8.0),
                                        child: Text(
                                          novel.title,
                                          overflow: TextOverflow.ellipsis,
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyText1,
                                          maxLines: 3,
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8.0),
                                        child: Text(
                                          novel.user.name,
                                          maxLines: 1,
                                          style: Theme.of(context)
                                              .textTheme
                                              .caption!
                                              .copyWith(
                                                  color: Theme.of(context)
                                                      .accentColor),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8.0),
                                        child: Wrap(
                                          crossAxisAlignment:
                                              WrapCrossAlignment.center,
                                          spacing: 2, // gap between adjacent chips
                                          runSpacing: 0,
                                          children: [
                                            for (var f in novel.tags)
                                              Text(
                                                f.name,
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .caption,
                                              )
                                          ],
                                        ),
                                      ),
                                      Container(
                                        height: 8.0,
                                      )
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: Column(
                              mainAxisSize: MainAxisSize.max,
                              children: [
                                NovelBookmarkButton(novel: novel),
                                Text('${novel.totalBookmarks}',
                                    style: Theme.of(context).textTheme.caption)
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                );
              }, childCount: _store.novels.length)),
          ],
        ),
      );
    });
  }
}
