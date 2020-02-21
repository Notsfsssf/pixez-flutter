import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import './bloc.dart';

class ControllerBloc extends Bloc<ControllerEvent, ControllerState> {
  static void whatever({@required int tapTime,@required BuildContext context,@required String route}) {
    var spaceTime = DateTime.now().millisecondsSinceEpoch - tapTime;
    print("${spaceTime}/${tapTime}");
    if (spaceTime > 2000) {
      tapTime = DateTime.now().millisecondsSinceEpoch;
    } else {
      BlocProvider.of<ControllerBloc>(context)
          .add(ScrollToTopEvent(route));
    }
  }

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
