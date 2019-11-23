import 'package:dio/dio.dart';
import 'package:pixez/models/account.dart';
import 'package:pixez/network/oauth_client.dart';

class RefreshTokenInterceptor extends Interceptor {
  @override
  onError(DioError err) async {
    if (err.response != null && err.response.statusCode == 400) {
      final client = OAuthClient();
      final dio = client.httpClient;
      dio.lock();
      AccountProvider accountProvider = new AccountProvider();
      await accountProvider.open();
      final allAccount = await accountProvider.getAllAccount();
      AccountPersist accountPersist = allAccount[0];

      final response = await client.postRefreshAuthToken(
          refreshToken: accountPersist.refreshToken,
          deviceToken: accountPersist.deviceToken);
      AccountResponse accountResponse = response.data;

      var request = err.response.request; //千万不要调用 err.request
      request.headers[OAuthClient.AUTHORIZATION] =
          "Bearer " + accountResponse.accessToken;
      try {
        var response = await dio.request(
          request.path,
          data: request.data,
          queryParameters: request.queryParameters,
          cancelToken: request.cancelToken,
          options: request,
        );
        dio.unlock();
        return response;
      } on DioError catch (e) {
        dio.unlock();
        return e;
      }
    }

    super.onError(err);
  }
}

class ApiClient {
  Dio httpClient;

  ApiClient() {
    this.httpClient = Dio()
      ..options.baseUrl = "https://app-api.pixiv.net"
      ..interceptors.add(LogInterceptor(responseBody: true, requestBody: true))
      ..interceptors.add(RefreshTokenInterceptor())
      ..interceptors
          .add(InterceptorsWrapper(onRequest: (Options options) async {
        AccountProvider accountProvider = new AccountProvider();
        await accountProvider.open();
        final allAccount = await accountProvider.getAllAccount();
        AccountPersist accountPersist = allAccount[0];
        options.headers[OAuthClient.AUTHORIZATION] = "Bearer " + accountPersist.accessToken;
        return options; //continue
      }));

  }
  Future<Response> getRecommend() async {
    return httpClient.get(
        "/v1/illust/recommended?filter=for_ios&include_ranking_label=true");
  }
  //getLikeIllust(@Header("Authorization") String paramString1, @Query("user_id") long paramLong, @Query("restrict") String paramString2, @Query("tag") String paramString3);
 Future<Response> getLikeIllust() async {
    return httpClient.get(
        "/v1/user/bookmarks/illust");
  }
  //postUnlikeIllust(@Header("Authorization") String paramString, @Field("illust_id") long paramLong);
Future<Response> postUnlikeIllust() async {
    return httpClient.get(
        "/v1/illust/bookmark/delete");
  }
 Future<Response> getIllustRanking({mode: String, data: String}) async {
    return httpClient.get("/v1/illust/ranking?filter=for_ios",
        queryParameters: data != null
            ? {
          "mode": mode,
          'date': data,
        }
            : {
          "mode": mode,
        });
  }
}
