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

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:pixez/component/spotlight_card.dart';
import 'package:pixez/generated/l10n.dart';
import 'package:pixez/network/api_client.dart';
import 'package:pixez/page/hello/recom/bloc.dart';

class SpotLightPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var _easyController = EasyRefreshController();
    var _controller = ScrollController();
    var _refreshCompleter = Completer<void>();
    var _loadCompleter = Completer<void>();
    return BlocProvider<SpotlightBloc>(
      child: Scaffold(
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
        body: BlocListener<SpotlightBloc, SpotlightState>(
          child: BlocBuilder<SpotlightBloc, SpotlightState>(
              builder: (context, snapshot) {
            if (snapshot is DataSpotlight)
              return EasyRefresh(
                  controller: _easyController,
                  onLoad: () {
                    print("next:${snapshot.nextUrl}");
                    BlocProvider.of<SpotlightBloc>(context).add(
                        LoadMoreSpolightEvent(
                            snapshot.articles, snapshot.nextUrl));
                    return _loadCompleter.future;
                  },
                  child: StaggeredGridView.countBuilder(
                    crossAxisCount: 3,
                    controller: _controller,
                    itemBuilder: (BuildContext context, int index) {
                      return SpotlightCard(spotlight: snapshot.articles[index]);
                    },
                    staggeredTileBuilder: (int index) => StaggeredTile.fit(1),
                    itemCount: snapshot.articles.length,
                  ));
            else
              return Center(
                child: CircularProgressIndicator(),
              );
          }),
          listener: (BuildContext context, state) {
            if (state is DataSpotlight) {
              _loadCompleter?.complete();
              _loadCompleter = Completer();
              _refreshCompleter?.complete();
              _refreshCompleter = Completer();
            }
          },
        ),
      ),
      create: (BuildContext context) =>
          SpotlightBloc(apiClient)..add(FetchSpotlightEvent()),
    );
  }
}
