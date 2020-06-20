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
import 'package:pixez/models/error_message.dart';
import 'package:pixez/models/illust.dart';
import 'package:pixez/network/api_client.dart';

import './bloc.dart';

class IllustBloc extends Bloc<IllustEvent, IllustState> {
  final ApiClient client;

  final int id;

  Illusts illust;

  IllustBloc(this.client, this.id, {this.illust});

  @override
  IllustState get initialState => InitialIllustState();

  @override
  Stream<IllustState> mapEventToState(
    IllustEvent event,
  ) async* {
    if (event is FetchIllustDetailEvent) {
      if (illust == null) {
        try {
          Response response = await client.getIllustDetail(id);
          illust = Illusts.fromJson(response.data['illust']);
          yield DataIllustState(illust);
        } on DioError catch (e) {
          if (e.response != null) {
            ErrorMessage errorMessage = ErrorMessage.fromJson(e.response.data);
            yield FZFIllustState(errorMessage);
          }
        }
      } else
        yield DataIllustState(illust);
    }
    if (event is FollowUserIllustEvent) {
      try {
        if (illust.user.isFollowed) {
          Response response = await client.postUnFollowUser(illust.user.id);
          illust.user.isFollowed = false;
        } else {
          Response response = await client.postFollowUser(illust.user.id, 'public');
          illust.user.isFollowed = true;
        }
        yield DataIllustState(illust);
      } catch (e) {}
    }
  }
}
