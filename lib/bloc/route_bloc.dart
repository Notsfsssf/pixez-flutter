import 'dart:async';
import 'package:bloc/bloc.dart';
import './bloc.dart';

class RouteBloc extends Bloc<RouteEvent, RouteState> {
  @override
  RouteState get initialState => InitialRouteState();

  @override
  Stream<RouteState> mapEventToState(
    RouteEvent event,
  ) async* {
    // TODO: Add Logic
  }
}
