import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:pixez/component/illust_card.dart';
import 'package:pixez/network/api_client.dart';
import 'package:pixez/page/hello/ranking/ranking_mode/bloc.dart';

class RankingModePage extends StatefulWidget {
  final String mode;

  const RankingModePage({Key key, this.mode}) : super(key: key);

  @override
  _RankingModePageState createState() => _RankingModePageState();
}

class _RankingModePageState extends State<RankingModePage> {
  Completer<void> _refreshCompleter, _loadCompleter;
  @override
  void initState() {
    super.initState();
    _refreshCompleter = Completer<void>();
    _loadCompleter = Completer<void>();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      builder: (context) => RankingModeBloc(ApiClient())..add(FetchEvent(widget.mode)),
      child: BlocListener<RankingModeBloc, RankingModeState>(listener: (context, state) {
        if (state is DataRankingModeState) {
          _loadCompleter?.complete();
          _loadCompleter = Completer();
          _refreshCompleter?.complete();
          _refreshCompleter = Completer();
        }
      }, child: BlocBuilder<RankingModeBloc, RankingModeState>(
        builder: (context, state) {
          if (state is DataRankingModeState)
            return EasyRefresh(
              child: StaggeredGridView.countBuilder(
                crossAxisCount: 2,
                itemCount: state.illusts.length,
                itemBuilder: (context, index) {
                  return IllustCard(state.illusts[index]);
                },
                staggeredTileBuilder: (int index) => StaggeredTile.fit(1),
              ),
              onRefresh: () async {
                BlocProvider.of<RankingModeBloc>(context).add(FetchEvent(widget.mode));
                return _refreshCompleter.future;
              },
              onLoad: () async {
                BlocProvider.of<RankingModeBloc>(context)
                    .add(LoadMoreEvent(state.nextUrl, state.illusts));
                return _loadCompleter.future;
              },
            );
          return Container();
        },
      )),
    );
  }
}
