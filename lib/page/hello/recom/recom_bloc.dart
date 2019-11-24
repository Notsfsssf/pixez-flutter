import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:pixez/models/recommend.dart';
import 'package:pixez/network/api_client.dart';
import 'package:pixez/page/hello/bloc/bloc.dart';
import './bloc.dart';
import 'package:dio/dio.dart';

class RecomBloc extends Bloc<RecomEvent, RecomState> {
  @override
  RecomState get initialState => InitialRecomState();

  @override
  Stream<RecomState> mapEventToState(
    RecomEvent event,
  ) async* {
    if (event is FetchEvent) {
      final client = new ApiClient();
      try {
        final response = await client.getRecommend();
        Recommend recommend = Recommend.fromJson(response.data);
        yield DataRecomState(recommend.illusts, recommend.nextUrl);
      } on DioError catch (e) {
        // The request was made and the server responded with a status code
        // that falls out of the range of 2xx and is also not 304.
        if (e == null) {
          return;
        }
        if (e.response != null) {
          print(e.response.data);
          print(e.response.headers);
          print(e.response.request);
        } else {
          // Something happened in setting up or sending the request that triggered an Error
          print(e.request);
          print(e.message);
        }
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
          yield DataRecomState(ill, recommend.nextUrl);
        } catch (e) {}
      } else {}
    }
  }
}
