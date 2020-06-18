import 'package:mobx/mobx.dart';
import 'package:pixez/models/account.dart';
import 'package:pixez/page/account/select/account_select_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'account_store.g.dart';

class AccountStore = _AccountStoreBase with _$AccountStore;

abstract class _AccountStoreBase with Store {
  AccountProvider accountProvider = new AccountProvider();
  @observable
  AccountPersist now;

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
  }

  @action
  fetch() async {
    await accountProvider.open();
    List<AccountPersist> list = await accountProvider.getAllAccount();
    var pre = await SharedPreferences.getInstance();
    var i = pre.getInt(AccountSelectBloc.ACCOUNT_SELECT_NUM);
    if (list != null && list.isNotEmpty) {
      now = list[i ?? 0];
    }
  }
}
