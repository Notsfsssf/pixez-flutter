import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:pixez/component/painer_card.dart';
import 'package:pixez/network/api_client.dart';
import 'package:pixez/page/search/result/painter/bloc/bloc.dart';

class SearchResultPainerPage extends StatefulWidget {
  final String word;

  const SearchResultPainerPage({Key key, this.word}) : super(key: key);
  @override
  _SearchResultPainerPageState createState() => _SearchResultPainerPageState();
}

class _SearchResultPainerPageState extends State<SearchResultPainerPage> {
  ResultPainterBloc _bloc;
  Completer<void> _refreshCompleter, _loadCompleter;
  EasyRefreshController _refreshController;
  @override
  void initState() {
    super.initState();
    _refreshCompleter = Completer<void>();
    _loadCompleter = Completer<void>();
    _refreshController = EasyRefreshController();
  }

  @override
  Widget build(BuildContext context) {
    _bloc = ResultPainterBloc(ApiClient())..add(FetchEvent(widget.word));
    return BlocListener<ResultPainterBloc, ResultPainterState>(
      bloc: _bloc,
      listener: (BuildContext context, state) {
           _loadCompleter.complete();
          _refreshCompleter.complete();
          _refreshCompleter = Completer<void>();
          _loadCompleter = Completer<void>();
          if(state is LoadEndState){
            Scaffold.of(context).showSnackBar(SnackBar(content: Text("End"),));
          }
      },
      child: BlocBuilder<ResultPainterBloc, ResultPainterState>(
        bloc: _bloc,
        condition: (pre,now){
          print(now is ResultPainterState);
          return now is ResultPainterDataState;
        },
        builder: (BuildContext context, ResultPainterState state) {
          if (state is ResultPainterDataState)
            return EasyRefresh(
              onRefresh: () async {
                _bloc.add(FetchEvent(widget.word));
                return _refreshCompleter.future;
              },
              controller: _refreshController,
              child: ListView.builder(
                itemCount: state.userPreviews.length,
                itemBuilder: (BuildContext context, int index) {
                  return PainterCard(
                    user: state.userPreviews[index],
                  );
                },
              ),
              onLoad: () async {
                _bloc.add(LoadMoreEvent(state.nextUrl));
                return _loadCompleter.future;
              },
            );
          else
            return Center(
              child: CircularProgressIndicator(),
            );
        },
      ),
    );
  }
}
