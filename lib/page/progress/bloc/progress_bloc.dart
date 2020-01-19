import 'dart:async';
import 'package:bloc/bloc.dart';
import './bloc.dart';

class ProgressBloc extends Bloc<ProgressEvent, ProgressState> {
  @override
  ProgressState get initialState => InitialProgressState();

  @override
  Stream<ProgressState> mapEventToState(
    ProgressEvent event,
  ) async* {
  }
}
