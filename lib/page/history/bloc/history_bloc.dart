import 'dart:async';
import 'package:bloc/bloc.dart';
import './bloc.dart';

class HistoryBloc extends Bloc<HistoryEvent, HistoryState> {
  @override
  HistoryState get initialState => InitialHistoryState();

  @override
  Stream<HistoryState> mapEventToState(
    HistoryEvent event,
  ) async* {
    // TODO: Add Logic
  }
}
