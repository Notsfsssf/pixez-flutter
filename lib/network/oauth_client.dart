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
import 'package:device_info/device_info.dart';
import 'package:dio/adapter.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:pixez/constants.dart';
import 'package:pixez/crypto_plugin.dart';
import 'package:pixez/main.dart';

final OAuthClient oAuthClient = OAuthClient();

class OAuthClient {
  final String hashSalt =
      "28c1fdd170a5204386cb1313c7077b34f83e4aaf4aa829ce78c231e05b0bae2c";
  late Dio httpClient;
  static const BASE_OAUTH_URL_HOST = "oauth.secure.pixiv.net";

  final String CLIENT_ID = "MOBrBDS8blbauoSck0ZfDbtuzpyT";
  final String CLIENT_SECRET = "lsACyCD94FhDUtGTXi3QzcFE2uU1hqtDaKeqrdwj";
  final String REFRESH_CLIENT_ID = "KzEZED7aC0vird8jWyHM38mXjNTY";
  final String REFRESH_CLIENT_SECRET =
      "W9JZoJe00qPvJsiyCGT3CCtC6ZUtdpKpzMbNlUGP"; //这换行绝了

  String getIsoDate() {
    DateTime dateTime = new DateTime.now();
    DateFormat dateFormat = new DateFormat("yyyy-MM-dd'T'HH:mm:ss'+00:00'");
    return dateFormat.format(dateTime);
  }

  static final String AUTHORIZATION = "Authorization";

  initA(time) async {
    if (Platform.isAndroid) {
      DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      var headers = this.httpClient.options.headers;
      headers['User-Agent'] =
          "PixivAndroidApp/5.0.166 (Android ${androidInfo.version.release}; ${androidInfo.model})";
      headers['App-OS-Version'] = "Android ${androidInfo.version.release}";
    }
  }

  OAuthClient() {
    String time = getIsoDate();
    this.httpClient = Dio()
      ..options.baseUrl = "https://210.140.131.199"
      ..options.headers = {
        "X-Client-Time": time,
        "X-Client-Hash": getHash(time + hashSalt),
        "User-Agent": "PixivAndroidApp/5.0.155 (Android 6.0; Pixel C)",
        HttpHeaders.acceptLanguageHeader: "zh-CN",
        "App-OS": "Android",
        "App-OS-Version": "Android 6.0",
        "App-Version": "5.0.166",
        "Host": BASE_OAUTH_URL_HOST
      }
      ..options.contentType = Headers.formUrlEncodedContentType;
    (this.httpClient.httpClientAdapter as DefaultHttpClientAdapter)
        .onHttpClientCreate = (client) {
      HttpClient httpClient = new HttpClient();
      httpClient.badCertificateCallback =
          (X509Certificate cert, String host, int port) {
        return true;
      };
      return httpClient;
    };
    if (kDebugMode)
      httpClient.interceptors
          .add(LogInterceptor(responseBody: true, requestBody: true));
    if (userSetting.disableBypassSni) {
      httpClient.options.baseUrl = "https://${BASE_OAUTH_URL_HOST}";
    }
    initA(time);
  }

  static String getHash(String string) {
    var content = new Utf8Encoder().convert(string);
    var digest = md5.convert(content);
    return digest.toString();
  }

  Future<Response> postAuthToken(String userName, String passWord,
      {String deviceToken = "pixiv"}) {
    return httpClient.post("/auth/token", data: {
      "client_id": CLIENT_ID,
      "client_secret": CLIENT_SECRET,
      "grant_type": "password",
      "username": userName,
      "password": passWord,
      "Device_token": deviceToken,
      "get_secure_url": true,
      "include_policy": true
    });
  }

  Future<Response> code2Token(String code) {
    return httpClient.post("/auth/token",
        data: {
          "code": code,
          "redirect_uri":
              "https://app-api.pixiv.net/web/v1/users/auth/pixiv/callback",
          "grant_type": "authorization_code",
          "include_policy": true,
          "client_id": CLIENT_ID,
          "code_verifier": Constants.code_verifier,
          "client_secret": CLIENT_SECRET
        },
        options: Options(contentType: Headers.formUrlEncodedContentType));
  }

  static Future<String> generateWebviewUrl({bool create = false}) async {
    await generateCodeVerify();
    String codeChallenge = await CryptoPlugin.getCodeChallenge();
    String url = !create
        ? "https://app-api.pixiv.net/web/v1/login?code_challenge=${codeChallenge}&code_challenge_method=S256&client=pixiv-android"
        : "https://app-api.pixiv.net/web/v1/provisional-accounts/create?code_challenge=${codeChallenge}&code_challenge_method=S256&client=pixiv-android";
    return url;
  }

  static Future<String> generateCodeVerify() async {
    return await CryptoPlugin.getCodeVer();
  }

  Future<Response> postRefreshAuthToken(
      {refreshToken: String, deviceToken: String}) {
    return httpClient.post("/auth/token", data: {
      "client_id": CLIENT_ID,
      "client_secret": CLIENT_SECRET,
      "grant_type": "refresh_token",
      "refresh_token": refreshToken,
      "include_policy": true
    });
  }

//  @FormUrlEncoded
//  @POST("/api/provisional-accounts/create")
//  fun createProvisionalAccount(@Field("user_name") paramString1: String, @Field("ref") paramString2: String, @Header("Authorization") paramString3: String): Observable<PixivAccountsResponse>

}
