import 'dart:async';
import 'dart:io';

import 'package:rhttp/src/client/io/io_request.dart';
import 'package:rhttp/src/client/rhttp_client.dart';
import 'package:rhttp/src/interceptor/interceptor.dart';
import 'package:rhttp/src/model/settings.dart';

/// An HTTP client that is compatible with dart:io package.
/// This minimizes the changes needed to switch from dart:io to `rhttp`
/// and also avoids vendor lock-in.
class IoCompatibleClient implements HttpClient {
  /// The actual client that is used to make requests.
  final RhttpClient client;

  IoCompatibleClient._(this.client);

  /// Creates a new HTTP client asynchronously.
  /// Use this method if your app is already running to avoid blocking the UI.
  static Future<IoCompatibleClient> create({
    ClientSettings? settings,
    List<Interceptor>? interceptors,
  }) async {
    final rhttpClient = await RhttpClient.create(
      settings: (settings ?? const ClientSettings()),
      interceptors: interceptors,
    );
    return IoCompatibleClient._(rhttpClient);
  }

  /// Creates a new HTTP client synchronously.
  /// Use this method if your app is starting up to simplify the code
  /// that might arise by using async/await.
  ///
  /// Note:
  /// This method crashes when configured to use HTTP/3.
  /// See: https://codeberg.org/Tienisto/rhttp/issues/10
  factory IoCompatibleClient.createSync({
    ClientSettings? settings,
    List<Interceptor>? interceptors,
  }) {
    final rhttpClient = RhttpClient.createSync(
      settings: (settings ?? const ClientSettings()),
      interceptors: interceptors,
    );
    return IoCompatibleClient._(rhttpClient);
  }

  /// Creates a new request.
  ///
  /// Note:
  /// The request is not sent
  /// until you add a body or call [HttpClientRequest.close].
  Future<RhttpIoRequest> _createRequest(String method, Uri url) async {
    return RhttpIoRequest(client, method, url);
  }

  @override
  Future<HttpClientRequest> get(String host, int port, String path) =>
      open('GET', host, port, path);

  @override
  Future<HttpClientRequest> getUrl(Uri url) => openUrl('GET', url);

  @override
  Future<HttpClientRequest> post(String host, int port, String path) =>
      open('POST', host, port, path);

  @override
  Future<HttpClientRequest> postUrl(Uri url) => openUrl('POST', url);

  @override
  Future<HttpClientRequest> put(String host, int port, String path) =>
      open('PUT', host, port, path);

  @override
  Future<HttpClientRequest> putUrl(Uri url) => openUrl('PUT', url);

  @override
  Future<HttpClientRequest> delete(String host, int port, String path) =>
      open('DELETE', host, port, path);

  @override
  Future<HttpClientRequest> deleteUrl(Uri url) => openUrl('DELETE', url);

  @override
  Future<HttpClientRequest> head(String host, int port, String path) =>
      open('HEAD', host, port, path);

  @override
  Future<HttpClientRequest> headUrl(Uri url) => openUrl('HEAD', url);

  @override
  Future<HttpClientRequest> patch(String host, int port, String path) =>
      open('PATCH', host, port, path);

  @override
  Future<HttpClientRequest> patchUrl(Uri url) => openUrl('PATCH', url);

  @override
  Future<HttpClientRequest> open(
    String method,
    String host,
    int port,
    String path,
  ) => openUrl(method, Uri.parse('http://$host:$port$path'));

  @override
  Future<HttpClientRequest> openUrl(String method, Uri url) =>
      _createRequest(method, url);

  @override
  bool autoUncompress = true;

  @override
  Duration? connectionTimeout;

  @override
  Duration get idleTimeout =>
      client.settings.timeoutSettings?.keepAliveTimeout ?? Duration.zero;

  @override
  set idleTimeout(Duration d) {
    // noop
  }

  @override
  int? maxConnectionsPerHost;

  @override
  String? userAgent;

  @override
  void addCredentials(
    Uri url,
    String realm,
    HttpClientCredentials credentials,
  ) => throw UnimplementedError("addCredentials is not supported");

  @override
  void addProxyCredentials(
    String host,
    int port,
    String realm,
    HttpClientCredentials credentials,
  ) => throw UnimplementedError("addProxyCredentials is not supported");

  @override
  set authenticate(
    Future<bool> Function(Uri url, String scheme, String? realm)? f,
  ) => throw UnimplementedError("authenticate is not supported");

  @override
  set authenticateProxy(
    Future<bool> Function(String host, int port, String scheme, String? realm)?
    f,
  ) => throw UnimplementedError("authenticateProxy is not supported");

  @override
  set badCertificateCallback(
    bool Function(X509Certificate cert, String host, int port)? callback,
  ) => UnimplementedError("badCertificateCallback is not supported");

  @override
  void close({bool force = false}) {
    client.dispose(cancelRunningRequests: force);
  }

  @override
  set connectionFactory(
    Future<ConnectionTask<Socket>> Function(
      Uri url,
      String? proxyHost,
      int? proxyPort,
    )?
    f,
  ) {
    UnimplementedError("connectionFactory is not supported");
  }

  @override
  set findProxy(String Function(Uri url)? f) =>
      UnimplementedError("findProxy is not supported");

  @override
  set keyLog(Function(String line)? callback) =>
      throw UnimplementedError("keyLog is not supported");
}
