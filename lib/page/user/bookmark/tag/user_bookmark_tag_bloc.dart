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
import 'package:pixez/models/illust_bookmark_tags_response.dart';
import 'package:pixez/network/api_client.dart';

import './bloc.dart';

class UserBookmarkTagBloc
    extends Bloc<UserBookmarkTagEvent, UserBookmarkTagState> {
  final ApiClient client;

  UserBookmarkTagBloc(this.client);

  @override
  UserBookmarkTagState get initialState => InitialUserBookmarkTagState();

  @override
  Stream<UserBookmarkTagState> mapEventToState(
    UserBookmarkTagEvent event,
  ) async* {
    if (event is FetchUserBookmarkTagEvent) {
      try {
        var result = await client.getUserBookmarkTagsIllust(event.id,
            restrict: event.restrict);
        yield DataUserBookmarkTagState(result.bookmarkTags, result.nextUrl);
        yield RefreshSuccess();
      } catch (e) {
        yield RefreshFail();
      }
    }
    if (event is LoadMoreUserBookmarkTagEvent) {
      if (event.nextUrl != null && event.nextUrl.isNotEmpty) {
        try {
          final result = await client.getNext(event.nextUrl);
          var r = IllustBookmarkTagsResponse.fromJson(result.data);
          yield DataUserBookmarkTagState(
              event.bookmarkTags..addAll(r.bookmarkTags), r.nextUrl);
          yield LoadMoreSuccess();
        } catch (e) {
          print(e);
          yield LoadMoreFail();
        }
      } else {
        yield LoadMoreEnd();
      }
    }
  }
}
