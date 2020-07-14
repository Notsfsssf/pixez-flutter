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
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:flutter_easyrefresh/material_header.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:pixez/component/spotlight_card.dart';
import 'package:pixez/generated/l10n.dart';
import 'package:pixez/page/hello/recom/spotlight_store.dart';

class SpotLightPage extends StatelessWidget {
  final SpotlightStore _spotlightStore = SpotlightStore();
  final ScrollController _controller = ScrollController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(I18n.of(context).Spotlight),
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
          firstRefresh: true,
          header: MaterialHeader(),
          child: StaggeredGridView.countBuilder(
            crossAxisCount: 3,
            controller: _controller,
            itemBuilder: (BuildContext context, int index) {
              return SpotlightCard(spotlight: _spotlightStore.articles[index]);
            },
            staggeredTileBuilder: (int index) => StaggeredTile.fit(1),
            itemCount: _spotlightStore.articles.length,
          )),
    );
  }
}
