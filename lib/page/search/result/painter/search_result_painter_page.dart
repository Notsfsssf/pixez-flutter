import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:pixez/component/painer_card.dart';
import 'package:pixez/network/api_client.dart';
import 'package:pixez/page/search/result/painter/bloc/bloc.dart';

class SearchResultPainerPage extends StatelessWidget {
  final String word;
  Completer<void> _refreshCompleter, _loadCompleter;
  EasyRefreshController _refreshController;

  SearchResultPainerPage({Key key, this.word}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    _refreshCompleter = Completer<void>();
    _loadCompleter = Completer<void>();
    _refreshController = EasyRefreshController();
    return BlocProvider<ResultPainterBloc>(
      create: (context) =>
          ResultPainterBloc(RepositoryProvider.of<ApiClient>(context)),
      child: BlocListener<ResultPainterBloc, ResultPainterState>(
        listener: (BuildContext context, state) {
          if(state is ResultPainterDataState){
            _refreshController.finishRefresh(success: true);
            _loadCompleter.complete();
            _refreshCompleter.complete();
            _refreshCompleter = Completer<void>();
            _loadCompleter = Completer<void>();
          }
          if (state is RefreshFailState) {
            _refreshController.finishRefresh(success: false);
            _loadCompleter.complete();
            _refreshCompleter.complete();
            _refreshCompleter = Completer<void>();
            _loadCompleter = Completer<void>();
          }
          if (state is LoadEndState) {
            _refreshController.finishLoad(success: true, noMore: true);
          }
        },
        child: BlocBuilder<ResultPainterBloc, ResultPainterState>(
          condition: (pre, now) {
            return now is ResultPainterDataState;
          },
          builder: (BuildContext context, ResultPainterState state) {
            return EasyRefresh(
              onRefresh: () async {
                BlocProvider.of<ResultPainterBloc>(context)
                    .add(FetchEvent(word));
                return _refreshCompleter.future;
              },
              firstRefresh: true,
              controller: _refreshController,
              child: state is ResultPainterDataState
                  ? ListView.builder(
                      itemCount: state.userPreviews.length,
                      itemBuilder: (BuildContext context, int index) {
                        return PainterCard(
                          user: state.userPreviews[index],
                        );
                      },
                    )
                  : Container(),
              onLoad: () async {
                if (state is ResultPainterDataState) {
                  BlocProvider.of<ResultPainterBloc>(context)
                      .add(LoadMoreEvent(state.nextUrl));
                  BlocProvider.of<ResultPainterBloc>(context)
                      .add(LoadMoreEvent(state.nextUrl));
                }
                return;
              },
            );
          },
        ),
      ),
    );
  }
}
