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
