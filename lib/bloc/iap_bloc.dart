import 'dart:async';
import 'package:bloc/bloc.dart';
import './bloc.dart';

class IapBloc extends Bloc<IapEvent, IapState> {
  @override
  IapState get initialState => InitialIapState();

  @override
  Stream<IapState> mapEventToState(
    IapEvent event,
  ) async* {
    if (event is ThanksEvent) {
      yield ThanksState();
    }
    if (event is InitialEvent) {

    }
    if (event is FetchIapEvent) {


    }
    if (event is MakeIapEvent) {

    }
  }
}
