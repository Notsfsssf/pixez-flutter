import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:pixez/models/recommend.dart';
import 'package:pixez/network/api_client.dart';

import './bloc.dart';

class WorksBloc extends Bloc<WorksEvent, WorksState> {
  final ApiClient client;

  WorksBloc(this.client);

  @override
  WorksState get initialState => InitialWorksState();

  @override
  Stream<WorksState> mapEventToState(
    WorksEvent event,
  ) async* {
    if (event is FetchWorksEvent) {
      try {
        final response = await client.getUserIllusts(event.user_id, event.type);
        Recommend recommend = Recommend.fromJson(response.data);
        yield DataWorksState(recommend.illusts, recommend.nextUrl);
      } catch (e) {
        yield FailWorkState();
      }
    }
    if (event is LoadMoreEvent) {
      if (event.nextUrl != null) {
        try {
          final response = await client.getNext(event.nextUrl);
          Recommend recommend = Recommend.fromJson(response.data);
          final ill = event.illusts..addAll(recommend.illusts);
          print(ill.length);
          yield DataWorksState(ill, recommend.nextUrl);
        } catch (e) {
          yield LoadMoreFailState();
        }
      } else {
        yield LoadMoreEndState();
      }
    }
  }
}
