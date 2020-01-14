import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:pixez/component/fail_face.dart';
import 'package:pixez/component/illust_card.dart';
import 'package:pixez/page/hello/ranking/ranking_mode/bloc.dart';

class RankingModePage extends StatelessWidget {
  final String mode, date;

  const RankingModePage({Key key, this.mode, this.date}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var _refreshCompleter = Completer<void>();
    var _loadCompleter = Completer<void>();
    final _refreshController = EasyRefreshController();

    return BlocListener<RankingModeBloc, RankingModeState>(
        listener: (context, state) {
          if (state is DataRankingModeState) {
            _loadCompleter?.complete();
            _loadCompleter = Completer();
            _refreshCompleter?.complete();
            _refreshCompleter = Completer();
          }
          if (state is LoadMoreSuccessState) {
            _refreshController.finishRefresh(success: true, noMore: true);
          }
          if(state is FailRankingModeState){
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
                child: state is DataRankingModeState?StaggeredGridView.countBuilder(
                  crossAxisCount: 2,
                  itemCount: state.illusts.length,
                  itemBuilder: (context, index) {
                    return IllustCard(state.illusts[index]);
                  },
                  staggeredTileBuilder: (int index) => StaggeredTile.fit(1),
                ):Container(),
                onRefresh: () async {
                  BlocProvider.of<RankingModeBloc>(context)
                      .add(FetchEvent(mode, date));
                  return _refreshCompleter.future;
                },
                onLoad: () async {
                  if(state is DataRankingModeState)
                  BlocProvider.of<RankingModeBloc>(context)
                      .add(LoadMoreEvent(state.nextUrl, state.illusts));
                  return _loadCompleter.future;
                },
              );
        
          },
        ));
  }
}
