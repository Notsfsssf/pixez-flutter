import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:pixez/models/recommend.dart';
import 'package:pixez/network/api_client.dart';

import './bloc.dart';

class RecomBloc extends Bloc<RecomEvent, RecomState> {
  final ApiClient client;
  EasyRefreshController easyRefreshController;
  RecomBloc(this.client, this.easyRefreshController);

  @override
  RecomState get initialState => InitialRecomState();

  @override
  Stream<RecomState> mapEventToState(
    RecomEvent event,
  ) async* {
    if (event is FetchEvent) {
      try {
        final response = await client.getRecommend();
        Recommend recommend = Recommend.fromJson(response.data);
        yield DataRecomState(recommend.illusts, recommend.nextUrl);
      } catch (e) {
        yield FailRecomState();
      }
    }
    if (event is LoadMoreEvent) {
      if (event.nextUrl != null) {
        try {
          final response = await client.getNext(event.nextUrl);
          Recommend recommend = Recommend.fromJson(response.data);
          final ill = event.illusts..addAll(recommend.illusts);
          print(ill.length);
          yield DataRecomState(ill, recommend.nextUrl);
        } catch (e) {
          easyRefreshController.finishLoad(
            success: false,
          );
        }
      } else {
        easyRefreshController.finishLoad(success: true, noMore: true);
      }
    }
  }
}
