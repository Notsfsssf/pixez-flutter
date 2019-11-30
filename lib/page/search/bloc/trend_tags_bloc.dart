import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:pixez/models/trend_tags.dart';
import 'package:pixez/network/api_client.dart';
import './bloc.dart';

class TrendTagsBloc extends Bloc<TrendTagsEvent, TrendTagsState> {
  final ApiClient client;

  TrendTagsBloc(this.client);
  @override
  TrendTagsState get initialState => InitialTrendTagsState();

  @override
  Stream<TrendTagsState> mapEventToState(
    TrendTagsEvent event,
  ) async* {
    if (state is FetchEvent) {
      Response response = await client.getIllustTrendTags();
      TrendingTag trendingTag = TrendingTag.fromJson(response.data);
      yield TrendTagDataState(trendingTag);
    }
  }
}
