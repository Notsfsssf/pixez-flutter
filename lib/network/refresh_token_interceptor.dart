import 'package:dio/dio.dart';
import 'package:pixez/main.dart';
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

  DateTime successRefreshDate = DateTime.now();

  @override
  onError(DioError err) async {
    ApiClient.httpClient.interceptors.requestLock.lock();
    DateTime errorDate = DateTime.now();
    if (err.response != null &&
        err.response.statusCode == 400 &&
        errorDate.millisecondsSinceEpoch >=
            successRefreshDate.millisecondsSinceEpoch) {
      try {
        ErrorMessage errorMessage = ErrorMessage.fromJson(err.response.data);
        if (errorMessage.error.message.contains("OAuth") &&
            accountStore.now != null) {
          final client = OAuthClient();
          AccountPersist accountPersist = accountStore.now;
          print("eeeeeeeeeeeeeeeeeeeeeeee");
          Response response1 = await client.postRefreshAuthToken(
              refreshToken: accountPersist.refreshToken,
              deviceToken: accountPersist.deviceToken);
          AccountResponse accountResponse =
              Account.fromJson(response1.data).response;
          print("eeeeeeeeeeeeeeeeeeeeeeee11");
          final user = accountResponse.user;
          accountStore.updateSingle(AccountPersist()
            ..id = accountPersist.id
            ..accessToken = accountResponse.accessToken
            ..deviceToken = accountResponse.deviceToken
            ..refreshToken = accountResponse.refreshToken
            ..userImage = user.profileImageUrls.px170x170
            ..userId = user.id
            ..name = user.name
            ..passWord = accountPersist.passWord
            ..isMailAuthorized = bti(user.isMailAuthorized)
            ..isPremium = bti(user.isPremium)
            ..mailAddress = user.mailAddress
            ..account = user.account
            ..xRestrict = user.xRestrict);
          var request = err.response.request;
          request.headers[OAuthClient.AUTHORIZATION] =
              "Bearer " + accountResponse.accessToken;
          var response = await ApiClient.httpClient.request(
            request.path,
            data: request.data,
            queryParameters: request.queryParameters,
            cancelToken: request.cancelToken,
            options: request,
          );
          ApiClient.httpClient.interceptors.requestLock.unlock();
          successRefreshDate = DateTime.now();
          return response;
        }
        if (errorMessage.error.message.contains("Limit")) {}
      } catch (e) {
        ApiClient.httpClient.interceptors.requestLock.unlock();
        print(e);
        return e;
      }
    }
    ApiClient.httpClient.interceptors.requestLock.unlock();
    super.onError(err);
  }
}
