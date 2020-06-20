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
import 'package:pixez/models/recommend.dart';
import 'package:pixez/network/api_client.dart';

import './bloc.dart';

class IllustRelatedBloc extends Bloc<IllustRelatedEvent, IllustRelatedState> {
  final ApiClient client;

  IllustRelatedBloc(this.client);

  @override
  IllustRelatedState get initialState => InitialIllustRelatedState();

  @override
  Stream<IllustRelatedState> mapEventToState(
    IllustRelatedEvent event,
  ) async* {
    if (event is FetchRelatedEvent) {
      try {
        Response response = await client.getIllustRelated(event.id);
        Recommend recommend = Recommend.fromJson(response.data);
        yield DataIllustRelatedState(recommend); //??????
      } catch (e) {}
    }
  }
}
