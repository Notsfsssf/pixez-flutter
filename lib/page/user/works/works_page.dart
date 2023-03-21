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

import 'dart:math';

import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:pixez/component/illust_card.dart';
import 'package:pixez/component/pixez_default_header.dart';
import 'package:pixez/component/sort_group.dart';
import 'package:pixez/exts.dart';
import 'package:pixez/i18n.dart';
import 'package:pixez/lighting/lighting_store.dart';
import 'package:pixez/main.dart';
import 'package:pixez/network/api_client.dart';
import 'package:waterfall_flow/waterfall_flow.dart';

class WorksPage extends StatefulWidget {
  final int id;
  final String portal;
  final LightingStore store;

  const WorksPage(
      {Key? key, required this.id, required this.store, required this.portal})
      : super(key: key);

  @override
  _WorksPageState createState() => _WorksPageState();
}

class _WorksPageState extends State<WorksPage> {
  late LightSource futureGet;
  late LightingStore _store;
  late EasyRefreshController _easyRefreshController;

  @override
  void initState() {
    _easyRefreshController = EasyRefreshController(
        controlFinishLoad: true, controlFinishRefresh: true);
    futureGet = ApiForceSource(
        futureGet: (bool e) => apiClient.getUserIllusts(widget.id, 'illust'));
    _store = widget.store ?? LightingStore(futureGet);
    _store.easyRefreshController = _easyRefreshController;
    super.initState();
    _store.fetch();
  }

  @override
  void dispose() {
    _easyRefreshController.dispose();
    _store.dispose();
    super.dispose();
  }

  String now = 'illust';

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      _buildWorks(),
      // SafeArea(
      //   top: false,
      //   bottom: false,
      //   child: CustomScrollView(
      //     slivers: [
      //       SliverOverlapInjector(
      //         handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
      //       ),
      //       SliverToBoxAdapter(
      //         child: Container(
      //           height: 50,
      //           child: Center(
      //             child: _buildSortChip(),
      //           ),
      //         ),
      //       )
      //     ],
      //   ),
      // )
    ]);
  }

  Widget _buildWorks() {
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
                header: ClassicHeader(
                  position: IndicatorPosition.locator,
                ),
                footer: ClassicFooter(
                  position: IndicatorPosition.locator,
                ),
                childBuilder: (context, phy) {
                  return Observer(builder: (_) {
                    return CustomScrollView(
                      physics: phy,
                      key: PageStorageKey<String>(widget.portal),
                      slivers: [
                        SliverOverlapInjector(
                          handle:
                              NestedScrollView.sliverOverlapAbsorberHandleFor(
                                  context),
                        ),
                        SliverToBoxAdapter(
                          child: Container(
                            height: 50,
                          ),
                        ),
                        const HeaderLocator.sliver(),
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

  Widget _buildSortChip() {
    return SortGroup(
      onChange: (index) {
        setState(() {
          now = index == 0 ? 'illust' : 'manga';
          futureGet = ApiForceSource(
              futureGet: (bool e) => apiClient.getUserIllusts(widget.id, now));
        });
      },
      children: [
        I18n.of(context).illust,
        I18n.of(context).manga,
      ],
    );
  }
}
