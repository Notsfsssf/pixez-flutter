import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_rust_bridge/flutter_rust_bridge.dart';
import 'package:rhttp/src/dev_tools.dart';
import 'package:rhttp/src/interceptor/interceptor.dart';
import 'package:rhttp/src/model/exception.dart';
import 'package:rhttp/src/model/header.dart';
import 'package:rhttp/src/model/request.dart';
import 'package:rhttp/src/model/response.dart';
import 'package:rhttp/src/model/settings.dart';
import 'package:rhttp/src/rust/api/error.dart' as rust_error;
import 'package:rhttp/src/rust/api/http.dart' as rust;
import 'package:rhttp/src/rust/api/stream.dart' as rust_stream;
import 'package:rhttp/src/rust/lib.dart' as rust_lib;
import 'package:rhttp/src/util/byte_stream_converter.dart';
import 'package:rhttp/src/util/byte_stream_subscription.dart';
import 'package:rhttp/src/util/collection.dart';
import 'package:rhttp/src/util/progress_notifier.dart';
import 'package:rhttp/src/util/stream_listener.dart';
import 'package:rhttp/src/util/strings.dart';

/// Non-Generated helper function that is used by
/// the client and also by the static class.
@internal
Future<HttpResponse> requestInternalGeneric(HttpRequest request) async {
  if (request.client?.ref.isDisposed ?? false) {
    throw RhttpClientDisposedException(request);
  }

  final interceptors = request.interceptor;

  if (interceptors != null) {
    try {
      final result = await interceptors.beforeRequest(request);
      switch (result) {
        case InterceptorNextResult<HttpRequest>() ||
            InterceptorStopResult<HttpRequest>():
          request = result.value ?? request;
        case InterceptorResolveResult<HttpRequest>():
          return result.response;
      }
    } on RhttpException {
      rethrow;
    } catch (e, st) {
      Error.throwWithStackTrace(RhttpInterceptorException(request, e), st);
    }
  }

  final ProgressNotifier? sendNotifier;
  if (request.onSendProgress != null) {
    switch (request.body) {
      case HttpBodyBytesStream():
        sendNotifier = ProgressNotifier(request.onSendProgress!);
        break;
      case HttpBodyBytes body:
        // transform to Stream
        request = request.copyWith(
          body: HttpBody.stream(
            body.bytes.toStream(chunkSize: 1024),
            length: body.bytes.length,
          ),
        );
        sendNotifier = ProgressNotifier(request.onSendProgress!);
        break;
      default:
        sendNotifier = null;
        if (kDebugMode) {
          print(
            'Progress callback is not supported for ${request.body.runtimeType}',
          );
        }
    }
  } else {
    sendNotifier = null;
  }

  HttpHeaders? headers = request.headers;
  headers = _digestHeaders(headers: headers, body: request.body);

  // Convert the Dart stream to a Dart2Rust stream
  final requestBodyStream = switch (request.body) {
    HttpBodyBytesStream body => await _createDart2RustStream(
      body: body,
      headers: headers,
      sendNotifier: sendNotifier,
    ),
    _ => null,
  };

  final ProgressNotifier? receiveNotifier;
  final bool convertBackToBytes;
  if (request.onReceiveProgress != null) {
    switch (request.expectBody) {
      case HttpExpectBody.stream:
        receiveNotifier = ProgressNotifier(request.onReceiveProgress!);
        convertBackToBytes = false;
        break;
      case HttpExpectBody.bytes:
        request = request.copyWith(expectBody: HttpExpectBody.stream);
        receiveNotifier = ProgressNotifier(request.onReceiveProgress!);
        convertBackToBytes = true;
        break;
      default:
        receiveNotifier = null;
        convertBackToBytes = false;
        if (kDebugMode) {
          print('Progress callback is not supported for ${request.expectBody}');
        }
    }
  } else {
    receiveNotifier = null;
    convertBackToBytes = false;
  }

  bool exceptionByInterceptor = false;
  final url = switch (request.settings?.baseUrl) {
    String baseUrl => baseUrl + request.url,
    null => request.url,
  };

  final profile = createDevToolsProfile(
    request: request,
    url: url,
    headers: headers,
  );

  try {
    if (request.expectBody == HttpExpectBody.stream) {
      final cancelRefCompleter = Completer<rust_lib.CancellationToken>();
      final responseCompleter = Completer<rust.HttpResponse>();
      Stream<Uint8List> stream = rust.makeHttpRequestReceiveStream(
        client: request.client?.ref,
        settings: request.settings?.toRustType(),
        method: request.method._toRustType(),
        url: url,
        query:
            request.queryRaw ??
            request.query?.entries.map((e) => (e.key, e.value)).toList(),
        headers: headers?._toRustType(),
        body: request.body?._toRustType(),
        bodyStream: requestBodyStream,
        onResponse: (r) {
          if (!responseCompleter.isCompleted) {
            responseCompleter.complete(r);
          }
        },
        onError: (e) {
          if (!responseCompleter.isCompleted) {
            responseCompleter.completeError(e);
          }
        },
        onCancelToken: (cancelRef) => cancelRefCompleter.complete(cancelRef),
        cancelable: request.cancelToken != null,
      );

      final cancelToken = request.cancelToken;
      if (cancelToken != null) {
        final cancelRef = await cancelRefCompleter.future;
        cancelToken.addRef(cancelRef);
      }

      final rustResponse = await responseCompleter.future;
      final profileByteStream = profile == null || convertBackToBytes
          ? null
          : ByteStreamSubscription();

      if (receiveNotifier != null) {
        final contentLengthStr =
            rustResponse.headers
                .firstWhereOrNull((e) => e.$1.toLowerCase() == 'content-length')
                ?.$2 ??
            '-1';
        final contentLength = int.tryParse(contentLengthStr) ?? -1;

        // Somehow, a temporary variable is needed to avoid null check inside the closure
        final receiveNotifierNotNull = receiveNotifier;

        stream = stream.transform(
          _createStreamTransformer(
            request: request,
            onData: (chunk) {
              receiveNotifierNotNull.notify(chunk.length, contentLength);
              profileByteStream?.addBytes(chunk);
            },
            onDone: () {
              if (contentLength != -1) {
                receiveNotifierNotNull.notifyDone(contentLength);
              }
              profileByteStream?.close();
            },
          ),
        );
      } else {
        stream = stream.transform(
          _createStreamTransformer(
            request: request,
            onData: profileByteStream == null
                ? null
                : (chunk) => profileByteStream.addBytes(chunk),
            onDone: profileByteStream?.close,
          ),
        );
      }

      HttpResponse response = parseHttpResponse(
        request,
        rustResponse,
        bodyStream: stream,
      );

      if (convertBackToBytes) {
        response = HttpBytesResponse(
          remoteIp: response.remoteIp,
          request: request,
          version: response.version,
          statusCode: response.statusCode,
          headers: response.headers,
          body: await stream.toUint8List(),
        );

        profile?.trackResponse(response);
      } else if (profile != null && profileByteStream != null) {
        // Notify DevTools as soon as the complete body is received.
        // Using then() to return the response immediately.
        profileByteStream.waitForBytes().then((bytes) {
          profile.trackStreamResponse(
            response: response as HttpStreamResponse,
            streamBody: bytes,
          );
        });
      }

      if (interceptors != null) {
        try {
          final result = await interceptors.afterResponse(response);
          switch (result) {
            case InterceptorNextResult<HttpResponse>() ||
                InterceptorStopResult<HttpResponse>():
              response = result.value ?? response;
            case InterceptorResolveResult<HttpResponse>():
              return result.response;
          }
        } on RhttpException {
          exceptionByInterceptor = true;
          rethrow;
        } catch (e, st) {
          exceptionByInterceptor = true;
          Error.throwWithStackTrace(RhttpInterceptorException(request, e), st);
        }
      }

      return response;
    } else {
      final cancelRefCompleter = Completer<rust_lib.CancellationToken>();
      final responseFuture = rust.makeHttpRequest(
        client: request.client?.ref,
        settings: request.settings?.toRustType(),
        method: request.method._toRustType(),
        url: url,
        query:
            request.queryRaw ??
            request.query?.entries.map((e) => (e.key, e.value)).toList(),
        headers: headers?._toRustType(),
        body: request.body?._toRustType(),
        bodyStream: requestBodyStream,
        expectBody: request.expectBody.toRustType(),
        onCancelToken: (cancelRef) => cancelRefCompleter.complete(cancelRef),
        cancelable: request.cancelToken != null,
      );

      final cancelToken = request.cancelToken;
      if (cancelToken != null) {
        final cancelRef = await cancelRefCompleter.future;
        cancelToken.addRef(cancelRef);
      }

      final rustResponse = await responseFuture;

      HttpResponse response = parseHttpResponse(request, rustResponse);

      profile?.trackResponse(response);

      if (interceptors != null) {
        try {
          final result = await interceptors.afterResponse(response);
          switch (result) {
            case InterceptorNextResult<HttpResponse>() ||
                InterceptorStopResult<HttpResponse>():
              response = result.value ?? response;
            case InterceptorResolveResult<HttpResponse>():
              return result.response;
          }
        } on RhttpException {
          exceptionByInterceptor = true;
          rethrow;
        } catch (e, st) {
          exceptionByInterceptor = true;
          Error.throwWithStackTrace(RhttpInterceptorException(request, e), st);
        }
      }

      return response;
    }
  } catch (e, st) {
    if (exceptionByInterceptor) {
      rethrow;
    }
    if (e is rust_error.RhttpError) {
      RhttpException exception = parseError(request, e);

      if (profile != null) {
        if (exception is RhttpStatusCodeException) {
          profile.trackCustomResponse(
            statusCode: exception.statusCode,
            headers: exception.headers,
            body: exception.body,
          );
        } else {
          profile.trackError(error: e.toString());
        }
      }

      if (interceptors == null) {
        // throw converted exception with same stack trace
        Error.throwWithStackTrace(exception, st);
      }

      try {
        final result = await interceptors.onError(exception);
        switch (result) {
          case InterceptorNextResult<RhttpException>() ||
              InterceptorStopResult<RhttpException>():
            exception = result.value ?? exception;
          case InterceptorResolveResult<RhttpException>():
            return result.response;
        }
        Error.throwWithStackTrace(exception, st);
      } on RhttpException {
        rethrow;
      } catch (e, st) {
        Error.throwWithStackTrace(RhttpInterceptorException(request, e), st);
      }
    } else {
      rethrow;
    }
  }
}

