import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:pixez/models/spotlight_response.dart';
import 'package:pixez/network/api_client.dart';

import './bloc.dart';

class SpotlightBloc extends Bloc<SpotlightEvent, SpotlightState> {
  final ApiClient client;

  SpotlightBloc(this.client);

  @override
  SpotlightState get initialState => InitialSpotlightState();

  @override
  Stream<SpotlightState> mapEventToState(
    SpotlightEvent event,
  ) async* {
    if (event is FetchSpotlightEvent) {
      try {
        Response response = await client.getSpotlightArticles("all");
        yield DataSpotlight(SpotlightResponse.fromJson(response.data));
      } catch (e) {}
    }
  }
}
