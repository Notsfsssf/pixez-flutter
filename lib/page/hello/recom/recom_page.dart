import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:pixez/component/illust_card.dart';
import 'package:pixez/page/hello/recom/bloc.dart';

class ReComPage extends StatefulWidget {
  @override
  _ReComPageState createState() => _ReComPageState();
}

class _ReComPageState extends State<ReComPage> {
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
        builder: (context) => RecomBloc()..add(FetchEvent()),
        child: BlocListener<RecomBloc, RecomState>(
            listener: (context, state) {
              if (state is DataRecomState) {
                _loadCompleter?.complete();
                _loadCompleter = Completer();
                _refreshCompleter?.complete();
                _refreshCompleter = Completer();
              }
            },
            child: Scaffold(
                appBar: AppBar(
                  title: Text("Recommend"),
                ),
                body: BlocBuilder<RecomBloc, RecomState>(
                    builder: (context, state) {
                  if (state is DataRecomState)
                    return _buildDateBody(state, context);
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                }))));
  }

  Widget _buildDateBody(DataRecomState state, BuildContext context) {
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
        BlocProvider.of<RecomBloc>(context).add(FetchEvent());
        return _refreshCompleter.future;
      },
      onLoad: () async {
        BlocProvider.of<RecomBloc>(context)
            .add(LoadMoreEvent(state.nextUrl, state.illusts));
        return _loadCompleter.future;
      },
    );
  }
}
