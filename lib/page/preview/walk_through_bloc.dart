import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:pixez/models/recommend.dart';
import 'package:pixez/network/api_client.dart';

import './bloc.dart';

class WalkThroughBloc extends Bloc<WalkThroughEvent, WalkThroughState> {
  final ApiClient client;

  WalkThroughBloc(this.client);

  @override
  WalkThroughState get initialState => InitialWalkThroughState();

  @override
  Stream<WalkThroughState> mapEventToState(
    WalkThroughEvent event,
  ) async* {
    if (event is FetchWalkThroughEvent) {
      var response = await client.walkthroughIllusts();
      yield DataWalkThroughState(response.illusts, response.nextUrl);
    }
    if (event is LoadMoreWalkThroughEvent) {
      if (event.nextUrl != null && event.nextUrl.isNotEmpty) {
        var result = await client.getNext(event.nextUrl);
        var response = Recommend.fromJson(result.data);
        yield DataWalkThroughState(
            event.illusts..addAll(response.illusts), response.nextUrl);
      }
    }
  }
}
