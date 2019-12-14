import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:pixez/models/recommend.dart';
import 'package:pixez/network/api_client.dart';

import './bloc.dart';

class NewIllustBloc extends Bloc<NewIllustEvent, NewIllustState> {
  @override
  NewIllustState get initialState => InitialNewIllustState();

  @override
  Stream<NewIllustState> mapEventToState(
    NewIllustEvent event,
  ) async* {
      if (event is FetchEvent) {
      final client =ApiClient();
      try {
        final response = await client.getFollowIllusts(event.restrict);
        Recommend recommend = Recommend.fromJson(response.data);
        yield DataNewIllustState(recommend.illusts, recommend.nextUrl);
      }  catch (e) {
        // The request was made and the server responded with a status code
        // that falls out of the range of 2xx and is also not 304.
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
          yield DataNewIllustState(ill, recommend.nextUrl);
        } catch (e) {
          
        }
      } else {}
    }
  }
}
