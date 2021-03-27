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
import 'dart:io';

import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:pixez/component/illust_card.dart';
import 'package:pixez/component/spotlight_card.dart';
import 'package:pixez/exts.dart';
import 'package:pixez/i18n.dart';
import 'package:pixez/lighting/lighting_store.dart';
import 'package:pixez/main.dart';
import 'package:pixez/network/api_client.dart';
import 'package:pixez/page/hello/recom/recom_user_road.dart';
import 'package:pixez/page/hello/recom/recom_user_store.dart';
import 'package:pixez/page/hello/recom/spotlight_store.dart';
import 'package:pixez/page/spotlight/spotlight_page.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:waterfall_flow/waterfall_flow.dart';

class RecomSpolightPage extends StatefulWidget {
  final LightingStore? lightingStore;

  RecomSpolightPage({Key? key, this.lightingStore}) : super(key: key);

  @override
  _RecomSpolightPageState createState() => _RecomSpolightPageState();
}

class _RecomSpolightPageState extends State<RecomSpolightPage>
    with AutomaticKeepAliveClientMixin {
  late SpotlightStore spotlightStore;
  late LightingStore _lightingStore;
  late RecomUserStore _recomUserStore;
  late StreamSubscription<String> subscription;
  late RefreshController _easyRefreshController;

  @override
  void dispose() {
    subscription.cancel();
    super.dispose();
  }

  @override
  void initState() {
    _easyRefreshController = RefreshController(initialRefresh: true);
    _recomUserStore = RecomUserStore();
    spotlightStore = SpotlightStore(null);
    _lightingStore = widget.lightingStore ??
        LightingStore(() => apiClient.getRecommend(), _easyRefreshController);
    if (widget.lightingStore != null) {
      _lightingStore.controller = _easyRefreshController;
    }
    super.initState();
    subscription = topStore.topStream.listen((event) {
      if (event == "100") {
        _easyRefreshController.position?.jumpTo(0);
      }
    });
  }

  Future<void> fetchT() async {
    await spotlightStore.fetch();
    await _lightingStore.fetch();
    await _recomUserStore.fetch();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return buildEasyRefresh(context);
  }

  bool backToTopVisible = false;

  Widget buildEasyRefresh(BuildContext context) {
    return Observer(builder: (_) {
      return Stack(
        children: [
          NotificationListener<ScrollNotification>(
            onNotification: (ScrollNotification notification) {
              ScrollMetrics metrics = notification.metrics;
              if (backToTopVisible == metrics.atEdge && mounted) {
                setState(() {
                  backToTopVisible = !backToTopVisible;
                });
              }
              return true;
            },
            child: NestedScrollView(
              body: SmartRefresher(
                controller: _easyRefreshController,
                enablePullDown: true,
                enablePullUp: true,
                header: (Platform.isAndroid)
                    ? MaterialClassicHeader(
                        color: Theme.of(context).accentColor,
                      )
                    : ClassicHeader(),
                footer: _buildCustomFooter(),
                onRefresh: () async {
                  await fetchT();
                },
                onLoading: () async {
                  await _lightingStore.fetchNext();
                },
                child: _buildWaterFall(),
              ),
              headerSliverBuilder:
                  (BuildContext context, bool innerBoxIsScrolled) {
                return [
                  SliverAppBar(
                    elevation: 0.0,
                    titleSpacing: 0.0,
                    automaticallyImplyLeading: false,
                    backgroundColor: Colors.transparent,
                    title: _buildFirstRow(context),
                  )
                ];
              },
            ),
          ),
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
                      _easyRefreshController.position?.jumpTo(0);
                    },
                  ),
                ),
              ),
            ),
            alignment: Alignment.bottomCenter,
          )
        ],
      );
    });
  }

  CustomFooter _buildCustomFooter() {
    return CustomFooter(
      builder: (BuildContext context, LoadStatus? mode) {
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

  Widget _buildWaterFall() {
    double screanWidth = MediaQuery.of(context).size.width;
    double itemWidth = (screanWidth / userSetting.crossCount.toDouble()) - 32.0;
    _lightingStore.iStores
        .removeWhere((element) => element.illusts!.hateByUser());
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: _buildSpotlightContainer(),
        ),
        SliverToBoxAdapter(
          child: _buildSecondRow(context, I18n.of(context).recommend_for_you),
        ),
        _buildWaterfall(itemWidth)
      ],
    );
  }

  Widget _buildWaterfall(double itemWidth) {
    return _lightingStore.iStores.isNotEmpty
        ? SliverWaterfallFlow(
            gridDelegate: SliverWaterfallFlowDelegateWithFixedCrossAxisCount(
              crossAxisCount: userSetting.crossCount,
              collectGarbage: (List<int> garbages) {
                garbages.forEach((index) {
                  final provider = ExtendedNetworkImageProvider(
                    _lightingStore.iStores[index].illusts!.imageUrls.medium,
                  );
                  provider.evict();
                });
              },
            ),
            delegate:
                SliverChildBuilderDelegate((BuildContext context, int index) {
              double radio =
                  _lightingStore.iStores[index].illusts!.height.toDouble() /
                      _lightingStore.iStores[index].illusts!.width.toDouble();
              double mainAxisExtent;
              if (radio > 3)
                mainAxisExtent = itemWidth;
              else
                mainAxisExtent = itemWidth * radio;
              return IllustCard(
                store: _lightingStore.iStores[index],
                iStores: _lightingStore.iStores,
                height: mainAxisExtent + 86.0,
              );
            }, childCount: _lightingStore.iStores.length),
          )
        : SliverToBoxAdapter(
            child: Container(
              height: 30,
            ),
          );
  }

  Widget _buildSpotlightContainer() {
    return Container(
      height: 230.0,
      padding: EdgeInsets.only(left: 5.0),
      child: spotlightStore.articles.isNotEmpty
          ? ListView.builder(
              shrinkWrap: true,
              itemBuilder: (context, index) {
                final spotlight = spotlightStore.articles[index];
                return SpotlightCard(
                  spotlight: spotlight,
                );
              },
              itemCount: spotlightStore.articles.length,
              scrollDirection: Axis.horizontal,
            )
          : Container(),
    );
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
                I18n.of(context).spotlight,
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 24.0,
                    color: Theme.of(context).textTheme.headline6!.color),
              ),
              padding: EdgeInsets.only(left: 20.0, bottom: 10.0),
            ),
          ),
          Padding(
            child: TextButton(
              child: Text(
                I18n.of(context).more,
                style: Theme.of(context).textTheme.caption,
              ),
              onPressed: () {
                Navigator.of(context)
                    .push(MaterialPageRoute(builder: (BuildContext context) {
                  return SpotLightPage();
                }));
              },
            ),
            padding: EdgeInsets.all(8.0),
          )
        ],
      ),
    );
  }

  Widget _buildSecondRow(BuildContext context, String title) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Padding(
          child: Center(
            child: Text(
              title,
              overflow: TextOverflow.clip,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24.0),
            ),
          ),
          padding: EdgeInsets.only(left: 20.0),
        ),
        Expanded(child: RecomUserRoad())
      ],
    );
  }

  @override
  bool get wantKeepAlive => true;
}
