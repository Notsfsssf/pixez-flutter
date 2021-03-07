import 'package:dio/dio.dart';
import 'package:mobx/mobx.dart';
import 'package:pixez/models/account.dart';
import 'package:pixez/models/login_error_response.dart';
import 'package:pixez/network/oauth_client.dart';

part 'login_store.g.dart';

class LoginStore = _LoginStoreBase with _$LoginStore;

abstract class _LoginStoreBase with Store {
  final OAuthClient client = oAuthClient;

  int bti(bool bool) {
    if (bool) {
      return 1;
    } else
      return 0;
  }

  @observable
  String? errorMessage;

/*  @action
  Future<bool> auth(String username, password, {String? deviceToken}) async {
    try {
      final response = await client.postAuthToken(username, password,
          deviceToken: deviceToken!);
      AccountResponse accountResponse =
          Account.fromJson(response.data).response;
      User user = accountResponse.user;
      AccountProvider accountProvider = new AccountProvider();
      await accountProvider.open();
      accountProvider.insert(AccountPersist()
        ..accessToken = accountResponse.accessToken
        ..passWord = password
        ..deviceToken = accountResponse.deviceToken
        ..refreshToken = accountResponse.refreshToken
        ..userImage = user.profileImageUrls.px170x170
        ..userId = user.id
        ..name = user.name
        ..isMailAuthorized = bti(user.isMailAuthorized)
        ..isPremium = bti(user.isPremium)
        ..mailAddress = user.mailAddress
        ..account = user.account
        ..xRestrict = user.xRestrict);
      return true;
    } on DioError catch (e) {
      if (e == null) {
        return false;
      }
      if (e.response != null && e.response!.data != null)
        errorMessage =
            LoginErrorResponse.fromJson(e.response!.data).errors.system.message;
      else
        errorMessage = e.message;
      return false;
    }
  }*/
}
