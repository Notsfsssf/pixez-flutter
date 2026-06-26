import 'dart:async';

import 'package:meta/meta.dart';
import 'package:rhttp/src/interceptor/interceptor.dart';
import 'package:rhttp/src/model/cancel_token.dart';
import 'package:rhttp/src/model/request.dart';
import 'package:rhttp/src/model/response.dart';
import 'package:rhttp/src/model/settings.dart';
import 'package:rhttp/src/request.dart';
import 'package:rhttp/src/rust/api/client.dart' as rust_client;
import 'package:rhttp/src/rust/api/http.dart' as rust;

/// An HTTP client that is used to make requests.
/// Creating this is an expensive operation, so it is recommended to reuse it.
/// Internally, it holds a connection pool and other resources on the Rust side.
class RhttpClient {
  /// Settings for the client.
  final ClientSettings settings;

  /// One or more interceptors that are used to modify requests and responses.
  final Interceptor? interceptor;

  /// Internal reference to the Rust client.
  @internal
  final rust_client.RequestClient ref;

  const RhttpClient._({
    required this.settings,
    required this.interceptor,
    required this.ref,
  });

  /// Creates a new HTTP client asynchronously.
  /// Use this method if your app is already running to avoid blocking the UI.
  static Future<RhttpClient> create({
    ClientSettings? settings,
    List<Interceptor>? interceptors,
  }) async {
    settings ??= const ClientSettings();
    final ref = await rust.registerClient(settings: settings.toRustType());
    return RhttpClient._(
      settings: settings,
      interceptor: parseInterceptorList(interceptors),
      ref: ref,
    );
  }

  /// Creates a new HTTP client synchronously.
  /// Use this method if your app is starting up to simplify the code
  /// that might arise by using async/await.
  ///
  /// Note:
  /// This method crashes when configured to use HTTP/3.
  /// See: https://codeberg.org/Tienisto/rhttp/issues/10
  factory RhttpClient.createSync({
    ClientSettings? settings,
    List<Interceptor>? interceptors,
  }) {
    settings ??= const ClientSettings();
    final ref = rust.registerClientSync(settings: settings.toRustType());
    return RhttpClient._(
      settings: settings,
      interceptor: parseInterceptorList(interceptors),
      ref: ref,
    );
  }

  /// Disposes the client.
  /// This frees the resources associated with the client.
  /// After calling this method, the client should not be used anymore.
  ///
  /// Note:
  /// This might improve performance but it is not necessary because the client
  /// is automatically disposed when the Dart object is garbage collected.
  void dispose({bool cancelRunningRequests = false}) async {
    if (ref.isDisposed) {
      return;
    }

    if (cancelRunningRequests) {
      await rust.cancelRunningRequests(client: ref);
    }
    ref.dispose();
  }

  /// Makes an HTTP request.
  /// Use [send] if you already have a [BaseHttpRequest] object.
  Future<HttpResponse> request({
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
      client: this,
      settings: settings,
      interceptor: interceptor,
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
  Future<HttpResponse> send(BaseHttpRequest request) => requestInternalGeneric(
    HttpRequest.from(
      request: request,
      client: this,
      settings: settings,
      interceptor: interceptor,
    ),
  );

  /// Makes an HTTP request and returns the response as text.
  Future<HttpTextResponse> requestText({
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
  Future<HttpBytesResponse> requestBytes({
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
  Future<HttpStreamResponse> requestStream({
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
  Future<HttpTextResponse> get(
    String url, {
    Map<String, String>? query,
    List<(String, String)>? queryRaw,
    HttpHeaders? headers,
    CancelToken? cancelToken,
    ProgressCallback? onReceiveProgress,
  }) => requestText(
    method: HttpMethod.get,
    url: url,
    query: query,
    queryRaw: queryRaw,
    headers: headers,
    cancelToken: cancelToken,
    onReceiveProgress: onReceiveProgress,
  );

  /// Makes an HTTP GET request and returns the response as text.
  Future<HttpTextResponse> getText(
    String url, {
    Map<String, String>? query,
    List<(String, String)>? queryRaw,
    HttpHeaders? headers,
    CancelToken? cancelToken,
    ProgressCallback? onReceiveProgress,
  }) => requestText(
    method: HttpMethod.get,
    url: url,
    query: query,
    queryRaw: queryRaw,
    headers: headers,
    cancelToken: cancelToken,
    onReceiveProgress: onReceiveProgress,
  );

  /// Makes an HTTP GET request and returns the response as bytes.
  Future<HttpBytesResponse> getBytes(
    String url, {
    Map<String, String>? query,
    List<(String, String)>? queryRaw,
    HttpHeaders? headers,
    CancelToken? cancelToken,
    ProgressCallback? onReceiveProgress,
  }) => requestBytes(
    method: HttpMethod.get,
    url: url,
    query: query,
    queryRaw: queryRaw,
    headers: headers,
    cancelToken: cancelToken,
    onReceiveProgress: onReceiveProgress,
  );

  /// Makes an HTTP GET request and returns the response as a stream.
  Future<HttpStreamResponse> getStream(
    String url, {
    Map<String, String>? query,
    List<(String, String)>? queryRaw,
    HttpHeaders? headers,
    CancelToken? cancelToken,
    ProgressCallback? onReceiveProgress,
  }) => requestStream(
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
  Future<HttpTextResponse> post(
    String url, {
    Map<String, String>? query,
    List<(String, String)>? queryRaw,
    HttpHeaders? headers,
    HttpBody? body,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) => requestText(
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
  Future<HttpTextResponse> put(
    String url, {
    Map<String, String>? query,
    List<(String, String)>? queryRaw,
    HttpHeaders? headers,
    HttpBody? body,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) => requestText(
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
  Future<HttpTextResponse> delete(
    String url, {
    Map<String, String>? query,
    List<(String, String)>? queryRaw,
    HttpHeaders? headers,
    HttpBody? body,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) => requestText(
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
  Future<HttpTextResponse> head(
    String url, {
    Map<String, String>? query,
    List<(String, String)>? queryRaw,
    HttpHeaders? headers,
    CancelToken? cancelToken,
    ProgressCallback? onReceiveProgress,
  }) => requestText(
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
  Future<HttpTextResponse> patch(
    String url, {
    Map<String, String>? query,
    List<(String, String)>? queryRaw,
    HttpHeaders? headers,
    HttpBody? body,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) => requestText(
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
  Future<HttpTextResponse> options(
    String url, {
    Map<String, String>? query,
    List<(String, String)>? queryRaw,
    HttpHeaders? headers,
    HttpBody? body,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) => requestText(
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
  Future<HttpTextResponse> trace(
    String url, {
    Map<String, String>? query,
    List<(String, String)>? queryRaw,
    HttpHeaders? headers,
    HttpBody? body,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) => requestText(
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
