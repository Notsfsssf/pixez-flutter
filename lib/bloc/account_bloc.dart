import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:pixez/models/account.dart';

import './bloc.dart';

class AccountBloc extends Bloc<AccountEvent, AccountState> {
  @override
  AccountState get initialState => InitialAccountState();

  @override
  Stream<AccountState> mapEventToState(
    AccountEvent event,
  ) async* {
    if (event is DeleteAllAccountEvent) {
      AccountProvider accountProvider = new AccountProvider();
      await accountProvider.open();
      await accountProvider.deleteAll();
      add(FetchDataBaseEvent());
    }
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
