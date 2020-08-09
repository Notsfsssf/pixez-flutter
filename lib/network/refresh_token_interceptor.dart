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

import 'package:bot_toast/bot_toast.dart';
import 'package:dio/dio.dart';
import 'package:pixez/main.dart';
import 'package:pixez/models/account.dart';
import 'package:pixez/models/error_message.dart';
import 'package:pixez/network/api_client.dart';
import 'package:pixez/network/oauth_client.dart';

class RefreshTokenInterceptor extends Interceptor {
  String getToken() {
    String result = "Bearer " + accountStore.now.accessToken;
    return result;
  }

  @override
  Future onRequest(RequestOptions options) async {
    if (options.path.contains('v1/walkthrough/illusts')) return options;
    options.headers[OAuthClient.AUTHORIZATION] = getToken();
    return options; //continue
  }

  int bti(bool bool) {
    if (bool) {
      return 1;
    } else
      return 0;
  }

  int lastRefreshTime = 0;
  @override
  onError(DioError err) async {
    if (err.response != null && err.response.statusCode == 400) {
      DateTime dateTime = DateTime.now();
      if ((dateTime.millisecondsSinceEpoch - lastRefreshTime) > 200000) {
        try {
          ErrorMessage errorMessage = ErrorMessage.fromJson(err.response.data);
          if (errorMessage.error.message.contains("OAuth") &&
              accountStore.now != null) {
            lastRefreshTime = DateTime.now().millisecondsSinceEpoch;
            final client = OAuthClient();
            AccountPersist accountPersist = accountStore.now;
            Response response1 = await client.postRefreshAuthToken(
                refreshToken: accountPersist.refreshToken,
                deviceToken: accountPersist.deviceToken);
            AccountResponse accountResponse =
                Account.fromJson(response1.data).response;
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
            apiClient.httpClient.unlock();
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
          lastRefreshTime = 0;
          return e;
        }
      }
    }
    super.onError(err);
  }
}
