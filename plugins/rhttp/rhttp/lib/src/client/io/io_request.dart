import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:meta/meta.dart';
import 'package:rhttp/src/client/io/io_headers.dart';
import 'package:rhttp/src/client/io/io_response.dart';
import 'package:rhttp/src/client/rhttp_client.dart';
import 'package:rhttp/src/model/cancel_token.dart';
import 'package:rhttp/src/model/request.dart';
import 'package:rhttp/src/model/response.dart';

@internal
class RhttpIoRequest implements HttpClientRequest {
  final RhttpClient client;

  @override
  final String method;

  @override
  final Uri uri;

  @override
  final RhttpIoHeaders headers = RhttpIoHeaders();

  final _controller = StreamController<List<int>>();
  final _responseCompleter = Completer<HttpStreamResponse>();
  final _cancelToken = CancelToken();

  RhttpIoRequest(
    this.client,
    this.method,
    this.uri,
  );

  bool started = false;

  void startRequest() async {
    if (started) {
      return;
    }

    started = true;

    final response = client.requestStream(
      method: HttpMethod(method.toUpperCase()),
      url: '${uri.scheme}://${uri.host}:${uri.port}${uri.path}',
      headers: HttpHeaders.list([
        for (final entry in headers.headers.entries)
          for (final value in entry.value) (entry.key, value),
        if (contentLength != -1) ('content-length', contentLength.toString()),
      ]),
      query: uri.queryParameters,
      body: HttpBody.stream(_controller.stream),
      cancelToken: _cancelToken,
    );

    response
        .then((value) async {
          _controller.close();
          _responseCompleter.complete(value);
        })
        .catchError((error, stackTrace) {
          _controller.close();
          _responseCompleter.completeError(error, stackTrace);
        });
  }

  @override
  bool bufferOutput = true;

  @override
  int contentLength = -1;

  @override
  late Encoding encoding;

  @override
  bool followRedirects = true;

  @override
  int maxRedirects = 10;

  @override
  bool persistentConnection = true;

  @override
  void abort([Object? exception, StackTrace? stackTrace]) {
    _cancelToken.cancel();
  }

  @override
  void add(List<int> data) {
    _controller.add(data);
    startRequest();
  }

  @override
  void addError(Object error, [StackTrace? stackTrace]) {
    if (stackTrace != null) {
      Error.throwWithStackTrace(error, stackTrace);
    } else {
      throw error;
    }
  }

  @override
  Future addStream(Stream<List<int>> stream) {
    final future = _controller.addStream(stream);
    startRequest();
    return future;
  }

  @override
  void write(Object? object) {
    _controller.add(utf8.encode(object.toString()));
    startRequest();
  }

  @override
  void writeAll(Iterable objects, [String separator = ""]) {
    _controller.add(utf8.encode(objects.join(separator)));
    startRequest();
  }

  @override
  void writeCharCode(int charCode) {
    _controller.add([charCode]);
    startRequest();
  }

  @override
  void writeln([Object? object = ""]) {
    _controller.add(utf8.encode('$object\n'));
    startRequest();
  }

  @override
  Future<HttpClientResponse> close() async {
    startRequest();
    final response = await _responseCompleter.future;
    return RhttpIoResponse(response, headers);
  }

  @override
  HttpConnectionInfo? get connectionInfo => throw UnimplementedError();

  @override
  List<Cookie> get cookies => throw UnimplementedError();

  @override
  Future<HttpClientResponse> get done => throw UnimplementedError();

  @override
  Future flush() => _controller.done;
}
