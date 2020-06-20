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
import 'package:flutter/cupertino.dart';
import 'package:pixez/models/novel_text_response.dart';
import 'package:pixez/network/api_client.dart';

import './bloc.dart';

class NovelTextBloc extends Bloc<NovelTextEvent, NovelTextState> {
  ApiClient client;
  int id;

  NovelTextBloc(this.client, {@required this.id});

  @override
  NovelTextState get initialState => InitialNovelTextState();

  @override
  Stream<NovelTextState> mapEventToState(
    NovelTextEvent event,
  ) async* {
    if (event is FetchEvent) {
     try{
       var response = await client.getNovelText(id);
       NovelTextResponse novelTextResponse =
       NovelTextResponse.fromJson(response.data);
       yield DataNovelState(novelTextResponse);
     }catch(e){}
    }
  }
}
