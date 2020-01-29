import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:pixez/models/account.dart';
import 'package:pixez/page/account/select/account_select_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
    if (event is UpdateAccountEvent) {
      AccountProvider accountProvider = new AccountProvider();
      await accountProvider.open();
      await accountProvider.update(event.accountPersist);
      add(FetchDataBaseEvent());
    }
    if (event is FetchDataBaseEvent) {
      AccountProvider accountProvider = new AccountProvider();
      await accountProvider.open();
      List<AccountPersist> list = await accountProvider.getAllAccount();
      if (list.length <= 0) {
        yield NoneUserState();
      } else {
        var pre = await SharedPreferences.getInstance();
        var i = pre.getInt(AccountSelectBloc.ACCOUNT_SELECT_NUM);
        yield HasUserState(list[i ?? 0]);
      }
    }
  }
}
