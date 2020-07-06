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
import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:pixez/models/novel_recom_response.dart';
import 'package:pixez/network/api_client.dart';

import './bloc.dart';

class NovelRecomBloc extends Bloc<NovelRecomEvent, NovelRecomState> {
  final ApiClient client;

  NovelRecomBloc(this.client);

  @override
  NovelRecomState get initialState => InitialNovelRecomState();

  String getPrettyJSONString(jsonObject) {
    var encoder = new JsonEncoder.withIndent("     ");
    return encoder.convert(jsonObject);
  }

  @override
  Stream<NovelRecomState> mapEventToState(
    NovelRecomEvent event,
  ) async* {
    if (event is LoadMoreNovelRecomEvent) {
      if (event.nextUrl != null && event.nextUrl.isNotEmpty) {
        try {
          var response = await client.getNext(event.nextUrl);
          NovelRecomResponse novelRecomResponse =
              NovelRecomResponse.fromJson(response.data);
          yield DataNovelRecomState(
              event.novels..addAll(novelRecomResponse.novels),
              novelRecomResponse.nextUrl);
        } catch (e) {}
      }
    }
    if (event is NovelRecomEvent) {
      try {
        var response = await client.getNovelRecommended();
        NovelRecomResponse novelRecomResponse =
            NovelRecomResponse.fromJson(response.data);
        yield DataNovelRecomState(
            novelRecomResponse.novels, novelRecomResponse.nextUrl);
      } catch (e) {}
    }
  }
}
