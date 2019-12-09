import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:flutter/cupertino.dart';

import './bloc.dart';

class RankingBloc extends Bloc<RankingEvent, RankingState> {
  @override
  RankingState get initialState => InitialRankingState();

  @override
  Stream<RankingState> mapEventToState(
    RankingEvent event,
  ) async* {
    if (event is DateChangeEvent) {
      debugPrint("bloccccccccccccccccccccccc");
      yield DateState(event.dateTime);
    }
  }
}
