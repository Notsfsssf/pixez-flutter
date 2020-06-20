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
import 'package:pixez/models/user_preview.dart';
import 'package:pixez/network/api_client.dart';

import './bloc.dart';

class NewPainterBloc extends Bloc<NewPainterEvent, NewPainterState> {
  final ApiClient client;

  NewPainterBloc(this.client);

  @override
  NewPainterState get initialState => InitialNewPainterState();

  @override
  Stream<NewPainterState> mapEventToState(
    NewPainterEvent event,
  ) async* {
    if (event is FetchPainterEvent) {
      try {
        final response = await client.getUserFollowing(event.id, event.retrict);
        UserPreviewsResponse userPreviews =
            UserPreviewsResponse.fromJson(response.data);
        yield DataState(userPreviews.user_previews, userPreviews.next_url);
      } catch (e) {
      yield FailState();
      }
    }
    if (event is LoadMoreEvent) {
      try {
        if (event.nextUrl != null) {
          final response = await client.getNext(event.nextUrl);
          UserPreviewsResponse userPreviews =
              UserPreviewsResponse.fromJson(response.data);
          yield DataState(event.users..addAll(userPreviews.user_previews),
              userPreviews.next_url);
        } else {
          yield LoadEndState();
        }
      } catch (e) {}
    }
  }
}
