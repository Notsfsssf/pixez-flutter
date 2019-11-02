import 'dart:async';
import 'dart:io';

import 'package:meta/meta.dart';
import 'package:rhttp/rhttp.dart' as rhttp;
import 'package:rhttp/src/model/response.dart';

@internal
class RhttpIoResponse with Stream<List<int>> implements HttpClientResponse {
  final HttpStreamResponse _response;
  final HttpHeaders _headers;
  RhttpIoResponse(this._response, this._headers);

  @override
  int get statusCode => _response.statusCode;

  @override
  int get contentLength =>
      int.tryParse(_response.headerMap['content-length'] ?? '-1') ?? -1;

  @override
  HttpHeaders get headers => _headers;

  @override
  X509Certificate? get certificate => throw UnimplementedError();

  @override
  HttpClientResponseCompressionState get compressionState =>
      throw UnimplementedError();

  @override
  HttpConnectionInfo? get connectionInfo => throw UnimplementedError();

  @override
  List<Cookie> get cookies => throw UnimplementedError();

  @override
  Future<Socket> detachSocket() => throw UnimplementedError();

  @override
  bool get isRedirect {
    if (_response.request.method == rhttp.HttpMethod.get ||
        _response.request.method == rhttp.HttpMethod.head) {
      return statusCode == HttpStatus.movedPermanently ||
          statusCode == HttpStatus.permanentRedirect ||
          statusCode == HttpStatus.found ||
          statusCode == HttpStatus.seeOther ||
          statusCode == HttpStatus.temporaryRedirect;
    } else if (_response.request.method == rhttp.HttpMethod.post) {
      return statusCode == HttpStatus.seeOther;
    }
    return false;
  }

  @override
  StreamSubscription<List<int>> listen(
    void Function(List<int> event)? onData, {
    Function? onError,
    void Function()? onDone,
    bool? cancelOnError,
  }) {
    return _response.body.listen(
      onData,
      onError: onError,
      onDone: onDone,
      cancelOnError: cancelOnError,
    );
  }

  @override
  bool get persistentConnection => throw UnimplementedError();

  @override
  String get reasonPhrase => "";

  @override
  Future<HttpClientResponse> redirect([
    String? method,
    Uri? url,
    bool? followLoops,
  ]) {
    throw UnimplementedError();
  }

  @override
  List<RedirectInfo> get redirects => []; // leaving this empty since we cant extract the redirect from rust side
}
