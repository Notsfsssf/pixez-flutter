/*
 * Copyright (C) 2020. by perol_notsf, All rights reserved
 *
 * This program is free software: you can redistribute it and/or modify it under
 * the terms of the GNU General Public License as published by the Free Software
 * Foundation, either version 3 of the License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful, but WITHOUT ANY
 * WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
 * FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License along with
 * this program. If not, see <http://www.gnu.org/licenses/>.
 *
 */

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
