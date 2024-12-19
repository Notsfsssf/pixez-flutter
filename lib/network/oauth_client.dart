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
import 'package:device_info_plus/device_info_plus.dart';
import 'package:dio/dio.dart';
import 'package:dio_compatibility_layer/dio_compatibility_layer.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:pixez/constants.dart';
import 'package:pixez/crypto_plugin.dart';
import 'package:pixez/er/hoster.dart';
import 'package:pixez/main.dart';
import 'package:rhttp/rhttp.dart' as r;

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

  Future<Dio> createDioClient() async {
    final compatibleClient = await r.RhttpCompatibleClient.create(
        settings: userSetting.disableBypassSni
            ? null
            : r.ClientSettings(
                tlsSettings: r.TlsSettings(
                    verifyCertificates: false, sni: false),
                dnsSettings: r.DnsSettings.dynamic(
                  resolver: (host) async {
                    final ip = Hoster.oauth();
                    return [ip];
                  },
                ),
              ));
    httpClient.httpClientAdapter = ConversionLayerAdapter(compatibleClient);
    if (Platform.isAndroid) {
      try {
        DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
        AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
        var headers = httpClient.options.headers;
        headers['User-Agent'] =
            "PixivAndroidApp/5.0.166 (Android ${androidInfo.version.release}; ${androidInfo.model})";
        headers['App-OS-Version'] = "Android ${androidInfo.version.release}";
      } catch (e) {}
    }
    return httpClient;
  }

  OAuthClient() {
    String time = getIsoDate();
    httpClient = Dio(BaseOptions(
        baseUrl: 'https://${BASE_OAUTH_URL_HOST}',
        headers: {
          "X-Client-Time": time,
          "X-Client-Hash": getHash(time + hashSalt),
          "User-Agent": "PixivAndroidApp/5.0.155 (Android 6.0; Pixel C)",
          HttpHeaders.acceptLanguageHeader: "zh-CN",
          "App-OS": "Android",
          "App-OS-Version": "Android 6.0",
          "App-Version": "5.0.166",
        },
        contentType: Headers.formUrlEncodedContentType));
    if (kDebugMode) {
      httpClient.interceptors.add(LogInterceptor(
          responseBody: true, responseHeader: true, requestBody: true));
    }
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
      {refreshToken = String, deviceToken = String}) {
    return httpClient.post("/auth/token", data: {
      "client_id": CLIENT_ID,
      "client_secret": CLIENT_SECRET,
      "grant_type": "refresh_token",
      "refresh_token": refreshToken,
      "include_policy": true
    });
  }
}
