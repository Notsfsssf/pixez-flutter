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
import 'package:pixez/models/bookmark_detail.dart';
import 'package:pixez/network/api_client.dart';

import './bloc.dart';

class BookmarkDetailBloc
    extends Bloc<BookmarkDetailEvent, BookmarkDetailState> {
  final ApiClient client;

  BookmarkDetailBloc(this.client);
  @override
  BookmarkDetailState get initialState => InitialBookmarkDetailState();

  @override
  Stream<BookmarkDetailState> mapEventToState(
    BookmarkDetailEvent event,
  ) async* {
    if (event is FetchBookmarkDetailEvent) {
      try {
        Response response = await client.getIllustBookmarkDetail(event.id);
        BookMarkDetailResponse bookMarkDetailResponse =
            BookMarkDetailResponse.fromJson(response.data);
        yield DataBookmarkDetailState(bookMarkDetailResponse);
      } catch (e) {}
    }
  }
}
