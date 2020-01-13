import 'dart:async';

import 'package:bloc/bloc.dart';

import './bloc.dart';

class LightingBloc extends Bloc<LightingEvent, LightingState> {
  @override
  LightingState get initialState => LightingInitial();

  @override
  Stream<LightingState> mapEventToState(
    LightingEvent event,
  ) async* {
    // TODO: Add Logic
  }
}
