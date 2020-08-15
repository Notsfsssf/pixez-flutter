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

import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:pixez/component/illust_card.dart';
import 'package:pixez/component/spotlight_card.dart';
import 'package:pixez/generated/l10n.dart';
import 'package:pixez/lighting/lighting_store.dart';
import 'package:pixez/main.dart';
import 'package:pixez/models/illust.dart';
import 'package:pixez/network/api_client.dart';
import 'package:pixez/page/hello/ranking/rank_page.dart';
import 'package:pixez/page/hello/recom/spotlight_store.dart';
import 'package:pixez/page/spotlight/spotlight_page.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:waterfall_flow/waterfall_flow.dart';

class RecomSpolightPage extends StatefulWidget {
  @override
  _RecomSpolightPageState createState() => _RecomSpolightPageState();
}

class _RecomSpolightPageState extends State<RecomSpolightPage> {
  SpotlightStore spotlightStore;
  LightingStore _lightingStore;

  @override
  void initState() {
    _easyRefreshController = RefreshController(initialRefresh: true);
    spotlightStore = SpotlightStore(null);
    _lightingStore =
        LightingStore(() => apiClient.getRecommend(), _easyRefreshController);

    super.initState();
  }

  RefreshController _easyRefreshController;

  Future<void> fetchT() async {
    await spotlightStore.fetch();
    await _lightingStore.fetch();
  }

  @override
  void dispose() {
    _easyRefreshController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Observer(builder: (_) {
      return buildEasyRefresh(context);
    });
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

  Widget buildEasyRefresh(BuildContext context) {
    return SmartRefresher(
      controller: _easyRefreshController,
      enablePullDown: true,
      enablePullUp: true,
      footer: CustomFooter(
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
      ),
      onRefresh: () {
        return fetchT();
      },
      onLoading: () {
        return _lightingStore.fetchNext();
      },
      child: _buildWaterFall(),
    );
  }

  Widget _buildWaterFall() {
    double screanWidth = MediaQuery.of(context).size.width;
    double itemWidth = (screanWidth / userSetting.crossCount.toDouble()) - 32.0;
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          elevation: 0.0,
          titleSpacing: 0.0,
          automaticallyImplyLeading: false,
          backgroundColor: Colors.transparent,
          title: _buildFirstRow(context),
        ),
        SliverToBoxAdapter(
          child: _buildSpotlightContainer(),
        ),
        SliverToBoxAdapter(
          child: _buildSecondRow(context),
        ),
        _lightingStore.iStores.isNotEmpty
            ? SliverWaterfallFlow(
                gridDelegate:
                    SliverWaterfallFlowDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  collectGarbage: (List<int> garbages) {
                    garbages.forEach((index) {
                      final provider = ExtendedNetworkImageProvider(
                        _lightingStore.iStores[index].illusts.imageUrls.medium,
                      );
                      provider.evict();
                    });
                  },
                ),
                delegate: SliverChildBuilderDelegate(
                    (BuildContext context, int index) {
                  double radio = _lightingStore.iStores[index].illusts.height
                          .toDouble() /
                      _lightingStore.iStores[index].illusts.width.toDouble();
                  double mainAxisExtent;
                  if (radio > 3)
                    mainAxisExtent = itemWidth;
                  else
                    mainAxisExtent = itemWidth * radio;
                  return Container(
                    child: IllustCard(store: _lightingStore.iStores[index]),
                    height: mainAxisExtent + 60.0,
                  );
                }),
              )
            : []
      ],
    );
  }


  Widget _buildSpotlightContainer() {
    return Container(
      height: 230.0,
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
                    fontSize: 30.0,
                    color: Theme.of(context).textTheme.headline6.color),
              ),
              padding: EdgeInsets.only(left: 20.0, bottom: 10.0),
            ),
          ),
          Padding(
            child: FlatButton(
              child: Text(I18n.of(context).more),
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

  Widget _buildSecondRow(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Container(
          child: Padding(
            child: Container(
              child: Text(
                I18n.of(context).recommend_for_you,
                overflow: TextOverflow.clip,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30.0),
              ),
            ),
            padding: EdgeInsets.only(left: 20.0, bottom: 10.0),
          ),
        ),
        Padding(
          child: FlatButton(
            child: Text(I18n.of(context).more),
            onPressed: () {
              Navigator.of(context)
                  .push(MaterialPageRoute(builder: (BuildContext context) {
                return Scaffold(
                  body: RankPage(),
                );
              }));
            },
          ),
          padding: EdgeInsets.all(8.0),
        )
      ],
    );
  }
}
