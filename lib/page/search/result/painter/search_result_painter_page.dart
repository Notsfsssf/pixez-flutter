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
  ScrollController _scrollController;
  @override
  void initState() {
    _scrollController = ScrollController();

    _refreshController = EasyRefreshController();
    super.initState();
  }

  @override
  void dispose() {
    _refreshController?.dispose();
    _scrollController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ResultPainterBloc>(
      create: (context) => ResultPainterBloc(apiClient),
      child: MultiBlocListener(
        listeners: [
          BlocListener<ResultPainterBloc, ResultPainterState>(
              listener: (BuildContext context, state) {
            if (state is RefreshState) {
              _refreshController.finishRefresh(success: state.success);
            }
            if (state is LoadMoreState) {
              _refreshController.finishLoad(
                  success: state.success, noMore: state.noMore);
            }
          }),
        ],
        child: BlocBuilder<ResultPainterBloc, ResultPainterState>(
          condition: (pre, now) => now is ResultPainterDataState,
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
                      controller: _scrollController,
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
