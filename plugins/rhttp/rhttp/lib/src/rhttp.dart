import 'dart:async';

import 'package:rhttp/src/interceptor/interceptor.dart';
import 'package:rhttp/src/model/cancel_token.dart';
import 'package:rhttp/src/model/request.dart';
import 'package:rhttp/src/model/response.dart';
import 'package:rhttp/src/model/settings.dart';
import 'package:rhttp/src/request.dart';
import 'package:rhttp/src/rust/frb_generated.dart';

class Rhttp {
  const Rhttp._();

  /// Initializes the Rust library.
  static Future<void> init() async {
    await RustLib.init(
      // Reduce the probably of dependency hell.
      // Projects using rhttp may use frb for other purposes as well.
      forceSameCodegenVersion: false,
    );
  }

  /// Makes an HTTP request.
  /// Use [send] if you already have a [BaseHttpRequest] object.
  static Future<HttpResponse> request({
    ClientSettings? settings,
    List<Interceptor>? interceptors,
    required HttpMethod method,
    required String url,
    Map<String, String>? query,
    List<(String, String)>? queryRaw,
    HttpHeaders? headers,
    HttpBody? body,
    required HttpExpectBody expectBody,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) => requestInternalGeneric(
    HttpRequest(
      client: null,
      settings: settings,
      interceptor: parseInterceptorList(interceptors),
      method: method,
      url: url,
      query: query,
      queryRaw: queryRaw,
      headers: headers,
      body: body,
      expectBody: expectBody,
      cancelToken: cancelToken,
      onSendProgress: onSendProgress,
      onReceiveProgress: onReceiveProgress,
    ),
  );

  /// Similar to [request], but uses a [BaseHttpRequest] object
  /// instead of individual parameters.
  static Future<HttpResponse> send(
    BaseHttpRequest request, {
    ClientSettings? settings,
    List<Interceptor>? interceptors,
  }) => requestInternalGeneric(
    HttpRequest.from(
      request: request,
      client: null,
      settings: settings,
      interceptor: parseInterceptorList(interceptors),
    ),
  );

  /// Makes an HTTP request and returns the response as text.
  static Future<HttpTextResponse> requestText({
    ClientSettings? settings,
    List<Interceptor>? interceptors,
    required HttpMethod method,
    required String url,
    Map<String, String>? query,
    List<(String, String)>? queryRaw,
    HttpHeaders? headers,
    HttpBody? body,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    final response = await request(
      settings: settings,
      interceptors: interceptors,
      method: method,
      url: url,
      query: query,
      queryRaw: queryRaw,
      headers: headers,
      body: body,
      expectBody: HttpExpectBody.text,
      cancelToken: cancelToken,
      onSendProgress: onSendProgress,
      onReceiveProgress: onReceiveProgress,
    );
    return response as HttpTextResponse;
  }

  /// Makes an HTTP request and returns the response as bytes.
  static Future<HttpBytesResponse> requestBytes({
    ClientSettings? settings,
    List<Interceptor>? interceptors,
    required HttpMethod method,
    required String url,
    Map<String, String>? query,
    List<(String, String)>? queryRaw,
    HttpHeaders? headers,
    HttpBody? body,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    final response = await request(
      settings: settings,
      interceptors: interceptors,
      method: method,
      url: url,
      query: query,
      queryRaw: queryRaw,
      headers: headers,
      body: body,
      expectBody: HttpExpectBody.bytes,
      cancelToken: cancelToken,
      onSendProgress: onSendProgress,
      onReceiveProgress: onReceiveProgress,
    );
    return response as HttpBytesResponse;
  }

  /// Makes an HTTP request and returns the response as a stream.
  static Future<HttpStreamResponse> requestStream({
    ClientSettings? settings,
    List<Interceptor>? interceptors,
    required HttpMethod method,
    required String url,
    Map<String, String>? query,
    List<(String, String)>? queryRaw,
    HttpHeaders? headers,
    HttpBody? body,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    final response = await request(
      settings: settings,
      interceptors: interceptors,
      method: method,
      url: url,
      query: query,
      queryRaw: queryRaw,
      headers: headers,
      body: body,
      expectBody: HttpExpectBody.stream,
      cancelToken: cancelToken,
      onSendProgress: onSendProgress,
      onReceiveProgress: onReceiveProgress,
    );
    return response as HttpStreamResponse;
  }

  /// Alias for [getText].
  static Future<HttpTextResponse> get(
    String url, {
    ClientSettings? settings,
    List<Interceptor>? interceptors,
    Map<String, String>? query,
    List<(String, String)>? queryRaw,
    HttpHeaders? headers,
    CancelToken? cancelToken,
    ProgressCallback? onReceiveProgress,
  }) => requestText(
    settings: settings,
    interceptors: interceptors,
    method: HttpMethod.get,
    url: url,
    query: query,
    queryRaw: queryRaw,
    headers: headers,
    cancelToken: cancelToken,
    onReceiveProgress: onReceiveProgress,
  );

  /// Makes an HTTP GET request and returns the response as text.
  static Future<HttpTextResponse> getText(
    String url, {
    ClientSettings? settings,
    List<Interceptor>? interceptors,
    Map<String, String>? query,
    List<(String, String)>? queryRaw,
    HttpHeaders? headers,
    CancelToken? cancelToken,
    ProgressCallback? onReceiveProgress,
  }) => requestText(
    settings: settings,
    interceptors: interceptors,
    method: HttpMethod.get,
    url: url,
    query: query,
    queryRaw: queryRaw,
    headers: headers,
    cancelToken: cancelToken,
    onReceiveProgress: onReceiveProgress,
  );

  /// Makes an HTTP GET request and returns the response as bytes.
  static Future<HttpBytesResponse> getBytes(
    String url, {
    ClientSettings? settings,
    List<Interceptor>? interceptors,
    Map<String, String>? query,
    List<(String, String)>? queryRaw,
    HttpHeaders? headers,
    CancelToken? cancelToken,
    ProgressCallback? onReceiveProgress,
  }) => requestBytes(
    settings: settings,
    interceptors: interceptors,
    method: HttpMethod.get,
    url: url,
    query: query,
    queryRaw: queryRaw,
    headers: headers,
    cancelToken: cancelToken,
    onReceiveProgress: onReceiveProgress,
  );

  /// Makes an HTTP GET request and returns the response as a stream.
  static Future<HttpStreamResponse> getStream(
    String url, {
    ClientSettings? settings,
    List<Interceptor>? interceptors,
    Map<String, String>? query,
    List<(String, String)>? queryRaw,
    HttpHeaders? headers,
    CancelToken? cancelToken,
    ProgressCallback? onReceiveProgress,
  }) => requestStream(
    settings: settings,
    interceptors: interceptors,
    method: HttpMethod.get,
    url: url,
    query: query,
    queryRaw: queryRaw,
    headers: headers,
    cancelToken: cancelToken,
    onReceiveProgress: onReceiveProgress,
  );

  /// Makes an HTTP POST request and returns the response as text.
  /// Use [requestBytes], or [requestStream] for other response types.
  static Future<HttpTextResponse> post(
    String url, {
    ClientSettings? settings,
    List<Interceptor>? interceptors,
    Map<String, String>? query,
    List<(String, String)>? queryRaw,
    HttpHeaders? headers,
    HttpBody? body,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) => requestText(
    settings: settings,
    interceptors: interceptors,
    method: HttpMethod.post,
    url: url,
    query: query,
    queryRaw: queryRaw,
    headers: headers,
    body: body,
    cancelToken: cancelToken,
    onSendProgress: onSendProgress,
    onReceiveProgress: onReceiveProgress,
  );

  /// Makes an HTTP PUT request and returns the response as text.
  /// Use [requestBytes], or [requestStream] for other response types.
  static Future<HttpTextResponse> put(
    String url, {
    ClientSettings? settings,
    List<Interceptor>? interceptors,
    Map<String, String>? query,
    List<(String, String)>? queryRaw,
    HttpHeaders? headers,
    HttpBody? body,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) => requestText(
    settings: settings,
    interceptors: interceptors,
    method: HttpMethod.put,
    url: url,
    query: query,
    queryRaw: queryRaw,
    headers: headers,
    body: body,
    cancelToken: cancelToken,
    onSendProgress: onSendProgress,
    onReceiveProgress: onReceiveProgress,
  );

  /// Makes an HTTP DELETE request and returns the response as text.
  /// Use [requestBytes], or [requestStream] for other response types.
  static Future<HttpTextResponse> delete(
    String url, {
    ClientSettings? settings,
    List<Interceptor>? interceptors,
    Map<String, String>? query,
    List<(String, String)>? queryRaw,
    HttpHeaders? headers,
    HttpBody? body,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) => requestText(
    settings: settings,
    interceptors: interceptors,
    method: HttpMethod.delete,
    url: url,
    query: query,
    queryRaw: queryRaw,
    headers: headers,
    body: body,
    cancelToken: cancelToken,
    onSendProgress: onSendProgress,
    onReceiveProgress: onReceiveProgress,
  );

  /// Makes an HTTP HEAD request and returns the response as text.
  /// Use [requestBytes], or [requestStream] for other response types.
  static Future<HttpTextResponse> head(
    String url, {
    ClientSettings? settings,
    List<Interceptor>? interceptors,
    Map<String, String>? query,
    List<(String, String)>? queryRaw,
    HttpHeaders? headers,
    CancelToken? cancelToken,
    ProgressCallback? onReceiveProgress,
  }) => requestText(
    settings: settings,
    interceptors: interceptors,
    method: HttpMethod.head,
    url: url,
    query: query,
    queryRaw: queryRaw,
    headers: headers,
    cancelToken: cancelToken,
    onReceiveProgress: onReceiveProgress,
  );

  /// Makes an HTTP PATCH request and returns the response as text.
  /// Use [requestBytes], or [requestStream] for other response types.
  static Future<HttpTextResponse> patch(
    String url, {
    ClientSettings? settings,
    List<Interceptor>? interceptors,
    Map<String, String>? query,
    List<(String, String)>? queryRaw,
    HttpHeaders? headers,
    HttpBody? body,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) => requestText(
    settings: settings,
    interceptors: interceptors,
    method: HttpMethod.patch,
    url: url,
    query: query,
    queryRaw: queryRaw,
    headers: headers,
    body: body,
    cancelToken: cancelToken,
    onSendProgress: onSendProgress,
    onReceiveProgress: onReceiveProgress,
  );

  /// Makes an HTTP OPTIONS request and returns the response as text.
  /// Use [requestBytes], or [requestStream] for other response types.
  static Future<HttpTextResponse> options(
    String url, {
    ClientSettings? settings,
    List<Interceptor>? interceptors,
    Map<String, String>? query,
    List<(String, String)>? queryRaw,
    HttpHeaders? headers,
    HttpBody? body,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) => requestText(
    settings: settings,
    interceptors: interceptors,
    method: HttpMethod.options,
    url: url,
    query: query,
    queryRaw: queryRaw,
    headers: headers,
    body: body,
    cancelToken: cancelToken,
    onSendProgress: onSendProgress,
    onReceiveProgress: onReceiveProgress,
  );

  /// Makes an HTTP TRACE request and returns the response as text.
  /// Use [requestBytes], or [requestStream] for other response types.
  static Future<HttpTextResponse> trace(
    String url, {
    ClientSettings? settings,
    List<Interceptor>? interceptors,
    Map<String, String>? query,
    List<(String, String)>? queryRaw,
    HttpHeaders? headers,
    HttpBody? body,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) => requestText(
    settings: settings,
    interceptors: interceptors,
    method: HttpMethod.trace,
    url: url,
    query: query,
    queryRaw: queryRaw,
    headers: headers,
    body: body,
    cancelToken: cancelToken,
    onSendProgress: onSendProgress,
    onReceiveProgress: onReceiveProgress,
  );
}
