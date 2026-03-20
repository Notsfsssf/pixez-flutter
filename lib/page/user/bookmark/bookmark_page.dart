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
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:pixez/component/illust_card.dart';
import 'package:pixez/component/pixez_default_header.dart';
import 'package:pixez/component/sort_group.dart';
import 'package:pixez/exts.dart';
import 'package:pixez/i18n.dart';
import 'package:pixez/lighting/lighting_page.dart';
import 'package:pixez/lighting/lighting_store.dart';
import 'package:pixez/main.dart';
import 'package:pixez/models/illust.dart';
import 'package:pixez/network/api_client.dart';
import 'package:pixez/page/user/bookmark/bookmark_search.dart'
    show BookMarkSearchView;
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
  static const _searchCardAnimationDuration = Duration(milliseconds: 220);

  late LightSource futureGet;
  String restrict = 'public';
  late LightingListController _lightingController;
  late ScrollController _scrollController;
  late StreamSubscription<String> subscription;
  String? currentTag;

  // toggle bookmark search card display
  bool _showSearch = false;

  // [BOOKMARK SEARCH MAIN STATE] current bookmark search tags
  List<String> _searchTags = [];

  // a ref of the inner lightingStore
  LightingStore? get _lightingStore => _lightingController.store;

  // is in continuous auto fetching state
  bool _isDeepSearching = false;

  // performing a fetch
  bool _isDeepSearchLoading = false;

  // ref to the the ongoing fetch
  Future<void>? _deepSearchTask;

  void _startDeepSearch() {
    if (_lightingStore == null || _isDeepSearching) return;
    setState(() {
      _isDeepSearching = true;
    });
    _deepSearchTask = _runDeepSearch();
  }

  Future<void> _runDeepSearch() async {
    // Continuous search keeps paging until the source runs out, the user stops
    // it, or a page request fails.
    while (_isDeepSearching &&
        _lightingStore!.nextUrl != null &&
        _lightingStore!.nextUrl!.isNotEmpty) {
      if (!mounted) break;
      setState(() {
        _isDeepSearchLoading = true;
      });
      final success = await _lightingStore!.fetchNext();
      if (!mounted) break;
      setState(() {
        _isDeepSearchLoading = false;
      });

      if (!success) {
        setState(() {
          _isDeepSearching = false;
        });
        break;
      }

      if (_isDeepSearching) {
        // The request interval is user-configurable to balance speed and rate
        // limiting risk during continuous bookmark scanning.
        await Future.delayed(
          Duration(milliseconds: userSetting.bookmarkAutoRequestInterval),
        );
      }
    }

    if (mounted) {
      setState(() {
        _isDeepSearching = false;
        _isDeepSearchLoading = false;
      });
    }
    _deepSearchTask = null;
  }

  Future<void> _stopDeepSearch() async {
    if (_isDeepSearching && mounted) {
      setState(() {
        _isDeepSearching = false;
      });
    } else {
      _isDeepSearching = false;
    }
    await _deepSearchTask;
  }

  Future<void> _switchBookmarkSource({
    required String nextRestrict,
    String? nextTag,
  }) async {
    // Source changes must stop the current continuous search first so old page
    // requests do not continue against a stale bookmark query.
    await _stopDeepSearch();
    if (!mounted) {
      return;
    }
    setState(() {
      restrict = nextRestrict;
      currentTag = nextTag;
      futureGet = ApiForceSource(
        futureGet: (bool e) =>
            apiClient.getBookmarksIllust(widget.id, nextRestrict, nextTag),
      );
    });
  }

  bool _filterIllust(Illusts illust) {
    if (_searchTags.isEmpty) return true;
    final normalizedTitle = illust.title.toLowerCase();

    return _searchTags.every((searchTag) {
      final keyword = searchTag.toLowerCase();
      if (normalizedTitle.contains(keyword)) {
        return true;
      }

      for (var tag in illust.tags) {
        if (tag.name.toLowerCase().contains(keyword)) {
          return true;
        }
        if (tag.translatedName != null &&
            tag.translatedName!.toLowerCase().contains(keyword)) {
          return true;
        }
      }

      return false;
    });
  }

  // iStores is a mobx observable 
  // these two value will be observed.
  int get _fetchedIllustCount => _lightingStore?.iStores.length ?? 0;
  int get _matchedIllustCount {
    final store = _lightingStore;
    if (store == null) {
      return 0;
    }
    return store.iStores
        .where((element) => _filterIllust(element.illusts!))
        .length;
  }

  @override
  void initState() {
    _lightingController = LightingListController();
    _scrollController = ScrollController();
    restrict = widget.restrict;
    futureGet = ApiForceSource(
      futureGet: (e) => apiClient.getBookmarksIllust(widget.id, restrict, null),
    );
    super.initState();
    subscription = topStore.topStream.listen((event) {
      if (event == "302") {
        if (_scrollController.hasClients) _scrollController.position.jumpTo(0);
      }
    });
  }

  @override
  void dispose() {
    _isDeepSearching = false;
    _deepSearchTask = null;
    subscription.cancel();
    _lightingController.dispose();
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
              // Reserve the search card's vertical space before the card itself
              // fades/sizes in, which avoids the grid jumping abruptly.
              header: AnimatedContainer(
                duration: _searchCardAnimationDuration,
                curve: Curves.easeOutCubic,
                height: _showSearch ? 180 : 45,
              ),
              filter: _filterIllust,
              controller: _lightingController,
              enableRefresh: !_isDeepSearching,
              enableLoad: !_isDeepSearching,
              showContinuousLoadHint: _isDeepSearching,
            ),
            buildTopChip(context),
          ],
        );
      }
      return LightingList(
        isNested: widget.isNested,
        scrollController: _scrollController,
        source: futureGet,
        filter: _filterIllust,
        controller: _lightingController,
        enableRefresh: !_isDeepSearching,
        enableLoad: !_isDeepSearching,
        showContinuousLoadHint: _isDeepSearching,
      );
    } else {
      return Container();
    }
  }

  Widget buildTopChip(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SortGroup(
                children: [I18n.of(context).public, I18n.of(context).private],
                onChange: (index) async {
                  await _switchBookmarkSource(
                    nextRestrict: index == 0 ? 'public' : 'private',
                    nextTag: currentTag,
                  );
                },
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: GestureDetector(
                  onTap: () async {
                    await _stopDeepSearch();
                    final result = await Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) =>
                            UserBookmarkTagPage(currentTag: currentTag),
                      ),
                    );
                    if (result != null) {
                      String? tag = result['tag'];
                      String restrict = result['restrict'];
                      await _switchBookmarkSource(
                        nextRestrict: restrict,
                        nextTag: tag,
                      );
                    }
                  },
                  behavior: HitTestBehavior.opaque,
                  child: Chip(
                    label: Row(
                      children: [
                        Icon(Icons.tag, size: 18),
                        if (currentTag != null)
                          Padding(
                            padding: const EdgeInsets.only(left: 8.0),
                            child: Text(
                              currentTag!,
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ),
                      ],
                    ),
                    backgroundColor: Theme.of(context).cardColor,
                    elevation: 4.0,
                    padding: EdgeInsets.all(0.0),
                  ),
                ),
              ),
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () async {
                  if (!mounted) {
                    return;
                  }
                  setState(() {
                    _showSearch = !_showSearch;
                  });
                },
                child: Chip(
                  label: Icon(
                    _showSearch ? Icons.search_off : Icons.search,
                    color:
                        Theme.of(context).textTheme.bodySmall?.color ??
                        Colors.grey,
                    size: 18,
                  ),
                  backgroundColor: Theme.of(context).cardColor,
                  elevation: 4.0,
                  padding: EdgeInsets.all(0.0),
                ),
              ),
            ],
          ),
          AnimatedSwitcher(
            duration: _searchCardAnimationDuration,
            switchInCurve: Curves.easeOutCubic,
            switchOutCurve: Curves.easeInCubic,
            transitionBuilder: (child, animation) {
              // Fade + vertical size keeps the search panel expansion feeling
              // lightweight while matching the reserved header height above.
              return FadeTransition(
                opacity: animation,
                child: SizeTransition(
                  sizeFactor: animation,
                  axisAlignment: -1,
                  child: child,
                ),
              );
            },
            child: _showSearch
                ? Padding(
                    key: const ValueKey('bookmark-search-card'),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 8.0,
                    ),
                    child: Card(
                      child: Column(
                        children: [
                          BookMarkSearchView(
                            tags: _searchTags,
                            onChange: (tags) {
                              setState(() {
                                _searchTags = tags;
                              });
                            },
                          ),
                          const Divider(height: 1),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16.0,
                              vertical: 4.0,
                            ),
                            child: AnimatedBuilder(
                              animation: _lightingController,
                              builder: (_, __) {
                                return Observer(
                                  builder: (_) {
                                    return Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          I18n.of(context).bookmarkDeepSearchStats(
                                            _matchedIllustCount.toString(),
                                            _fetchedIllustCount.toString(),
                                          ),
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodySmall,
                                        ),
                                        Row(
                                          children: [
                                            if (_isDeepSearchLoading)
                                              const Padding(
                                                padding: EdgeInsets.only(
                                                  right: 8.0,
                                                ),
                                                child: SizedBox(
                                                  width: 16,
                                                  height: 16,
                                                  child:
                                                      CircularProgressIndicator(
                                                    strokeWidth: 2,
                                                  ),
                                                ),
                                              ),
                                            Switch(
                                              value: _isDeepSearching,
                                              onChanged: (val) async {
                                                if (val) {
                                                  _startDeepSearch();
                                                } else {
                                                  await _stopDeepSearch();
                                                }
                                              },
                                            ),
                                          ],
                                        ),
                                      ],
                                    );
                                  },
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : const SizedBox(key: ValueKey('bookmark-search-empty')),
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

  const BookMarkNestedPage({
    Key? key,
    required this.id,
    required this.store,
    required this.portal,
  }) : super(key: key);

  @override
  State<BookMarkNestedPage> createState() => _BookMarkNestedPageState();
}

class _BookMarkNestedPageState extends State<BookMarkNestedPage> {
  late ScrollController _scrollController;
  late EasyRefreshController _easyRefreshController;
  late LightingStore _store;
  String restrict = 'public';
  String? currentTag;

  @override
  void initState() {
    _scrollController = ScrollController();
    _easyRefreshController = EasyRefreshController(
      controlFinishRefresh: true,
      controlFinishLoad: true,
    );
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
            header: PixezDefault.header(
              context,
              position: IndicatorPosition.locator,
              safeArea: false,
            ),
            footer: PixezDefault.footer(
              context,
              position: IndicatorPosition.locator,
            ),
            childBuilder: (context, phy) {
              return Observer(
                builder: (_) {
                  final userIsMe =
                      accountStore.now != null &&
                      accountStore.now!.userId == widget.id.toString();
                  return CustomScrollView(
                    physics: phy,
                    key: PageStorageKey<String>(widget.portal),
                    slivers: [
                      userIsMe
                          ? SliverPinnedOverlapInjector(
                              handle:
                                  NestedScrollView.sliverOverlapAbsorberHandleFor(
                                    context,
                                  ),
                            )
                          : SliverOverlapInjector(
                              handle:
                                  NestedScrollView.sliverOverlapAbsorberHandleFor(
                                    context,
                                  ),
                            ),
                      if (userIsMe)
                        SliverPersistentHeader(
                          delegate: SliverChipDelegate(
                            Container(
                              child: Center(child: buildTopChip(context)),
                            ),
                          ),
                          pinned: true,
                        ),
                      const HeaderLocator.sliver(),
                      if (_store.refreshing && _store.iStores.isEmpty)
                        SliverToBoxAdapter(
                          child: Container(
                            height: 200,
                            child: Center(child: CircularProgressIndicator()),
                          ),
                        ),
                      SliverWaterfallFlow(
                        gridDelegate: _buildGridDelegate(),
                        delegate: _buildSliverChildBuilderDelegate(context),
                      ),
                      const FooterLocator.sliver(),
                    ],
                  );
                },
              );
            },
          );
        },
      ),
    );
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
          Container(height: 50),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              ':(',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ),
          TextButton(
            onPressed: () {
              _store.fetch(force: true);
            },
            child: Text(I18n.of(context).retry),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              (_store.errorMessage?.contains("400") == true
                  ? '${I18n.of(context).error_400_hint}\n ${_store.errorMessage}'
                  : '${_store.errorMessage}'),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Observer(
      builder: (_) {
        return _buildContent(context);
      },
    );
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
    BuildContext context,
  ) {
    _store.iStores.removeWhere(
      (element) => element.illusts!.hateByUser(ai: false),
    );
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
                    widget.id,
                    restrict = 'public',
                    currentTag,
                  ),
                );
                _store.fetch();
              } else if (index == 1) {
                _store.source = ApiForceSource(
                  futureGet: (bool e) => apiClient.getBookmarksIllust(
                    widget.id,
                    restrict = 'private',
                    currentTag,
                  ),
                );
                _store.fetch();
              }
            },
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: InkWell(
              onTap: () async {
                final result = await Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => UserBookmarkTagPage()),
                );
                if (result != null) {
                  String? tag = result['tag'];
                  String restrict = result['restrict'];
                  setState(() {
                    currentTag = tag;
                    _store.source = ApiForceSource(
                      futureGet: (bool e) => apiClient.getBookmarksIllust(
                        widget.id,
                        restrict,
                        tag,
                      ),
                    );
                    _store.fetch();
                  });
                }
              },
              child: Chip(
                label: Row(
                  children: [
                    Icon(Icons.sort),
                    Text(currentTag ?? I18n.of(context).all),
                  ],
                ),
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
