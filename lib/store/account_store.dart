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

import 'package:mobx/mobx.dart';
import 'package:pixez/er/prefer.dart';
import 'package:pixez/models/account.dart';

part 'account_store.g.dart';

class AccountStore = _AccountStoreBase with _$AccountStore;

abstract class _AccountStoreBase with Store {
  AccountProvider accountProvider = new AccountProvider();
  @observable
  AccountPersist? now;
  @observable
  int index = 0;
  @observable
  bool feching = false;

  ObservableList<AccountPersist> accounts = ObservableList();

  @action
  select(int index) async {
    await Prefer.setInt('account_select_num', index);
    now = accounts[index];
    this.index = index;
  }

  @action
  deleteAll() async {
    await accountProvider.open();
    await accountProvider.deleteAll();
    now = null;
  }

  @action
  updateSingle(AccountPersist accountPersist) async {
    await accountProvider.open();
    await accountProvider.update(accountPersist);
    await fetch();
  }

  @action
  deleteSingle(int id) async {
    await accountProvider.open();
    await accountProvider.delete(id);
    await fetch();
  }

  @action
  fetch() async {
    feching = true;
    try {
      await accountProvider.open();
      List<AccountPersist> list = await accountProvider.getAllAccount();
      accounts.clear();
      accounts.addAll(list);
      var i = Prefer.getInt('account_select_num');
      if (list.isNotEmpty) {
        index = i ?? 0;
        now = list[i ?? 0];
      }
    } catch (e) {}
    feching = false;
  }
}
