import 'package:dio/dio.dart';
import 'package:mobx/mobx.dart';
import 'package:pixez/network/account_client.dart';
part 'account_edit_store.g.dart';

class AccountEditStore = _AccountEditStoreBase with _$AccountEditStore;

abstract class _AccountEditStoreBase with Store {
  @observable
  String? errorString;

  @action
 Future<bool> fetch(String newMailAddress, newPassword, oldPassword, newUserAccount) async {
    try {
      final client = AccountClient();
      var response = await client.accountEdit(
          newMailAddress: newMailAddress,
          newPassword: newPassword,
          currentPassword: oldPassword,
          newUserAccount: newUserAccount);
      print(response.data);
      return true;
    } catch (e) {
      if (e is DioException) {
        try {
          var a = e.response!.data['body']['validation_errors'].toString();
          errorString = a;
        } catch (e) {
          errorString = e.toString();
        }
      } else {
        errorString = e.toString();
      }
       return false;
    }
  }
}
