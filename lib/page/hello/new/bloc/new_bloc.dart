import 'dart:async';
import 'package:bloc/bloc.dart';
import './bloc.dart';

class NewBloc extends Bloc<NewEvent, NewState> {
  @override
  NewState get initialState => InitialNewState();

  @override
  Stream<NewState> mapEventToState(
    NewEvent event,
  ) async* {
    if(event is NewInitalEvent){
      yield NewDataRestrictState("${event.newRestrict}","${event.bookRestrict}","${event.painterRestrict}");
    }
    if (event is RestrictEvent) {
      yield NewDataRestrictState("${event.newRestrict}","${event.bookRestrict}","${event.painterRestrict}");
    }

  }
}
