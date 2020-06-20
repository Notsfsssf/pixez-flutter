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
import 'package:pixez/models/recommend.dart';
import 'package:pixez/network/api_client.dart';

import './bloc.dart';

class NewIllustBloc extends Bloc<NewIllustEvent, NewIllustState> {
  final ApiClient client;

  NewIllustBloc(this.client);

  @override
  NewIllustState get initialState => InitialNewIllustState();

  @override
  Stream<NewIllustState> mapEventToState(
    NewIllustEvent event,
  ) async* {
    if (event is FetchIllustEvent) {
      try {
        final response = await client.getFollowIllusts(event.restrict);
        Recommend recommend = Recommend.fromJson(response.data);
        yield DataNewIllustState(recommend.illusts, recommend.nextUrl);
      } catch (e) {
        yield FailIllustState();
      }
    }
    if (event is LoadMoreEvent) {
      if (event.nextUrl != null) {
        try {
          final response = await client.getNext(event.nextUrl);
          Recommend recommend = Recommend.fromJson(response.data);
          final ill = event.illusts..addAll(recommend.illusts);
          print(ill.length);
          yield DataNewIllustState(ill, recommend.nextUrl);
        } catch (e) {}
      } else {}
    }
  }
}
