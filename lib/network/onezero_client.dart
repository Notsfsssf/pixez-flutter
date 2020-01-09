import 'package:dio/dio.dart';
import 'package:pixez/models/onezero_response.dart';

class OnezeroClient {
  Dio httpClient;
  static const String URL_DNS_RESOLVER = "https://1.0.0.1/";
  OnezeroClient() {
    this.httpClient = Dio(BaseOptions(baseUrl: URL_DNS_RESOLVER));
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
    Response response = await httpClient.get('',
        options: Options(
          headers: {'accept': 'application/dns-json'},
        ),
        queryParameters: {'name': name, 'type': 'A'});
    return OnezeroResponse.fromJson(response.data);
  }
}
