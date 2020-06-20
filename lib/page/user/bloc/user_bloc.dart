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
import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:pixez/models/user_detail.dart';
import 'package:pixez/network/api_client.dart';

import './bloc.dart';

class UserBloc extends Bloc<UserEvent, UserState> {
  final ApiClient client;

  UserBloc(this.client);
  @override
  UserState get initialState => InitialUserState();

  @override
  Stream<UserState> mapEventToState(
    UserEvent event,
  ) async* {
    if (event is FetchEvent) {
      try {
        Response response = await client.getUser(event.id);
        UserDetail userDetail = UserDetail.fromJson(response.data);
        yield UserDataState(userDetail, "public");
      } on DioError catch (e) {
        if (e.response != null &&
            e.response.statusCode == HttpStatus.notFound) {
          yield FZFState();
        }
      }
    }
    if (event is ShowSheetEvent) {
      yield ShowSheetState();
    }
    if (event is ChoiceRestrictEvent) {
      yield UserDataState(event.userDetail, "${event.restrict}");
    }
    if (event is FollowUserEvent) {
      if (event.userDetail.user.is_followed) {
        try {
          Response response =
              await client.postUnFollowUser(event.userDetail.user.id);
          yield UserDataState(
              event.userDetail..user.is_followed = false, "${event.restrict}");
        } catch (e) {
        }
      } else {
        try {
          Response response = await client.postFollowUser(
              event.userDetail.user.id,event.followRestrict);
          yield UserDataState(
              event.userDetail..user.is_followed = true, "${event.restrict}");
        } catch (e) {}
      }
    }
  }
}
