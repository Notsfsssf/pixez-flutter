import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:flutter_easyrefresh/src/refresher.dart';
import 'package:pixez/models/recommend.dart';
import 'package:pixez/network/api_client.dart';

import './bloc.dart';

class SearchResultBloc extends Bloc<SearchResultEvent, SearchResultState> {
  final ApiClient client;
  EasyRefreshController refreshController;

  SearchResultBloc(this.client, this.refreshController);

  @override
  SearchResultState get initialState => InitialSearchResultState();

  @override
  Stream<SearchResultState> mapEventToState(
    SearchResultEvent event,
  ) async* {
    if (event is PreviewEvent) {
      try {
        final recommend = await client.getPopularPreview(event.word);
        refreshController.finishRefresh(success: true);
      } catch (e) {
        if (e == null) {
          return;
        }
        print(e);
        yield RefreshFailState();
        refreshController.finishRefresh(success: false);
      }
    }
    if (event is ApplyEvent) {
      try {
        final response = await client.getSearchIllust(event.word,
            search_target: event.searchTarget,
            sort: event.sort,
            start_date: event.enableDuration ? event.startDate : null,
            end_date: event.enableDuration ? event.endDate : null);
        Recommend recommend = Recommend.fromJson(response.data);
        yield DataState(recommend.illusts, recommend.nextUrl);
        refreshController.finishRefresh(success: true);
      } catch (e) {
        if (e == null) {
          return;
        }
        print(e);
        yield RefreshFailState();
        refreshController.finishRefresh(success: false);
      }
    }
    if (event is FetchEvent) {
      try {
        final response = await client.getSearchIllust(event.word,
            search_target: event.searchTarget,
            sort: event.sort,
            start_date: event.enableDuration ? event.startDate : null,
            end_date: event.enableDuration ? event.endDate : null);
        Recommend recommend = Recommend.fromJson(response.data);
        yield DataState(recommend.illusts, recommend.nextUrl);
        refreshController.finishRefresh(success: true);
      } catch (e) {
        if (e == null) {
          return;
        }
        print(e);
        refreshController.finishRefresh(success: false);
      }
    }
    if (event is LoadMoreEvent) {
      if (event.nextUrl != null && event.nextUrl.isNotEmpty) {
        try {
          final response = await client.getNext(event.nextUrl);
          Recommend recommend = Recommend.fromJson(response.data);
          final ill = event.illusts..addAll(recommend.illusts);
          print(ill.length);
          yield DataState(ill, recommend.nextUrl);
          refreshController.finishLoad(success: true, noMore: false);
        } catch (e) {
          refreshController.finishLoad(success: false);
        }
      } else {
        refreshController.finishLoad(success: true, noMore: true);
      }
    }
    if (event is ShowBottomSheetEvent) {
      yield ShowBottomSheetState();
    }
  }
}
