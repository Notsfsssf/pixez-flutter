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

import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:mobx/mobx.dart';
import 'package:pixez/component/illust_card.dart';
import 'package:pixez/generated/l10n.dart';
import 'package:pixez/lighting/lighting_store.dart';
import 'package:pixez/main.dart';
import 'package:pixez/models/illust.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:waterfall_flow/waterfall_flow.dart';

class LightingList extends StatefulWidget {
  final FutureGet source;
  final Widget header;
  final bool isNested;

  const LightingList({
    Key key,
    @required this.source,
    this.header,
    this.isNested,
  }) : super(key: key);

  @override
  _LightingListState createState() => _LightingListState();
}

class _LightingListState extends State<LightingList> {
  LightingStore _store;
  bool _isNested;

  @override
  void didUpdateWidget(LightingList oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.source != widget.source) {
      _store.source = widget.source;
      _store.fetch();
      if (!_isNested && _store?.errorMessage == null)
        _refreshController?.position?.jumpTo(0.0);
    }
  }

  ReactionDisposer disposer;

  @override
  void initState() {
    _isNested = widget.isNested ?? false;
    _store = LightingStore(
      widget.source,
      _refreshController,
    );
    super.initState();
    _store.fetch();
  }

  @override
  void dispose() {
    _store?.dispose();
    super.dispose();
  }

  bool backToTopVisible = false;

  @override
  Widget build(BuildContext context) {
    return Observer(builder: (_) {
      return Container(
        child: Stack(
          children: <Widget>[
            Container(child: _buildContent(context)),
            Align(
              child: Visibility(
                visible: backToTopVisible,
                child: Opacity(
                  opacity: 0.5,
                  child: Container(
                    height: 24.0,
                    margin: EdgeInsets.only(bottom: 8.0),
                    child: IconButton(
                      icon: Icon(
                        Icons.arrow_drop_up_outlined,
                        size: 24,
                      ),
                      onPressed: () {
                        _refreshController.position.jumpTo(0);
                      },
                    ),
                  ),
                ),
              ),
              alignment: Alignment.bottomCenter,
            )
          ],
        ),
      );
    });
  }

  RefreshController _refreshController = RefreshController();

  CustomFooter _buildCustomFooter() {
    return CustomFooter(
      builder: (BuildContext context, LoadStatus mode) {
        Widget body;
        if (mode == LoadStatus.idle) {
          body = Text(I18n.of(context).pull_up_to_load_more);
        } else if (mode == LoadStatus.loading) {
          body = CircularProgressIndicator();
        } else if (mode == LoadStatus.failed) {
          body = Text(I18n.of(context).loading_failed_retry_message);
        } else if (mode == LoadStatus.canLoading) {
          body = Text(I18n.of(context).let_go_and_load_more);
        } else {
          body = Text(I18n.of(context).no_more_data);
        }
        return Container(
          height: 55.0,
          child: Center(child: body),
        );
      },
    );
  }

  bool okForUser(Illusts illust) {
    for (var t in muteStore.banTags) {
      for (var f in illust.tags) {
        if (f.name == t.name) return false;
      }
    }
    for (var j in muteStore.banUserIds) {
      if (j.userId == illust.user.id.toString()) {
        return false;
      }
    }
    for (var i in muteStore.banillusts)
      if (illust.id == i.id) {
        return false;
      }
    return true;
  }

  Widget _buildWithoutHeader(context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double itemWidth = (screenWidth / userSetting.crossCount.toDouble()) - 32.0;
    _store.iStores.removeWhere((element) => !okForUser(element.illusts));
    return NotificationListener<ScrollNotification>(
        onNotification: (ScrollNotification notification) {
          ScrollMetrics metrics = notification.metrics;
          if (backToTopVisible == metrics.atEdge && mounted) {
            setState(() {
              backToTopVisible = !backToTopVisible;
            });
          }
          return true;
        },
        child: SmartRefresher(
          enablePullDown: true,
          enablePullUp: true,
          header: (Platform.isAndroid)
              ? MaterialClassicHeader(
                  color: Theme.of(context).accentColor,
                  backgroundColor: Theme.of(context).cardColor,
                )
              : ClassicHeader(),
          footer: _buildCustomFooter(),
          controller: _refreshController,
          onRefresh: () {
            _store.fetch();
          },
          onLoading: () {
            _store.fetchNext();
          },
          child: WaterfallFlow.builder(
            padding: EdgeInsets.all(5.0),
            itemCount: _store.iStores.length,
            itemBuilder: (context, index) {
              return _buildItem(index, itemWidth);
            },
            gridDelegate: _buildGridDelegate(),
          ),
        ));
  }

  bool needToBan(Illusts illust) {
    for (var i in muteStore.banillusts) {
      if (i.illustId == illust.id.toString()) return true;
    }
    for (var j in muteStore.banUserIds) {
      if (j.userId == illust.user.id.toString()) return true;
    }
    for (var t in muteStore.banTags) {
      for (var f in illust.tags) {
        if (f.name == t.name) return true;
      }
    }
    return false;
  }

  Widget _buildContent(context) {
    return _store.errorMessage != null
        ? Container(
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
                      Text(':(', style: Theme.of(context).textTheme.headline4),
                ),
                FlatButton(
                    onPressed: () {
                      _store.fetch();
                    },
                    child: Text(I18n.of(context).retry)),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text('${_store.errorMessage}'),
                )
              ],
            ),
          )
        : _store.iStores.isNotEmpty
            ? (widget.header != null
                ? _buildWithHeader(context)
                : _buildWithoutHeader(context))
            : Container();
  }

  Widget _buildWithHeader(BuildContext context) {
    return NotificationListener<ScrollNotification>(
      onNotification: (ScrollNotification notification) {
        ScrollMetrics metrics = notification.metrics;
        if (backToTopVisible == metrics.atEdge && mounted) {
          setState(() {
            backToTopVisible = !backToTopVisible;
          });
        }
        return true;
      },
      child: SmartRefresher(
        enablePullDown: true,
        enablePullUp: true,
        header: (Platform.isAndroid)
            ? MaterialClassicHeader(
                color: Theme.of(context).accentColor,
                backgroundColor: Theme.of(context).cardColor,
              )
            : ClassicHeader(),
        footer: _buildCustomFooter(),
        controller: _refreshController,
        onRefresh: () {
          _store.fetch();
        },
        onLoading: () {
          _store.fetchNext();
        },
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Container(child: widget.header),
            ),
            SliverWaterfallFlow(
              gridDelegate: _buildGridDelegate(),
              delegate: _buildSliverChildBuilderDelegate(context),
            )
          ],
        ),
      ),
    );
  }

  SliverChildBuilderDelegate _buildSliverChildBuilderDelegate(
      BuildContext context) {
    double screenWidth = MediaQuery
        .of(context)
        .size
        .width;
    double itemWidth = (screenWidth / userSetting.crossCount.toDouble()) - 32.0;
    _store.iStores.removeWhere((element) => !okForUser(element.illusts));
    return SliverChildBuilderDelegate((BuildContext context, int index) {
      double radio = _store.iStores[index].illusts.height.toDouble() /
          _store.iStores[index].illusts.width.toDouble();
      double mainAxisExtent;
      if (radio > 3)
        mainAxisExtent = itemWidth;
      else
        mainAxisExtent = itemWidth * radio;
      return IllustCard(
        store: _store.iStores[index],
        iStores: _store.iStores,
        height: mainAxisExtent + 64.0,
        heroString: widget.hashCode.toString(),
      );
    }, childCount: _store.iStores.length);
  }

  SliverWaterfallFlowDelegateWithFixedCrossAxisCount _buildGridDelegate() {
    return SliverWaterfallFlowDelegateWithFixedCrossAxisCount(
      crossAxisCount: userSetting.crossCount,
      collectGarbage: (List<int> garbages) {
        garbages.forEach((index) {
          final provider = ExtendedNetworkImageProvider(
            _store.iStores[index].illusts.imageUrls.medium,
          );
          provider.evict();
        });
      },
    );
  }

  Widget _buildItem(int index, double itemWidth) {
    double radio = _store.iStores[index].illusts.height.toDouble() /
        _store.iStores[index].illusts.width.toDouble();
    double mainAxisExtent;
    if (radio > 3)
      mainAxisExtent = itemWidth;
    else
      mainAxisExtent = itemWidth * radio;
    return IllustCard(
      store: _store.iStores[index],
      iStores: _store.iStores,
      height: mainAxisExtent + 64.0,
      heroString: widget.hashCode.toString(),
    );
  }
}
