import 'dart:async';
import 'package:bloc/bloc.dart';
import './bloc.dart';

class HelloBloc extends Bloc<HelloEvent, HelloState> {
  @override
  HelloState get initialState => InitialHelloState();

  @override
  Stream<HelloState> mapEventToState(
    HelloEvent event,
  ) async* {
    // TODO: Add Logic
  }
}
