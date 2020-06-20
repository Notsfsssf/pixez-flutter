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
import 'package:shared_preferences/shared_preferences.dart';

import './bloc.dart';

class RankingBloc extends Bloc<RankingEvent, RankingState> {
  static const MODE_LIST = 'mode_list';
  List<String> modeList = [
    "day",
    "day_male",
    "day_female",
    "week_original",
    "week_rookie",
    "week",
    "month",
    "day_r18",
    "week_r18"
  ];

  @override
  RankingState get initialState => InitialRankingState();

  @override
  Stream<RankingState> mapEventToState(
    RankingEvent event,
  ) async* {
    if (event is DateChangeEvent) {
      var pre = await SharedPreferences.getInstance();
      var stringList = pre.getStringList(MODE_LIST);
      if (stringList == null || stringList.isEmpty) {
        yield ModifyModeListState();
        return;
      }
      yield DateState(event.dateTime, stringList ?? modeList);
    }
    if (event is ResetEvent) {
      var pre = await SharedPreferences.getInstance();
      await pre.remove(MODE_LIST);
      add(DateChangeEvent(null));
    }
    if (event is SaveChangeEvent) {
      var pre = await SharedPreferences.getInstance();
      List<String> saveList = [];
      event.selectMap.forEach((s, b) {
        if (b) saveList.add(s);
      });
      await pre.setStringList(MODE_LIST, saveList);
      add(DateChangeEvent(null));
    }
  }
}