HttpHeaders? _digestHeaders({
  required HttpHeaders? headers,
  required HttpBody? body,
}) {
  if (body is HttpBodyJson) {
    headers = _addHeaderIfNotExists(
      headers: headers,
      name: HttpHeaderName.contentType,
      value: 'application/json',
    );
  }

  if (body is HttpBodyBytesStream && body.length != null) {
    headers = _addHeaderIfNotExists(
      headers: headers,
      name: HttpHeaderName.contentLength,
      value: body.length.toString(),
    );
  }

  return headers;
}

HttpHeaders? _addHeaderIfNotExists({
  required HttpHeaders? headers,
  required HttpHeaderName name,
  required String value,
}) {
  if (headers == null || !headers.containsKey(name)) {
    return (headers ?? HttpHeaders.empty).copyWith(name: name, value: value);
  }
  return headers;
}

Future<rust_stream.Dart2RustStreamReceiver> _createDart2RustStream({
  required HttpBodyBytesStream body,
  required HttpHeaders? headers,
  required ProgressNotifier? sendNotifier,
}) async {
  final bodyLength =
      body.length ?? headers?[HttpHeaderName.contentLength]?.toInt() ?? -1;
  final (sender, receiver) = await rust_stream.createStream();
  listenToStreamWithBackpressure(
    stream: body.stream,
    onData: sendNotifier == null
        ? (data) async {
            await sender.add(data: data);
          }
        : (data) async {
            sendNotifier.notify(data.length, bodyLength);
            await sender.add(data: data);
          },
    onDone: () async {
      sendNotifier?.notifyDone(bodyLength);
      await sender.close();
    },
  ).catchError((e) {
    // Sending errors are caught later anyways.
  });

  return receiver;
}

