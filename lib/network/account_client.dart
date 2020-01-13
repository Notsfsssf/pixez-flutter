import 'dart:convert';
import 'dart:core';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:dio/adapter.dart';
import 'package:dio/dio.dart';
import 'package:intl/intl.dart';

class AccountClient {
  Dio httpClient;
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

  AccountClient() {
    String time = getIsoDate();
    this.httpClient = Dio()
      ..options.baseUrl = "https://210.140.131.219"
      ..options.headers = {
        "X-Client-Time": time,
        "X-Client-Hash": getHash(time + hashSalt),
        "User-Agent": "PixivAndroidApp/5.0.155 (Android 6.0; Pixel C)",
        "Accept-Language": "zh-CN",
        "App-OS": "Android",
        "App-OS-Version": "Android 6.0",
        "App-Version": "5.0.166",
        "Host": BASE_API_URL_HOST
      }
      ..options.connectTimeout = 5000
      ..interceptors.add(LogInterceptor(requestBody: true, responseBody: true));
    (this.httpClient.httpClientAdapter as DefaultHttpClientAdapter)
        .onHttpClientCreate = (client) {
      HttpClient httpClient = new HttpClient();
      httpClient.badCertificateCallback =
          (X509Certificate cert, String host, int port) {
        return true;
      };
      return httpClient;
    };
  }
}
