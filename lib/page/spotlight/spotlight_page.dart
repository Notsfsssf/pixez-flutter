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
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:pixez/component/pixez_default_header.dart';
import 'package:pixez/component/spotlight_card.dart';
import 'package:pixez/i18n.dart';
import 'package:pixez/page/hello/recom/spotlight_store.dart';
import 'package:waterfall_flow/waterfall_flow.dart';

class SpotLightPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final ScrollController _controller = ScrollController();
    final EasyRefreshController _refreshController = EasyRefreshController(
        controlFinishLoad: true, controlFinishRefresh: true);
    final SpotlightStore _spotlightStore = SpotlightStore(_refreshController);
    return Observer(builder: (_) {
      return Scaffold(
        appBar: AppBar(
          title: Text(I18n.of(context).spotlight),
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.arrow_upward),
              onPressed: () {
                _controller.animateTo(0,
                    duration: Duration(seconds: 1), curve: Curves.ease);
              },
            )
          ],
        ),
        body: EasyRefresh(
            onLoad: () => _spotlightStore.next(),
            onRefresh: () => _spotlightStore.fetch(),
            header: PixezDefault.header(context),
            refreshOnStart: true,
            controller: _refreshController,
            child: WaterfallFlow.builder(
              gridDelegate: SliverWaterfallFlowDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2),
              controller: _controller,
              itemBuilder: (BuildContext context, int index) {
                return SpotlightCard(
                    spotlight: _spotlightStore.articles[index]);
              },
              itemCount: _spotlightStore.articles.length,
            )),
      );
    });
  }
}
