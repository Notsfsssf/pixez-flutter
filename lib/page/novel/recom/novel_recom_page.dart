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

import 'package:easy_refresh/easy_refresh.dart';
import 'package:pixez/component/pixez_default_header.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:pixez/component/pixiv_image.dart';
import 'package:pixez/i18n.dart';
import 'package:pixez/network/api_client.dart';
import 'package:pixez/page/novel/component/novel_bookmark_button.dart';
import 'package:pixez/page/novel/component/novel_lighting_store.dart';
import 'package:pixez/page/novel/viewer/novel_store.dart';
import 'package:pixez/page/novel/viewer/novel_viewer.dart';
import 'package:pixez/utils/haptic_util.dart';

class NovelRecomPage extends StatefulWidget {
  @override
  _NovelRecomPageState createState() => _NovelRecomPageState();
}

class _NovelRecomPageState extends State<NovelRecomPage>
    with AutomaticKeepAliveClientMixin {
  late NovelLightingStore _store;
  late EasyRefreshController _easyRefreshController;

  @override
  void initState() {
    _easyRefreshController = EasyRefreshController(
        controlFinishLoad: true, controlFinishRefresh: true);
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
                    color: Theme.of(context).textTheme.titleLarge!.color),
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
    super.build(context);
    return EasyRefresh.builder(
      header: PixezDefault.header(context),
      onRefresh: () => _store.fetch(),
      onLoad: () => _store.next(),
      controller: _easyRefreshController,
      callRefreshOverOffset: 10,
      refreshOnStart: true,
      childBuilder: (context, physics) => Observer(builder: (context) {
        return CustomScrollView(
          physics: physics,
          slivers: [
            SliverAppBar(
              elevation: 0.0,
              titleSpacing: 0.0,
              automaticallyImplyLeading: false,
              backgroundColor: Colors.transparent,
              title: _buildFirstRow(context),
            ),
            if (_store.errorMessage != null)
              _buildErrorSliver(context)
            else if (_store.novels.isNotEmpty)
              _buildSliverList()
            else
              _buildLoadingSliver(context),
          ],
        );
      }),
    );
  }

  /// 刷新失败时给出错误页和重试按钮，而不是继续显示旧内容，
  /// 否则用户看到"下拉刷新转完圈什么都没变"，无法分辨是不是出错。
  Widget _buildErrorSliver(BuildContext context) {
    return SliverFillRemaining(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(8.0),
              child:
                  Text(':(', style: Theme.of(context).textTheme.headlineMedium),
            ),
            TextButton(
                onPressed: () {
                  _easyRefreshController.callRefresh();
                },
                child: Text(I18n.of(context).retry)),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text('${_store.errorMessage}'),
            )
          ],
        ),
      ),
    );
  }

  /// 首屏 / 刷新中的占位，避免列表为空时整个页面一片空白。
  Widget _buildLoadingSliver(BuildContext context) {
    return SliverFillRemaining(
      child: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  SliverList _buildSliverList() {
    // 屏蔽项已经在 NovelLightingStore 里过滤掉了，这里不要再对
    // 被观察列表做 removeWhere（build 期间修改 ObservableList 是反模式）。
    return SliverList(
        delegate: SliverChildBuilderDelegate((BuildContext context, int index) {
      return _buildItem(context, _store.novels[index]);
    }, childCount: _store.novels.length));
  }

  Widget _buildItem(BuildContext context, NovelStore novelStore) {
    final novel = novelStore.novel!;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: InkWell(
        onTap: () {
          HapticUtil.selectionClick();
          Navigator.of(context, rootNavigator: true).push(MaterialPageRoute(
              builder: (BuildContext context) => NovelViewerPage(
                    id: novel.id,
                    novelStore: novelStore,
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
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: PixivImage(
                        novel.imageUrls.medium,
                        width: 80,
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0, left: 8.0),
                            child: Text(
                              novel.title,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.bodyLarge,
                              maxLines: 3,
                            ),
                          ),
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 8.0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  novel.user.name,
                                  maxLines: 1,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall!
                                      .copyWith(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .secondary),
                                ),
                                Padding(
                                  padding: EdgeInsets.only(left: 8),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.article,
                                        size: 12,
                                        color: Theme.of(context)
                                            .textTheme
                                            .labelSmall!
                                            .color,
                                      ),
                                      SizedBox(
                                        width: 2,
                                      ),
                                      Text(
                                        '${novel.textLength}',
                                        style: Theme.of(context)
                                            .textTheme
                                            .labelSmall,
                                      )
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 8.0),
                            child: Wrap(
                              crossAxisAlignment: WrapCrossAlignment.center,
                              spacing: 2, // gap between adjacent chips
                              runSpacing: 0,
                              children: [
                                for (var f in novel.tags)
                                  Text(
                                    f.name,
                                    style:
                                        Theme.of(context).textTheme.bodySmall,
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
                        style: Theme.of(context).textTheme.bodySmall)
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
