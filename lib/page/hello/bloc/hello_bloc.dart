import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:pixez/models/account.dart';

import './bloc.dart';

class HelloBloc extends Bloc<HelloEvent, HelloState> {
  @override
  HelloState get initialState => InitialHelloState();

  @override
  Stream<HelloState> mapEventToState(
    HelloEvent event,
  ) async* {
    if (event is FetchDataBaseEvent) {
      AccountProvider accountProvider = new AccountProvider();
      await accountProvider.open();
      List<AccountPersist> list = await accountProvider.getAllAccount();
      if (list.length <= 0) {
        yield NoneUserState();
      } else {
        yield HasUserState(list[0]);
      }
    }
  }
}
