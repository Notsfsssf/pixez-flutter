import 'dart:async';

import 'package:bloc/bloc.dart';

import './bloc.dart';

class RankingBloc extends Bloc<RankingEvent, RankingState> {
  @override
  RankingState get initialState => InitialRankingState();

  @override
  Stream<RankingState> mapEventToState(
    RankingEvent event,
  ) async* {
    // TODO: Add Logic
  }
}
