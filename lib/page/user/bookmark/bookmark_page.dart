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

import 'dart:async';
import 'dart:math';

import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:pixez/component/illust_card.dart';
import 'package:pixez/component/pixez_default_header.dart';
import 'package:pixez/component/sort_group.dart';
import 'package:pixez/er/leader.dart';
import 'package:pixez/exts.dart';
import 'package:pixez/i18n.dart';
import 'package:pixez/lighting/lighting_page.dart';
import 'package:pixez/lighting/lighting_store.dart';
import 'package:pixez/main.dart';
import 'package:pixez/network/api_client.dart';
import 'package:pixez/page/river/river_page.dart';
import 'package:pixez/page/user/bookmark/tag/user_bookmark_tag_page.dart';
import 'package:pixez/page/user/works/works_page.dart';
import 'package:waterfall_flow/waterfall_flow.dart';

class BookmarkPage extends StatefulWidget {
  final int id;
  final String restrict;
  final bool isNested;

  const BookmarkPage({
    Key? key,
    required this.id,
    this.restrict = "public",
    this.isNested = false,
  }) : super(key: key);

  @override
  _BookmarkPageState createState() => _BookmarkPageState();
}

class _BookmarkPageState extends State<BookmarkPage> {
  late LightSource futureGet;
  String restrict = 'public';
  late ScrollController _scrollController;
  late StreamSubscription<String> subscription;

  @override
  void initState() {
    _scrollController = ScrollController();
    restrict = widget.restrict;
    futureGet = ApiForceSource(
        futureGet: (e) =>
            apiClient.getBookmarksIllust(widget.id, restrict, null));
    super.initState();
    subscription = topStore.topStream.listen((event) {
      if (event == "302") {
        if (_scrollController.hasClients) _scrollController.position.jumpTo(0);
      }
    });
  }

  @override
  void dispose() {
    subscription.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (accountStore.now != null) {
      if (int.parse(accountStore.now!.userId) == widget.id) {
        return Stack(
          children: [
            LightingList(
              source: futureGet,
              scrollController: _scrollController,
              isNested: widget.isNested,
              header: Container(
                height: 45,
              ),
            ),
            buildTopChip(context)
          ],
        );
      }
      return LightingList(
        isNested: widget.isNested,
        scrollController: _scrollController,
        source: futureGet,
      );
    } else {
      return Container();
    }
  }

