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

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:pixez/component/illust_card.dart';
import 'package:pixez/component/spotlight_card.dart';
import 'package:pixez/generated/l10n.dart';
import 'package:pixez/lighting/lighting_store.dart';
import 'package:pixez/network/api_client.dart';
import 'package:pixez/page/hello/ranking/ranking_page.dart';
import 'package:pixez/page/hello/recom/spotlight_store.dart';
import 'package:pixez/page/spotlight/spotlight_page.dart';

class RecomSpolightPage extends StatefulWidget {
  @override
  _RecomSpolightPageState createState() => _RecomSpolightPageState();
}

class _RecomSpolightPageState extends State<RecomSpolightPage>
    with AutomaticKeepAliveClientMixin {
  SpotlightStore spotlightStore;
  LightingStore _lightingStore;

  @override
  void initState() {
    _easyRefreshController = EasyRefreshController();
    spotlightStore = SpotlightStore(RepositoryProvider.of<ApiClient>(context));
    _lightingStore = LightingStore(
        () => RepositoryProvider.of<ApiClient>(context).getRecommend(),
        RepositoryProvider.of<ApiClient>(context),
        _easyRefreshController);

    super.initState();
  }

  EasyRefreshController _easyRefreshController;

  Future<void> fetchT() async {
    await spotlightStore.fetch();
    await _lightingStore.fetch();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Observer(builder: (_) {
      return SafeArea(
        child: EasyRefresh(
          controller: _easyRefreshController,
          enableControlFinishLoad: true,
          enableControlFinishRefresh: true,
          firstRefresh: true,
          onRefresh: () {
            return fetchT();
          },
          onLoad: () {
            return _lightingStore.fetchNext();
          },
          child: _lightingStore.illusts.isNotEmpty
              ? StaggeredGridView.countBuilder(
                  crossAxisCount: 2,
                  padding: EdgeInsets.all(0.0),
                  staggeredTileBuilder: (int index) {
                    if (index < 3)
                      return StaggeredTile.fit(2);
                    else {
                      double screanWidth = MediaQuery.of(context).size.width;
                      double itemWidth = (screanWidth / 2.0) - 32.0;
                      double radio = _lightingStore.illusts[index - 3].height
                              .toDouble() /
                          _lightingStore.illusts[index - 3].width.toDouble();
                      double mainAxisExtent;
                      if (radio > 2)
                        mainAxisExtent = itemWidth;
                      else
                        mainAxisExtent = itemWidth * radio;
                      return StaggeredTile.extent(1, mainAxisExtent + 80.0);
                    }
                  },
                  itemCount: _lightingStore.illusts.length + 3,
                  itemBuilder: (BuildContext context, int index) {
                    if (index == 0) return _buildFirstRow(context);
                    if (index == 1) return _buildSpotlightContainer();
                    if (index == 2) return _buildSecondRow(context);
                    if (index >= 3)
                      return IllustCard(
                        _lightingStore.illusts[index - 3],
                        illustList: _lightingStore.illusts,
                      );

                    return Container();
                  },
                )
              : Container(),
        ),
      );
    });
  }

  Container _buildSpotlightContainer() {
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
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        AppBar(
          automaticallyImplyLeading: false,
          titleSpacing: 0.0,
          title: Padding(
            padding: const EdgeInsets.only(top: 10.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Container(
                  child: Padding(
                    child: Text(
                      I18n.of(context).Spotlight,
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
                    child: Text(I18n.of(context).More),
                    onPressed: () {
                      Navigator.of(context).push(
                          MaterialPageRoute(builder: (BuildContext context) {
                        return SpotLightPage();
                      }));
                    },
                  ),
                  padding: EdgeInsets.all(8.0),
                )
              ],
            ),
          ),
          elevation: 0.0,
          backgroundColor: Colors.transparent,
        ),
      ],
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
                I18n.of(context).Recommend_for_you,
                overflow: TextOverflow.clip,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30.0),
              ),
            ),
            padding: EdgeInsets.only(left: 20.0, bottom: 10.0),
          ),
        ),
        Padding(
          child: FlatButton(
            child: Text(I18n.of(context).More),
            onPressed: () {
              Navigator.of(context)
                  .push(MaterialPageRoute(builder: (BuildContext context) {
                return Scaffold(
                  body: RankingPage(),
                );
              }));
            },
          ),
          padding: EdgeInsets.all(8.0),
        )
      ],
    );
  }

  @override
  bool get wantKeepAlive => true;
}
