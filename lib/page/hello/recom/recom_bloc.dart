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
        yield DataRecomState(recommend.illusts);
      } on DioError catch (e) {

      }
    }
  }
}
