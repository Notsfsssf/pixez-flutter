import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:pixez/models/recommend.dart';
import 'package:pixez/network/api_client.dart';

import './bloc.dart';

class NewIllustBloc extends Bloc<NewIllustEvent, NewIllustState> {
  final ApiClient client;

  NewIllustBloc(this.client);

  @override
  NewIllustState get initialState => InitialNewIllustState();

  @override
  Stream<NewIllustState> mapEventToState(
    NewIllustEvent event,
  ) async* {
    if (event is FetchIllustEvent) {
      try {
        final response = await client.getFollowIllusts(event.restrict);
        Recommend recommend = Recommend.fromJson(response.data);
        yield DataNewIllustState(recommend.illusts, recommend.nextUrl);
      } catch (e) {
        yield FailIllustState();
      }
    }
    if (event is LoadMoreEvent) {
      if (event.nextUrl != null) {
        try {
          final response = await client.getNext(event.nextUrl);
          Recommend recommend = Recommend.fromJson(response.data);
          final ill = event.illusts..addAll(recommend.illusts);
          print(ill.length);
          yield DataNewIllustState(ill, recommend.nextUrl);
        } catch (e) {}
      } else {}
    }
  }
}
