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
  @override
  Widget build(BuildContext context) {
    _bloc = ResultPainterBloc(ApiClient())..add(FetchEvent(widget.word));
    return BlocBuilder<ResultPainterBloc, ResultPainterState>(
      bloc: _bloc,
      builder: (BuildContext context, ResultPainterState state) {
        if (state is ResultPainterDataState)
          return EasyRefresh(
            onRefresh: () {
              _bloc.add(FetchEvent(widget.word));
            },
            child: ListView.builder(
              itemCount: state.userPreviews.length,
              itemBuilder: (BuildContext context, int index) {
                return PainterCard(
                  user: state.userPreviews[index],
                );
              },
            ),
            onLoad: () {
              _bloc.add(LoadMoreEvent(state.nextUrl));
            },
          );
        else
          return Center(
            child: LinearProgressIndicator(),
          );
      },
    );
  }
}
