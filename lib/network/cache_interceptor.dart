import 'dart:async';

import 'package:dio/dio.dart';

class CacheInterceptor extends Interceptor {
  CacheInterceptor();

  var _cache = Map<Uri, Response>();

  @override
  Future onRequest(RequestOptions options) async {
    Response response = _cache[options.uri];
    if (options.extra["refresh"] == true) {
      return options;
    } else if (response != null) {
      print("cache hit: ${options.uri} \n");
      return response;
    }
  }

  // @override
  // Future onResponse(Response response) async {
  //   _cache[response.request.uri] = response;
  // }

  @override
  Future onError(DioError e) async {
    print('onError: $e');
  }
}
