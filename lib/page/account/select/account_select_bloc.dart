import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:pixez/models/account.dart';
import 'package:shared_preferences/shared_preferences.dart';

import './bloc.dart';

class AccountSelectBloc extends Bloc<AccountSelectEvent, AccountSelectState> {
  static const ACCOUNT_SELECT_NUM = 'account_select_num';

  @override
  AccountSelectState get initialState => InitialAccountSelectState();

  @override
  Stream<AccountSelectState> mapEventToState(
    AccountSelectEvent event,
  ) async* {
    if (event is FetchAllAccountSelectEvent) {
      AccountProvider accountProvider = new AccountProvider();
      await accountProvider.open();
      List<AccountPersist> accounts = await accountProvider.getAllAccount();
      var pre = await SharedPreferences.getInstance();
      yield AllAccountSelectState(
          accounts, pre.getInt(ACCOUNT_SELECT_NUM) ?? 0);
    }
    if (event is DeleteAccountSelectEvent) {
      AccountProvider accountProvider = new AccountProvider();
      await accountProvider.open();
      await accountProvider.delete(event.id);
      add(FetchAllAccountSelectEvent());
    }
    if (event is SelectAccountSelectEvent) {
      var pre = await SharedPreferences.getInstance();
      await pre.setInt(ACCOUNT_SELECT_NUM, event.num);
      yield SelectState();
      add(FetchAllAccountSelectEvent());
    }
  }
}
