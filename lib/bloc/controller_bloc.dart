import 'dart:async';
import 'package:bloc/bloc.dart';
import './bloc.dart';

class ControllerBloc extends Bloc<ControllerEvent, ControllerState> {
  @override
  ControllerState get initialState => InitialControllerState();

  @override
  Stream<ControllerState> mapEventToState(
    ControllerEvent event,
  ) async* {
    if (event is ScrollToTopEvent) {
      yield ScrollToTopState(event.name);
    }
  }
}
