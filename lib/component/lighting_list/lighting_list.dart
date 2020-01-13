import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:pixez/bloc/bloc.dart';
import 'package:pixez/bloc/lighting_bloc.dart';
import 'package:pixez/bloc/lighting_state.dart';
import 'package:pixez/component/illust_card.dart';

class LightingList extends StatefulWidget {
  String restrict;

  @override
  _LightingListState createState() => _LightingListState();
}

class _LightingListState extends State<LightingList> {
  Completer<void> _refreshCompleter, _loadCompleter;
  EasyRefreshController _easyRefreshController;

  @override
  void initState() {
    super.initState();
    _refreshCompleter = Completer<void>();
    _loadCompleter = Completer<void>();
    _easyRefreshController = EasyRefreshController();
    // BlocProvider.of<NewIllustBloc>(context)
    //     .add(FetchIllustEvent(widget.restrict));
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<LightingBloc, LightingState>(
      listener: (context, state) {
        if (state is LightingLoadSuccess) {
          _loadCompleter?.complete();
          _loadCompleter = Completer();
          _refreshCompleter?.complete();
          _refreshCompleter = Completer();
        }
        if (state is LightingLoadFailure) {
          _easyRefreshController.finishRefresh(
            success: false,
          );
          _refreshCompleter?.complete();
          _refreshCompleter = Completer();
        }
      },
      child:
          BlocBuilder<LightingBloc, LightingState>(builder: (context, state) {
        return EasyRefresh(
          controller: _easyRefreshController,
          firstRefresh: true,
          child: state is LightingLoadSuccess
              ? StaggeredGridView.countBuilder(
                  crossAxisCount: 2,
                  itemCount: state.illusts.length,
                  itemBuilder: (context, index) {
                    return IllustCard(state.illusts[index]);
                  },
                  staggeredTileBuilder: (int index) => StaggeredTile.fit(1),
                )
              : Container(),
          onRefresh: () async {
            BlocProvider.of<LightingBloc>(context)
                .add(LightingFetch(widget.restrict));
            return _refreshCompleter.future;
          },
          onLoad: () async {
            if (state is LightingLoadSuccess)
              BlocProvider.of<LightingBloc>(context).add(LightingLoadMore(
                state.illusts,
                state.nextUrl,
              ));
            return _loadCompleter.future;
          },
        );
      }),
    );
  }
}
