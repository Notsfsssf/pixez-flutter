import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:pixez/models/account.dart';

import './bloc.dart';

class RouteBloc extends Bloc<RouteEvent, RouteState> {
  @override
  RouteState get initialState => InitialRouteState();

  @override
  Stream<RouteState> mapEventToState(
    RouteEvent event,
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
