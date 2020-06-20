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
import 'package:pixez/models/illust.dart';
import 'package:pixez/network/api_client.dart';

import './bloc.dart';

class PictureBloc extends Bloc<PictureEvent, PictureState> {
  final ApiClient client;

  PictureBloc(this.client);

  @override
  PictureState get initialState => InitialPictureState();

  @override
  Stream<PictureState> mapEventToState(
    PictureEvent event,
  ) async* {
    if (event is StarPictureEvent) {
      if (!event.illusts.isBookmarked) {
        try {
          Response response = await client.postLikeIllust(
              event.illusts.id, event.restrict, event.tags);
          Illusts illusts = event.illusts;
          illusts.isBookmarked = true;
          yield DataState(illusts);
        } catch (e) {}
      } else {
        try {
          Response response = await client.postUnLikeIllust(event.illusts.id);
          Illusts illusts = event.illusts;
          illusts.isBookmarked = false;
          yield DataState(illusts);
        } catch (e) {}
      }
    }


  }
}
