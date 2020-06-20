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
import 'package:pixez/models/user_preview.dart';
import 'package:pixez/network/api_client.dart';

import './bloc.dart';

class ResultPainterBloc extends Bloc<ResultPainterEvent, ResultPainterState> {
  final ApiClient client;

  ResultPainterBloc(this.client);
  @override
  ResultPainterState get initialState => InitialResultPainterState();

  @override
  Stream<ResultPainterState> mapEventToState(
    ResultPainterEvent event,
  ) async* {
    if (event is FetchEvent) {
      try {
        Response response = await client.getSearchUser(event.word);
        UserPreviewsResponse userPreviewsResponse =
            UserPreviewsResponse.fromJson(response.data);
        yield ResultPainterDataState(
            userPreviewsResponse.user_previews, userPreviewsResponse.next_url);
        yield RefreshState(success: true);
      } catch (e) {
        yield RefreshState(success: false);
      }
    }
    if (event is LoadMoreEvent) {
      if (event.nextUrl != null && event.nextUrl.isNotEmpty) {
        try {
          Response response = await client.getNext(event.nextUrl);
          UserPreviewsResponse userPreviewsResponse =
              UserPreviewsResponse.fromJson(response.data);
          yield ResultPainterDataState(userPreviewsResponse.user_previews,
              userPreviewsResponse.next_url);
          yield LoadMoreState(success: true, noMore: false);
        } catch (e) {
          yield LoadMoreState(success: false, noMore: false);
        }
      }
      else{
        yield LoadMoreState(success: true, noMore: true);
      }
    }
  }
}
