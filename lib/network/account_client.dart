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

import 'dart:convert';
import 'dart:core';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:intl/intl.dart';
import 'package:pixez/models/account.dart';
import 'package:pixez/network/oauth_client.dart';

class AccountClient {
  late Dio httpClient;
  final String hashSalt =
      "28c1fdd170a5204386cb1313c7077b34f83e4aaf4aa829ce78c231e05b0bae2c";
  static const BASE_API_URL_HOST = 'accounts.pixiv.net';

  String getIsoDate() {
    DateTime dateTime = new DateTime.now();
    DateFormat dateFormat = new DateFormat("yyyy-MM-dd'T'HH:mm:ss'+00:00'");
    return dateFormat.format(dateTime);
  }

  static String getHash(String string) {
    var content = new Utf8Encoder().convert(string);
    var digest = md5.convert(content);
    return digest.toString();
  }

  Future<Response> createProvisionalAccount(String user_name) {
    return httpClient.post("/api/provisional-accounts/create",
        data: {
          "user_name": user_name,
          "ref": "pixiv_android_app_provisional_account"
        },
        options:
            Options(contentType: Headers.formUrlEncodedContentType, headers: {
          "Authorization": "Bearer l-f9qZ0ZyqSwRyZs8-MymbtWBbSxmCu1pmbOlyisou8"
        }));
  }

  Future<Response> accountEdit(
      {String? newMailAddress,
      String? currentPassword,
      newPassword,
      newUserAccount}) async {
    AccountProvider accountProvider = new AccountProvider();
    await accountProvider.open();
    final allAccount = await accountProvider.getAllAccount();
    AccountPersist accountPersist = allAccount[0];
    currentPassword = accountPersist.passWord;
    return httpClient.post("/api/account/edit",
        data: {
          "new_mail_address": newMailAddress,
          "new_user_account": newUserAccount,
          "current_password": currentPassword,
          "new_password": newPassword
        }..removeWhere((f, n) => n == null),
        options: Options(
            contentType: Headers.formUrlEncodedContentType,
            headers: {
              OAuthClient.AUTHORIZATION: "Bearer " + accountPersist.accessToken
            }));
  }

  AccountClient() {
    String time = getIsoDate();
    this.httpClient = Dio()
      ..options.baseUrl = "https://210.140.131.219"
      ..options.headers = {
        "X-Client-Time": time,
        "X-Client-Hash": getHash(time + hashSalt),
        "User-Agent": "PixivAndroidApp/5.0.155 (Android 6.0; Pixel C)",
        HttpHeaders.acceptLanguageHeader: "zh-CN",
        "App-OS": "Android",
        "App-OS-Version": "Android 6.0",
        "App-Version": "5.0.166",
        "Host": BASE_API_URL_HOST
      }
      ..options.connectTimeout = Duration(seconds: 5)
      ..interceptors.add(LogInterceptor(requestBody: true, responseBody: true));
    httpClient.httpClientAdapter = IOHttpClientAdapter(createHttpClient: () {
        HttpClient httpClient = HttpClient();
        httpClient.badCertificateCallback = (X509Certificate cert, String host, int port) => true;
        return httpClient;
      });
  }
}
