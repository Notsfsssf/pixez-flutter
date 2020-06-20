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

class WalkThroughBloc extends Bloc<WalkThroughEvent, WalkThroughState> {
  final ApiClient client;

  WalkThroughBloc(this.client);

  @override
  WalkThroughState get initialState => InitialWalkThroughState();

  @override
  Stream<WalkThroughState> mapEventToState(
    WalkThroughEvent event,
  ) async* {
    if (event is FetchWalkThroughEvent) {
      var response = await client.walkthroughIllusts();
      yield DataWalkThroughState(response.illusts, response.nextUrl);
    }
    if (event is LoadMoreWalkThroughEvent) {
      if (event.nextUrl != null && event.nextUrl.isNotEmpty) {
        var result = await client.getNext(event.nextUrl);
        var response = Recommend.fromJson(result.data);
        yield DataWalkThroughState(
            event.illusts..addAll(response.illusts), response.nextUrl);
      }
    }
  }
}
