import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:pixez/models/recommend.dart';
import 'package:pixez/network/api_client.dart';

import './bloc.dart';

class WorksBloc extends Bloc<WorksEvent, WorksState> {
  @override
  WorksState get initialState => InitialWorksState();

  @override
  Stream<WorksState> mapEventToState(
    WorksEvent event,
  ) async* {
    if (event is FetchWorksEvent) {
      final client = new ApiClient();
      try {
        final response = await client.getUserIllusts(event.user_id, event.type);
        Recommend recommend = Recommend.fromJson(response.data);
        yield DataWorksState(recommend.illusts, recommend.nextUrl);
      } catch (e) {
        if (e == null) {
          return;
        }
        print(e);
      }
    }
    if (event is LoadMoreEvent) {
      final client = new ApiClient();
      if (event.nextUrl != null) {
        try {
          final response = await client.getNext(event.nextUrl);
          Recommend recommend = Recommend.fromJson(response.data);
          final ill = event.illusts..addAll(recommend.illusts);
          print(ill.length);
          yield DataWorksState(ill, recommend.nextUrl);
        } catch (e) {}
      } else {}
    }
  }
}
