import 'dart:async';
import 'package:bloc/bloc.dart';
import './bloc.dart';

class HistoryPersistBloc extends Bloc<HistoryPersistEvent, HistoryPersistState> {
  @override
  HistoryPersistState get initialState => InitialHistoryPersistState();

  @override
  Stream<HistoryPersistState> mapEventToState(
    HistoryPersistEvent event,
  ) async* {
    if(event is FetchHistoryPersistEvent){
      
    }
  }
}
