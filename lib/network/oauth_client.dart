import 'dart:convert';
import 'dart:core';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:crypto/crypto.dart';
import 'package:dio/adapter.dart';

import 'package:intl/intl.dart';
class OAuthClient {
  final String hashSalt =
      "28c1fdd170a5204386cb1313c7077b34f83e4aaf4aa829ce78c231e05b0bae2c";
  Dio httpClient;

  String getIsoDate() {
    DateTime dateTime =new DateTime.now();
 DateFormat dateFormat = new DateFormat("yyyy-MM-dd'T'HH:mm:ss'+00:00'");
 
    return   dateFormat.format(dateTime);
  }

  OAuthClient({
    Dio httpClient,
  }) {
    String time = getIsoDate();
    this.httpClient = httpClient ?? Dio()
      ..interceptors.add(LogInterceptor(responseBody: true, requestBody: true))
      ..options.baseUrl = "https://210.140.131.219"
      ..options.headers = {
        "X-Client-Time": time,
        "X-Client-Hash": getHash(time + hashSalt),
        "User-Agent": "PixivAndroidApp/5.0.155 (Android 6.0; Pixel C)",
        "Accept-Language": "zh-CN",
        "App-OS": "Android",
        "App-OS-Version": "Android 6.0",
        "App-Version": "5.0.166",
        "Host": "oauth.secure.pixiv.net"
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
  }

  static String getHash(String string) {
    var content = new Utf8Encoder().convert(string);
    var digest = md5.convert(content);
    return digest.toString();
  }

  Future<Response> postAuthToken(String userName, String passWord,
      {String deviceToken = "pixiv"}) {
    return httpClient.post("/auth/token", data: {
      "client_id": "MOBrBDS8blbauoSck0ZfDbtuzpyT",
      "client_secret": "lsACyCD94FhDUtGTXi3QzcFE2uU1hqtDaKeqrdwj",
      "grant_type": "password",
      "username": userName,
      "password": passWord,
      "Device_token": deviceToken,
      "get_secure_url": true,
      "include_policy": true
    });
  }

  Future<Response> postRefreshAuthToken(
      {refreshToken: String, deviceToken: String}) {
    return httpClient.post("", queryParameters: {
      "client_id": "",
      "client_secret": "",
      "grant_type": "",
      "refresh_token": refreshToken,
      "device_token": deviceToken,
    });
  }
}
