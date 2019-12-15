import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:pixez/component/illust_card.dart';
import 'package:pixez/network/api_client.dart';
import 'package:pixez/page/hello/ranking/ranking_mode/bloc.dart';

class RankingModePage extends StatelessWidget {
  final String mode, date;

  const RankingModePage({Key key, this.mode, this.date}) : super(key: key);


  @override
  Widget build(BuildContext context) {
   var _refreshCompleter = Completer<void>();
   var _loadCompleter = Completer<void>();
   final _refreshController=EasyRefreshController();

   final _bloc=BlocProvider.of<RankingModeBloc>(context);
    return BlocListener<RankingModeBloc, RankingModeState>(
        bloc: _bloc,
        listener: (context, state) {
          if (state is DataRankingModeState) {
            _loadCompleter?.complete();
            _loadCompleter = Completer();
            _refreshCompleter?.complete();
            _refreshCompleter = Completer();
          }
        }, child: BlocBuilder<RankingModeBloc, RankingModeState>(
      bloc: _bloc,
      builder: (context, state) {
        if (state is DataRankingModeState)
          return EasyRefresh(
            controller: _refreshController,
            child: StaggeredGridView.countBuilder(
              crossAxisCount: 2,
              itemCount: state.illusts.length,
              itemBuilder: (context, index) {
                return IllustCard(state.illusts[index]);
              },
              staggeredTileBuilder: (int index) => StaggeredTile.fit(1),
            ),
            onRefresh: () async {
              BlocProvider.of<RankingModeBloc>(context)
                  .add(FetchEvent(mode,date));
              return _refreshCompleter.future;
            },
            onLoad: () async {
              BlocProvider.of<RankingModeBloc>(context)
                  .add(LoadMoreEvent(state.nextUrl, state.illusts));
              return _loadCompleter.future;
            },
          );
        return Center(
          child: CircularProgressIndicator(),
        );
      },
    ));
  }
}


