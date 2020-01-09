import 'dart:io';

import 'package:dio/adapter.dart';
import 'package:dio/dio.dart';
import 'package:pixez/models/onezero_response.dart';

class OnezeroClient {
  Dio httpClient;
  static const String URL_DNS_RESOLVER = "https://1.0.0.1";
  OnezeroClient() {
    this.httpClient =
        Dio(BaseOptions(baseUrl: URL_DNS_RESOLVER, connectTimeout: 5000))
          ..interceptors
              .add(LogInterceptor(requestBody: true, requestHeader: true));

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
  //     @GET("dns-query")
  // fun queryDns(
  //         @Header("accept") accept: String = "application/dns-json",
  //         @Query("name") name: String,
  //         @Query("type") type: String = "A",
  //         @Query("do") `do`: Boolean? = null,
  //         @Query("cd") cd: Boolean? = null
  // ): Observable<DnsQueryResponse>
  Future<OnezeroResponse> queryDns(String name) async {
    Response response = await httpClient.get('/dns-query',
        options: Options(
          headers: {'accept': 'application/dns-json', 'Host': '1.0.0.1'},
        ),
        queryParameters: {
          'name': name,
          'type': 'A',
        });

    return onezeroResponseFromJson(response.data);
  }
}
