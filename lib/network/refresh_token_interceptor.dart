import 'package:dio/dio.dart';
import 'package:pixez/models/account.dart';
import 'package:pixez/models/error_message.dart';
import 'package:pixez/network/api_client.dart';
import 'package:pixez/network/oauth_client.dart';

class RefreshTokenInterceptor extends Interceptor {
  @override
  Future onRequest(RequestOptions options) async {
    if (options.path.contains('v1/walkthrough/illusts')) return options;
    AccountProvider accountProvider = new AccountProvider();
    await accountProvider.open();
    final allAccount = await accountProvider.getAllAccount();
    AccountPersist accountPersist = allAccount[0];
    options.headers[OAuthClient.AUTHORIZATION] =
        "Bearer " + accountPersist.accessToken;
    return options; //continue
  }

  int bti(bool bool) {
    if (bool) {
      return 1;
    } else
      return 0;
  }

  @override
  onError(DioError err) async {
    if (err.response != null && err.response.statusCode == 400) {
      try {
        final errorMessage = ErrorMessage.fromJson(err.response.data);
        if (errorMessage.error.message.contains("OAuth")) {
          final client = OAuthClient();
          AccountProvider accountProvider = new AccountProvider();
          await accountProvider.open();
          final allAccount = await accountProvider.getAllAccount();
          AccountPersist accountPersist = allAccount[0];
          print("eeeeeeeeeeeeeeeeeeeeeeee");
          final response1 = await client.postRefreshAuthToken(
              refreshToken: accountPersist.refreshToken,
              deviceToken: accountPersist.deviceToken);
          AccountResponse accountResponse =
              Account.fromJson(response1.data).response;
          print("eeeeeeeeeeeeeeeeeeeeeeee11");
          final user = accountResponse.user;
          accountProvider.update(AccountPersist()
            ..id = accountPersist.id
            ..accessToken = accountResponse.accessToken
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
          var request = err.response.request;
          request.headers[OAuthClient.AUTHORIZATION] =
              "Bearer " + accountResponse.accessToken;
          var response = await ApiClient().httpClient.request(
                request.path,
                data: request.data,
                queryParameters: request.queryParameters,
                cancelToken: request.cancelToken,
                options: request,
              );
          return response;
        }
        if (errorMessage.error.message.contains("Limit")) {}
      } catch (e) {
        print(e);
        return e;
      }
    }

    super.onError(err);
  }
}
