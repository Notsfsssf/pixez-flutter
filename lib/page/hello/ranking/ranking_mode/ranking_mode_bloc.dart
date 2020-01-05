import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:pixez/models/recommend.dart';
import 'package:pixez/network/api_client.dart';

import './bloc.dart';

class RankingModeBloc extends Bloc<RankingModeEvent, RankingModeState> {
  final ApiClient client;

  RankingModeBloc(this.client);

  @override
  RankingModeState get initialState => InitialRankingModeState();

  @override
  Stream<RankingModeState> mapEventToState(
    RankingModeEvent event,
  ) async* {
    if (event is FetchEvent) {
      try {
        final response = await client.getIllustRanking(event.mode, event.date);
        Recommend recommend = Recommend.fromJson(response.data);
        yield DataRankingModeState(recommend.illusts, recommend.nextUrl);
      } catch (e) {
        print(e);
      }
    }
    if (event is LoadMoreEvent) {
      if (event.nextUrl != null) {
        try {
          final response = await client.getNext(event.nextUrl);
          Recommend recommend = Recommend.fromJson(response.data);
          final ill = event.illusts..addAll(recommend.illusts);
          print(ill.length);
          yield DataRankingModeState(ill, recommend.nextUrl);
        } catch (e) {}
      } else {
        yield LoadMoreSuccessState();
      }
    }
  }
}