  Widget buildTopChip(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SortGroup(
            children: [I18n.of(context).public, I18n.of(context).private],
            onChange: (index) {
              if (index == 0)
                setState(() {
                  futureGet = ApiForceSource(
                      futureGet: (bool e) => apiClient.getBookmarksIllust(
                          widget.id, restrict = 'public', null));
                });
              if (index == 1)
                setState(() {
                  futureGet = ApiForceSource(
                      futureGet: (bool e) => apiClient.getBookmarksIllust(
                          widget.id, restrict = 'private', null));
                });
            },
          ),
          if (kDebugMode)
            Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: IconButton(
                onPressed: () {
                  Leader.push(context, RiverPage());
                },
                icon: Icon(Icons.last_page),
              ),
            ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: InkWell(
              onTap: () async {
                final result = await Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => UserBookmarkTagPage()));
                if (result != null) {
                  String? tag = result['tag'];
                  String restrict = result['restrict'];
                  setState(() {
                    futureGet = ApiForceSource(
                        futureGet: (bool e) => apiClient.getBookmarksIllust(
                            widget.id, restrict, tag));
                  });
                }
              },
              child: Chip(
                label: Icon(Icons.sort),
                backgroundColor: Theme.of(context).cardColor,
                elevation: 4.0,
                padding: EdgeInsets.all(0.0),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class BookMarkNestedPage extends StatefulWidget {
  final int id;
  final LightingStore store;
  final String portal;

  const BookMarkNestedPage(
      {Key? key, required this.id, required this.store, required this.portal})
      : super(key: key);

  @override
  State<BookMarkNestedPage> createState() => _BookMarkNestedPageState();
}

class _BookMarkNestedPageState extends State<BookMarkNestedPage> {
  late ScrollController _scrollController;
  late EasyRefreshController _easyRefreshController;
  late LightingStore _store;
  String restrict = 'public';

  @override
  void initState() {
    _scrollController = ScrollController();
    _easyRefreshController = EasyRefreshController(
        controlFinishRefresh: true, controlFinishLoad: true);
    _store = widget.store;
    _store.easyRefreshController = _easyRefreshController;
    super.initState();
    _store.fetch();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _easyRefreshController.dispose();
    super.dispose();
  }

  Widget _buildWorks(BuildContext context) {
    return SafeArea(
        top: false,
        bottom: false,
        child: Builder(
          builder: (BuildContext context) {
            return EasyRefresh.builder(
                controller: _easyRefreshController,
                onLoad: () {
                  _store.fetchNext();
                },
                onRefresh: () {
                  _store.fetch(force: true);
                },
                header: PixezDefault.header(context,
                    position: IndicatorPosition.locator, safeArea: false),
                footer: PixezDefault.footer(
                  context,
                  position: IndicatorPosition.locator,
                ),
                childBuilder: (context, phy) {
                  return Observer(builder: (_) {
                    final userIsMe = accountStore.now != null &&
                        accountStore.now!.userId == widget.id.toString();
                    return CustomScrollView(
                      physics: phy,
                      key: PageStorageKey<String>(widget.portal),
                      slivers: [
                        userIsMe
                            ? SliverPinnedOverlapInjector(
                                handle: NestedScrollView
                                    .sliverOverlapAbsorberHandleFor(context),
                              )
                            : SliverOverlapInjector(
                                handle: NestedScrollView
                                    .sliverOverlapAbsorberHandleFor(context),
                              ),
                        if (userIsMe)
                          SliverPersistentHeader(
                              delegate: SliverChipDelegate(Container(
                                child: Center(
                                  child: buildTopChip(context),
                                ),
                              )),
                              pinned: true),
                        const HeaderLocator.sliver(),
                        if (_store.refreshing && _store.iStores.isEmpty)
                          SliverToBoxAdapter(
                            child: Container(
                              height: 200,
                              child: Center(
                                child: CircularProgressIndicator(),
                              ),
                            ),
                          ),
                        SliverWaterfallFlow(
                          gridDelegate: _buildGridDelegate(),
                          delegate: _buildSliverChildBuilderDelegate(context),
                        ),
                        const FooterLocator.sliver(),
                      ],
                    );
                  });
                });
          },
        ));
  }

  Widget _buildContent(context) {
    return _store.errorMessage != null && _store.iStores.isEmpty
        ? _buildErrorContent(context)
        : _buildWorks(context);
  }

  Widget _buildErrorContent(context) {
    return Container(
      child: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Container(
            height: 50,
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child:
                Text(':(', style: Theme.of(context).textTheme.headlineMedium),
          ),
          TextButton(
              onPressed: () {
                _store.fetch(force: true);
              },
              child: Text(I18n.of(context).retry)),
          Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                (_store.errorMessage?.contains("400") == true
                    ? '${I18n.of(context).error_400_hint}\n ${_store.errorMessage}'
                    : '${_store.errorMessage}'),
              ))
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Observer(builder: (_) {
      return _buildContent(context);
    });
  }

  SliverWaterfallFlowDelegate _buildGridDelegate() {
    var count = 2;
    if (userSetting.crossAdapt) {
      count = _buildSliderValue();
    } else {
      count = (MediaQuery.of(context).orientation == Orientation.portrait)
          ? userSetting.crossCount
          : userSetting.hCrossCount;
    }
    return SliverWaterfallFlowDelegateWithFixedCrossAxisCount(
      crossAxisCount: count,
    );
  }

  SliverChildBuilderDelegate _buildSliverChildBuilderDelegate(
      BuildContext context) {
    _store.iStores
        .removeWhere((element) => element.illusts!.hateByUser(ai: false));
    return SliverChildBuilderDelegate((BuildContext context, int index) {
      return IllustCard(
        lightingStore: _store,
        store: _store.iStores[index],
        iStores: _store.iStores,
      );
    }, childCount: _store.iStores.length);
  }

  int _buildSliderValue() {
    final currentValue =
        (MediaQuery.of(context).orientation == Orientation.portrait
                ? userSetting.crossAdapterWidth
                : userSetting.hCrossAdapterWidth)
            .toDouble();
    var nowAdaptWidth = max(currentValue, 50.0);
    nowAdaptWidth = min(nowAdaptWidth, 2160.0);
    final screenWidth = MediaQuery.of(context).size.width;
    final result = max(screenWidth / nowAdaptWidth, 1.0).toInt();
    return result;
  }

  Widget buildTopChip(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SortGroup(
            children: [I18n.of(context).public, I18n.of(context).private],
            onChange: (index) {
              if (index == 0) {
                _store.source = ApiForceSource(
                    futureGet: (bool e) => apiClient.getBookmarksIllust(
                        widget.id, restrict = 'public', null));
                _store.fetch();
              } else if (index == 1) {
                _store.source = ApiForceSource(
                    futureGet: (bool e) => apiClient.getBookmarksIllust(
                        widget.id, restrict = 'private', null));
                _store.fetch();
              }
            },
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: InkWell(
              onTap: () async {
                final result = await Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => UserBookmarkTagPage()));
                if (result != null) {
                  String? tag = result['tag'];
                  String restrict = result['restrict'];
                  _store.source = ApiForceSource(
                      futureGet: (bool e) => apiClient.getBookmarksIllust(
                          widget.id, restrict, tag));
                  _store.fetch();
                }
              },
              child: Chip(
                label: Icon(Icons.sort),
                backgroundColor: Theme.of(context).cardColor,
                elevation: 4.0,
                padding: EdgeInsets.all(0.0),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
