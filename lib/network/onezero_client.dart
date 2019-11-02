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

import 'dart:io';

import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:pixez/models/onezero_response.dart';

class OnezeroClient {
  late Dio httpClient;
  static const String URL_DNS_RESOLVER = "https://doh.dns.sb";

  OnezeroClient() {
    this.httpClient = Dio(BaseOptions(
        baseUrl: URL_DNS_RESOLVER, connectTimeout: Duration(seconds: 10)));
      httpClient.httpClientAdapter = IOHttpClientAdapter(createHttpClient: () {
        HttpClient httpClient = HttpClient();
        httpClient.badCertificateCallback = (X509Certificate cert, String host, int port) => true;
        return httpClient;
      });
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
          headers: {
            'accept': 'application/dns-json',
          },
        ),
        queryParameters: {
          'name': name,
          'type': 'A',
        });
    var responseFromJson = OnezeroResponse.fromJson(response.data);
    // for (var value in responseFromJson.answer) {
    //   if(value.name == "app-api.pixiv.net"){
    //     value.data=""
    //   }
    // }
    return responseFromJson;
  }
}
