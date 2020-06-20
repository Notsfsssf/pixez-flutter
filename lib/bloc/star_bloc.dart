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
import 'package:pixez/models/illust.dart';
import 'package:pixez/network/api_client.dart';

import './bloc.dart';

class StarBloc extends Bloc<StarEvent, StarState> {
  final ApiClient client;
  final Illusts illusts;

  StarBloc(this.client, this.illusts);

  @override
  StarState get initialState => InitialStarState(this.illusts.isBookmarked);

  @override
  Stream<StarState> mapEventToState(
    StarEvent event,
  ) async* {
    if (event is ToStarEvent) {
      try {
        Illusts illusts = event.illusts;
        if (illusts.isBookmarked) {
          return;
        }
        await client.postLikeIllust(
            event.illusts.id, event.restrict, event.tags);

        illusts.isBookmarked = true;
        yield InitialStarState(illusts.isBookmarked);
      } catch (e) {}
    }
    if (event is UnStarEvent) {
      try {
        Illusts illusts = event.illusts;
        if (illusts.isBookmarked) {
          return;
        }
        await client.postUnLikeIllust(event.illusts.id);
        illusts.isBookmarked = false;
        yield InitialStarState(illusts.isBookmarked);
      } catch (e) {}
    }
  }
}
