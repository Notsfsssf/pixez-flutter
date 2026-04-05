import 'package:meta/meta.dart';
import 'package:rhttp/src/interceptor/interceptor.dart';
import 'package:rhttp/src/model/exception.dart';
import 'package:rhttp/src/model/request.dart';
import 'package:rhttp/src/model/response.dart';

typedef RetryCondition = bool Function(HttpResponse?, RhttpException?);
typedef RetryDelay = Duration Function(int);
typedef BeforeRetry =
    Future<HttpRequest?> Function(
      int attempt,
      HttpRequest request,
      HttpResponse? response,
      RhttpException? exception,
    );

/// An interceptor that retries requests if they fail.
///
/// If a [CancelToken] is provided in the original request,
/// the subsequent requests triggered by this interceptor
/// will be cancelled as well via internal delegation.
class RetryInterceptor extends Interceptor {
  static const key = 'rhttp_retry';

  final int maxRetries;
  final RetryCondition shouldRetryFunc;
  final RetryDelay delayFunc;
  final BeforeRetry? beforeRetryFunc;

  RetryInterceptor({
    this.maxRetries = 1,
    RetryCondition? shouldRetry,
    RetryDelay? delay,
    BeforeRetry? beforeRetry,
  }) : shouldRetryFunc = shouldRetry ?? _defaultRetryCondition,
       delayFunc = delay ?? _defaultDelay,
       beforeRetryFunc = beforeRetry;

  @override
  @nonVirtual
  Future<InterceptorResult<HttpRequest>> beforeRequest(HttpRequest request) {
    return super.beforeRequest(request);
  }

  @override
  @nonVirtual
  Future<InterceptorResult<HttpResponse>> afterResponse(
    HttpResponse response,
  ) async {
    final isRetry = response.request.additionalData[key] ?? false;
    if (isRetry) {
      // Don't start a retry loop if we're already retrying.
      return Interceptor.next();
    }

    if (!shouldRetry(response, null)) {
      return Interceptor.next();
    }

    return _retry(response, null);
  }

  @override
  @nonVirtual
  Future<InterceptorResult<RhttpException>> onError(
    RhttpException exception,
  ) async {
    final isRetry = exception.request.additionalData[key] ?? false;
    if (isRetry) {
      // Don't start a retry loop if we're already retrying.
      return Interceptor.next();
    }

    if (!shouldRetry(null, exception)) {
      return Interceptor.next();
    }

    return await _retry(null, exception);
  }

  /// Whether to retry the request.
  /// Override this method to customize the retry logic.
  bool shouldRetry(HttpResponse? response, RhttpException? exception) {
    return shouldRetryFunc(response, exception);
  }

  /// The delay between retries (including the delay before the initial retry).
  /// Override this method to customize the delay.
  Duration getDelay(int attempt) {
    return delayFunc(attempt);
  }

  /// Called before each retry.
  /// May return a new request to be used for the current retry and
  /// all subsequent retries.
  Future<HttpRequest?> beforeRetry(
    int attempt,
    HttpRequest request,
    HttpResponse? response,
    RhttpException? exception,
  ) async {
    if (beforeRetryFunc != null) {
      return await beforeRetryFunc!.call(attempt, request, response, exception);
    }
    return null;
  }

  /// The actual retry process.
  Future<InterceptorResult<T>> _retry<T>(
    HttpResponse? response,
    RhttpException? exception,
  ) async {
    assert(response != null || exception != null);
    HttpRequest request = response?.request ?? exception!.request;
    final originalCancelToken = request.cancelToken;

    for (var i = 0; i < maxRetries; i++) {
      final delay = getDelay(i);
      if (delay != Duration.zero) {
        await Future.delayed(delay);
      }

      final beforeRetryResult = await beforeRetry(
        i,
        request,
        response,
        exception,
      );

      request = (beforeRetryResult ?? request).copyWith(
        cancelToken: originalCancelToken,
      );
      request.additionalData[key] = true;

      try {
        response = null;
        exception = null;
        response = await request.send();
      } on RhttpException catch (e) {
        if (e is RhttpCancelException) {
          rethrow;
        }
        exception = e;
      }

      if (!shouldRetry(response, exception)) {
        if (response != null) {
          return Interceptor.resolve(response);
        } else {
          return Interceptor.next();
        }
      }
    }

    return Interceptor.next();
  }
}

final RetryCondition _defaultRetryCondition = ((response, exception) {
  if (response != null) {
    return response.statusCode >= 500;
  }

  return exception != null;
});

final RetryDelay _defaultDelay = ((attempt) => Duration.zero);
