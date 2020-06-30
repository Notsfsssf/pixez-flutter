/*
 * Copyright (C) 2020. by perol_notsf, All rights reserved
 *
 * This program is free software: you can redistribute it and/or modify it under
 * the terms of the GNU General Public License as published by the Free Software
 * Foundation, either version 3 of the License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful, but WITHOUT ANY
 * WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
 * FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License along with
 * this program. If not, see <http://www.gnu.org/licenses/>.
 *
 */

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
        final result = SpotlightResponse.fromJson(response.data);
        yield DataSpotlight(result.spotlightArticles, result.nextUrl);
      } catch (e) {}
    }
    if (event is LoadMoreSpolightEvent) {
      if (event.nextUrl != null && event.nextUrl.isNotEmpty) {
        try {
          Response response = await client.getNext(event.nextUrl);
          final results = SpotlightResponse.fromJson(response.data);
          results.spotlightArticles = event.articles
            ..addAll(results.spotlightArticles);
          yield DataSpotlight(results.spotlightArticles, results.nextUrl);
        } catch (e) {}
      }
    }
  }
}
