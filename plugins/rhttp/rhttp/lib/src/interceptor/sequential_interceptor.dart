import 'package:rhttp/src/interceptor/interceptor.dart';
import 'package:rhttp/src/model/exception.dart';
import 'package:rhttp/src/model/request.dart';
import 'package:rhttp/src/model/response.dart';

/// An interceptor that queues other interceptors sequentially.
class SequentialInterceptor extends Interceptor {
  final List<Interceptor> interceptors;

  SequentialInterceptor({
    required this.interceptors,
  });

  @override
  Future<InterceptorResult<HttpRequest>> beforeRequest(
    HttpRequest request,
  ) async {
    HttpRequest tempRequest = request;
    for (final interceptor in interceptors) {
      final result = await interceptor.beforeRequest(tempRequest);
      switch (result) {
        case InterceptorNextResult<HttpRequest>():
          tempRequest = result.value ?? tempRequest;
        case InterceptorStopResult<HttpRequest>():
          return Interceptor.stop(result.value ?? tempRequest);
        case InterceptorResolveResult<HttpRequest>():
          return result;
      }
    }
    return Interceptor.next(tempRequest);
  }

  @override
  Future<InterceptorResult<HttpResponse>> afterResponse(
    HttpResponse response,
  ) async {
    HttpResponse tempResponse = response;
    for (final interceptor in interceptors) {
      final result = await interceptor.afterResponse(tempResponse);
      switch (result) {
        case InterceptorNextResult<HttpResponse>():
          tempResponse = result.value ?? tempResponse;
        case InterceptorStopResult<HttpResponse>():
          return Interceptor.stop(result.value ?? tempResponse);
        case InterceptorResolveResult<HttpResponse>():
          return result;
      }
    }
    return Interceptor.next(tempResponse);
  }

  @override
  Future<InterceptorResult<RhttpException>> onError(
    RhttpException exception,
  ) async {
    RhttpException tempException = exception;
    for (final interceptor in interceptors) {
      final result = await interceptor.onError(tempException);
      switch (result) {
        case InterceptorNextResult<RhttpException>():
          tempException = result.value ?? tempException;
        case InterceptorStopResult<RhttpException>():
          return Interceptor.stop(result.value ?? tempException);
        case InterceptorResolveResult<RhttpException>():
          return result;
      }
    }
    return Interceptor.next(tempException);
  }
}
