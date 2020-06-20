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
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:pixez/component/illust_card.dart';
import 'package:pixez/page/hello/ranking/ranking_mode/bloc.dart';

class RankingModePage extends StatefulWidget {
  final String mode, date;

  const RankingModePage({Key key, this.mode, this.date}) : super(key: key);

  @override
  _RankingModePageState createState() => _RankingModePageState();
}

class _RankingModePageState extends State<RankingModePage>
    with AutomaticKeepAliveClientMixin {
  EasyRefreshController _refreshController;
  Completer<void> _refreshCompleter = Completer<void>();
  Completer<void> _loadCompleter = Completer<void>();

  @override
  void initState() {
    _refreshController = EasyRefreshController();

    super.initState();
  }

  @override
  void dispose() {
    _refreshController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<RankingModeBloc, RankingModeState>(
        listener: (context, state) {
          _loadCompleter?.complete();
          _loadCompleter = Completer();
          _refreshCompleter?.complete();
          _refreshCompleter = Completer();
          if (state is DataRankingModeState) {
            _refreshController.finishRefresh(success: true);
          }
          if (state is LoadMoreSuccessState) {
            _refreshController.finishLoad(success: true, noMore: true);
          }
          if (state is FailRankingModeState) {
            _refreshController.finishRefresh(success: false);
          }
        },
        child: BlocBuilder<RankingModeBloc, RankingModeState>(
          condition: (pre, now) {
            return now is DataRankingModeState;
          },
          builder: (context, state) {
            return EasyRefresh(
              controller: _refreshController,
              firstRefresh: true,
              child: state is DataRankingModeState
                  ? StaggeredGridView.countBuilder(
                crossAxisCount: 2,
                itemCount: state.illusts.length,
                itemBuilder: (context, index) {
                  return IllustCard(
                    state.illusts[index],
                    illustList: state.illusts,
                  );
                },
                staggeredTileBuilder: (int index) => StaggeredTile.fit(1),
              )
                  : Container(),
              onRefresh: () async {
                BlocProvider.of<RankingModeBloc>(context)
                    .add(FetchEvent(widget.mode, widget.date));
                return _refreshCompleter.future;
              },
              onLoad: () async {
                if (state is DataRankingModeState)
                  BlocProvider.of<RankingModeBloc>(context)
                      .add(LoadMoreEvent(state.nextUrl, state.illusts));
                return _loadCompleter.future;
              },
            );
          },
        ));
  }

  @override
  bool get wantKeepAlive => true;
}
