import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:pixez/component/painer_card.dart';
import 'package:pixez/network/api_client.dart';
import 'package:pixez/page/search/result/painter/bloc/bloc.dart';

class SearchResultPainterPage extends StatefulWidget {
  final String word;

  SearchResultPainterPage({Key key, this.word}) : super(key: key);

  @override
  _SearchResultPainterPageState createState() =>
      _SearchResultPainterPageState();
}

class _SearchResultPainterPageState extends State<SearchResultPainterPage> {
  EasyRefreshController _refreshController;

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
    return BlocProvider<ResultPainterBloc>(
      create: (context) =>
          ResultPainterBloc(RepositoryProvider.of<ApiClient>(context)),
      child: BlocListener<ResultPainterBloc, ResultPainterState>(
        listener: (BuildContext context, state) {
          if (state is RefreshSuccessState) {
            _refreshController.finishRefresh(success: true);
          }
          if (state is RefreshFailState) {
            _refreshController.finishRefresh(success: false);
            ;
          }
          if (state is LoadEndState) {
            _refreshController.finishLoad(success: true, noMore: true);
          }
          if (state is LoadMoreSuccessState) {
            _refreshController.finishLoad(success: true);
          }
          if (state is LoadMoreFailState) {
            _refreshController.finishLoad(success: false);
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
                    .add(FetchEvent(widget.word));
                return;
              },
              firstRefresh: true,
              enableControlFinishLoad: true,
              enableControlFinishRefresh: true,
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


