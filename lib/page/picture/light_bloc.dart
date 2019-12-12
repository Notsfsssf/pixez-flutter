import 'dart:async';

import 'package:bloc/bloc.dart';

import './bloc.dart';

class LightBloc extends Bloc<LightEvent, LightState> {
  @override
  LightState get initialState => InitialLightState();

  @override
  Stream<LightState> mapEventToState(
    LightEvent event,
  ) async* {
    // TODO: Add Logic
  }
}