extension on HttpMethod {
  rust.HttpMethod _toRustType() {
    return rust.HttpMethod(method: value);
  }
}

extension on HttpHeaders {
  rust.HttpHeaders _toRustType() {
    return switch (this) {
      HttpHeaderMap map => rust.HttpHeaders.map({
        for (final entry in map.map.entries) entry.key.httpName: entry.value,
      }),
      HttpHeaderRawMap rawMap => rust.HttpHeaders.map(rawMap.map),
      HttpHeaderList list => rust.HttpHeaders.list(list.list),
    };
  }
}

extension on HttpBody {
  rust.HttpBody _toRustType() {
    return switch (this) {
      HttpBodyText text => rust.HttpBody.text(text.text),
      HttpBodyJson json => rust.HttpBody.text(jsonEncode(json.json)),
      HttpBodyBytes bytes => rust.HttpBody.bytes(bytes.bytes),
      HttpBodyBytesStream _ => const rust.HttpBody.bytesStream(),
      HttpBodyForm form => rust.HttpBody.form(form.form),
      HttpBodyMultipart multipart => rust.HttpBody.multipart(
        rust.MultipartPayload(
          parts: multipart.parts.map((e) {
            final name = e.$1;
            final item = e.$2;
            final rustItem = rust.MultipartItem(
              value: switch (item) {
                MultiPartText() => rust.MultipartValue.text(item.text),
                MultiPartBytes() => rust.MultipartValue.bytes(item.bytes),
                MultiPartFile() => rust.MultipartValue.file(item.file),
              },
              fileName: item.fileName,
              contentType: item.contentType,
            );
            return (name, rustItem);
          }).toList(),
        ),
      ),
    };
  }
}

/// Creates a [StreamTransformer] that listens to the byte stream.
/// Maps the error type to [RhttpException].
StreamTransformer<Uint8List, Uint8List> _createStreamTransformer({
  required HttpRequest request,
  void Function(Uint8List chunk)? onData,
  void Function()? onDone,
}) {
  return StreamTransformer<Uint8List, Uint8List>.fromHandlers(
    handleData: onData == null
        ? null
        : (data, sink) {
            onData(data);
            sink.add(data);
          },
    handleDone: onDone == null
        ? null
        : (sink) {
            onDone();
            sink.close();
          },
    handleError: (error, stackTrace, sink) {
      final mappedError = switch (error) {
        // Flutter Rust Bridge currently always throws AnyhowException
        AnyhowException _ => switch (error.message) {
          _ when error.message.contains('STREAM_CANCEL_ERROR') =>
            RhttpCancelException(request),
          _ => RhttpUnknownException(request, error.message),
        },
        rust_error.RhttpError e => parseError(request, e),
        _ => RhttpUnknownException(request, error.toString()),
      };
      sink.addError(mappedError);
    },
  );
}
