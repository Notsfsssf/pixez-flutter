import 'dart:typed_data';

import 'package:meta/meta.dart';
import 'package:rhttp/src/client/rhttp_client.dart';
import 'package:rhttp/src/interceptor/interceptor.dart';
import 'package:rhttp/src/interceptor/sequential_interceptor.dart';
import 'package:rhttp/src/model/cancel_token.dart';
import 'package:rhttp/src/model/header.dart';
import 'package:rhttp/src/model/response.dart';
import 'package:rhttp/src/model/settings.dart';
import 'package:rhttp/src/request.dart';
import 'package:rhttp/src/rust/api/http.dart' as rust;
import 'package:rhttp/src/util/collection.dart';
import 'package:rhttp/src/util/http_header.dart';

const Map<String, String> _keepQuery = {'__rhttp_keep__': '__rhttp_keep__'};
const List<(String, String)> _keepQueryRaw = [
  ('__rhttp_keep__', '__rhttp_keep__'),
];
const HttpHeaders _keepHeaders = HttpHeaders.rawMap({'__keep__': '__keep__'});
const HttpBody _keepBody = HttpBody.text('__rhttp_keep__');

/// A callback that can be used to report progress.
/// [count] is the current count of bytes received / sent.
/// [total] is the total count of bytes to receive / send.
/// [total] might be -1 when it is unknown (e.g. missing Content-Length header).
///
/// Note:
/// This is currently only implemented for byte(stream) requests and responses.
typedef ProgressCallback = void Function(int count, int total);

/// An HTTP request that can be used
/// on a client or statically.
class BaseHttpRequest {
  /// The HTTP method to use.
  final HttpMethod method;

  /// The URL to request.
  final String url;

  /// Query parameters.
  /// This can be null, if there are no query parameters
  /// or if they are already part of the URL.
  final Map<String, String>? query;

  /// Raw query parameters as a list of key-value pairs.
  /// This allows for duplicate keys, which is not possible with [query].
  /// Cannot be used together with [query].
  final List<(String, String)>? queryRaw;

  /// Headers to send with the request.
  final HttpHeaders? headers;

  /// The body of the request.
  final HttpBody? body;

  /// The expected body type of the response.
  final HttpExpectBody expectBody;

  /// The cancel token to use for the request.
  final CancelToken? cancelToken;

  /// Send progress callback.
  final ProgressCallback? onSendProgress;

  /// Receive progress callback.
  final ProgressCallback? onReceiveProgress;

  /// Map that can be used to store additional information.
  /// Primarily used by interceptors.
  /// This is not const to allow for modifications.
  final Map<String, dynamic> additionalData = {};

  BaseHttpRequest({
    this.method = HttpMethod.get,
    required this.url,
    this.query,
    this.queryRaw,
    this.headers,
    this.body,
    this.expectBody = HttpExpectBody.stream,
    this.cancelToken,
    this.onSendProgress,
    this.onReceiveProgress,
  }) {
    if (query != null && queryRaw != null) {
      throw ArgumentError('Cannot specify both query and queryRaw parameters');
    }
  }
}

/// An HTTP request with the information which client to use.
class HttpRequest extends BaseHttpRequest {
  /// The client to use for the request.
  final RhttpClient? client;

  /// The settings to use for the request.
  final ClientSettings? settings;

  /// The interceptor to use for the request.
  /// This can be a [SequentialInterceptor] if there are multiple interceptors.
  final Interceptor? interceptor;

  HttpRequest({
    this.client,
    this.settings,
    this.interceptor,
    super.method,
    required super.url,
    super.query,
    super.queryRaw,
    super.headers,
    super.body,
    super.expectBody,
    super.cancelToken,
    super.onSendProgress,
    super.onReceiveProgress,
  });

  factory HttpRequest.from({
    required BaseHttpRequest request,
    RhttpClient? client,
    ClientSettings? settings,
    Interceptor? interceptor,
  }) => HttpRequest(
    client: client,
    settings: settings,
    interceptor: interceptor,
    method: request.method,
    url: request.url,
    query: request.query,
    queryRaw: request.queryRaw,
    headers: request.headers,
    body: request.body,
    expectBody: request.expectBody,
    cancelToken: request.cancelToken,
    onSendProgress: request.onSendProgress,
    onReceiveProgress: request.onReceiveProgress,
  );

  /// Sends the request using the specified client / settings
  /// and returns the response.
  Future<HttpResponse> send() => requestInternalGeneric(this);

  HttpRequest copyWith({
    RhttpClient? client,
    ClientSettings? settings,
    HttpMethod? method,
    String? url,
    Map<String, String>? query = _keepQuery,
    List<(String, String)>? queryRaw = _keepQueryRaw,
    HttpHeaders? headers = _keepHeaders,
    HttpBody? body = _keepBody,
    HttpExpectBody? expectBody,
    CancelToken? cancelToken,
  }) {
    final request = HttpRequest(
      client: client ?? this.client,
      settings: settings ?? this.settings,
      interceptor: interceptor,
      method: method ?? this.method,
      url: url ?? this.url,
      query: identical(query, _keepQuery) ? this.query : query,
      queryRaw: identical(queryRaw, _keepQueryRaw) ? this.queryRaw : queryRaw,
      headers: identical(headers, _keepHeaders) ? this.headers : headers,
      body: identical(body, _keepBody) ? this.body : body,
      expectBody: expectBody ?? this.expectBody,
      cancelToken: cancelToken ?? this.cancelToken,
      onSendProgress: onSendProgress,
      onReceiveProgress: onReceiveProgress,
    );

    request.additionalData.addAll(additionalData);

    return request;
  }

  /// Convenience method to add a header to the request.
  /// Returns a new instance of [HttpRequest] with the added header.
  HttpRequest addHeader({required HttpHeaderName name, required String value}) {
    return copyWith(
      headers: (headers ?? HttpHeaders.empty).copyWith(
        name: name,
        value: value,
      ),
    );
  }
}

enum HttpExpectBody {
  /// The response body is parsed as text.
  text,

  /// The response body is parsed as bytes.
  bytes,

  /// The response body is a stream of bytes.
  stream,
}

/// The HTTP method to use.
class HttpMethod {
  final String value;

  const HttpMethod(this.value);

  static const options = HttpMethod('OPTIONS');

  static const get = HttpMethod('GET');

  static const post = HttpMethod('POST');

  static const put = HttpMethod('PUT');

  static const delete = HttpMethod('DELETE');

  static const head = HttpMethod('HEAD');

  static const trace = HttpMethod('TRACE');

  static const connect = HttpMethod('CONNECT');

  static const patch = HttpMethod('PATCH');
}

enum HttpVersionPref {
  /// Only use HTTP/1.0.
  http1_0,

  /// Only use HTTP/1.1.
  http1_1,

  /// Only use HTTP/2.
  http2,

  /// Only use HTTP/3.
  http3,

  /// Default behavior: Let the server decide.
  all,
}

sealed class HttpHeaders {
  const HttpHeaders();

  /// A typed header map with a set of predefined keys.
  const factory HttpHeaders.map(Map<HttpHeaderName, String> map) =
      HttpHeaderMap._;

  /// A raw header map where the keys are strings.
  const factory HttpHeaders.rawMap(Map<String, String> map) =
      HttpHeaderRawMap._;

  /// A raw header list.
  /// This allows for multiple headers with the same name.
  const factory HttpHeaders.list(List<(String, String)> list) =
      HttpHeaderList._;

  /// An empty header map.
  static const HttpHeaders empty = HttpHeaderMap._({});

  /// Returns true if the headers contain the [key].
  bool containsKey(HttpHeaderName key) {
    return switch (this) {
      HttpHeaderMap map => map.map.containsKey(key),
      HttpHeaderRawMap rawMap => rawMap.map.keys.any(
        (e) => e.toLowerCase() == key.httpName,
      ),
      HttpHeaderList list => list.list.any(
        (e) => e.$1.toLowerCase() == key.httpName,
      ),
    };
  }

  /// Returns the value of the header with the [key].
  /// Returns null if the header is not found.
  String? operator [](HttpHeaderName key) {
    return switch (this) {
      HttpHeaderMap map => map.map[key],
      HttpHeaderRawMap rawMap =>
        rawMap.map[key.httpName] ??
            rawMap.map.entries
                .firstWhereOrNull((e) => e.key.toLowerCase() == key.httpName)
                ?.value,
      HttpHeaderList list =>
        list.list
            .firstWhereOrNull((e) => e.$1.toLowerCase() == key.httpName)
            ?.$2,
    };
  }

  /// Adds a header to the headers.
  /// Returns a new instance of [HttpHeaders] with the added header.
  /// Converts [HttpHeaderMap] to [HttpHeaderRawMap].
  HttpHeaders copyWithRaw({required String name, required String value}) {
    return switch (this) {
      HttpHeaderMap map => HttpHeaders.rawMap({
        for (final entry in map.map.entries) entry.key.httpName: entry.value,
        name: value,
      }),
      HttpHeaderRawMap rawMap => HttpHeaders.rawMap({
        ...rawMap.map,
        name: value,
      }),
      HttpHeaderList list => HttpHeaders.list([...list.list, (name, value)]),
    };
  }

  /// Adds a header to the headers.
  /// Returns a new instance of [HttpHeaders] with the added header.
  HttpHeaders copyWith({required HttpHeaderName name, required String value}) {
    return switch (this) {
      HttpHeaderMap map => HttpHeaders.map({...map.map, name: value}),
      HttpHeaderRawMap rawMap => HttpHeaders.rawMap({
        ...rawMap.map,
        name.httpName: value,
      }),
      HttpHeaderList list => HttpHeaders.list([
        ...list.list,
        (name.httpName, value),
      ]),
    };
  }

  /// Removes a header from the headers.
  /// Returns a new instance of [HttpHeaders] without the [key].
  HttpHeaders copyWithout(HttpHeaderName key) {
    return switch (this) {
      HttpHeaderMap map => HttpHeaders.map({
        for (final entry in map.map.entries)
          if (entry.key != key) entry.key: entry.value,
      }),
      HttpHeaderRawMap rawMap => HttpHeaders.rawMap({
        for (final entry in rawMap.map.entries)
          if (entry.key.toLowerCase() != key.httpName) entry.key: entry.value,
      }),
      HttpHeaderList list => HttpHeaders.list([
        for (final entry in list.list)
          if (entry.$1.toLowerCase() != key.httpName) entry,
      ]),
    };
  }

  /// Removes a header from the headers.
  /// Returns a new instance of [HttpHeaders] without the [key].
  /// Converts [HttpHeaderMap] to [HttpHeaderRawMap].
  HttpHeaders copyWithoutRaw(String key) {
    key = key.toLowerCase();
    return switch (this) {
      HttpHeaderMap map => HttpHeaders.rawMap({
        for (final entry in map.map.entries)
          if (entry.key.httpName != key) entry.key.httpName: entry.value,
      }),
      HttpHeaderRawMap rawMap => HttpHeaders.rawMap({
        for (final entry in rawMap.map.entries)
          if (entry.key.toLowerCase() != key) entry.key: entry.value,
      }),
      HttpHeaderList list => HttpHeaders.list([
        for (final entry in list.list)
          if (entry.$1.toLowerCase() != key) entry,
      ]),
    };
  }

  /// Converts the headers to a map where duplicate headers are represented
  /// using a list of values.
  Map<String, List<String>> toMapList() {
    return switch (this) {
      HttpHeaderMap map => {
        for (final entry in map.map.entries) entry.key.httpName: [entry.value],
      },
      HttpHeaderRawMap rawMap => {
        for (final entry in rawMap.map.entries) entry.key: [entry.value],
      },
      HttpHeaderList list => list.list.asHeaderMapList,
    };
  }
}

/// A typed header map with a set of predefined keys.
class HttpHeaderMap extends HttpHeaders {
  final Map<HttpHeaderName, String> map;

  const HttpHeaderMap._(this.map);

  @override
  String toString() {
    return 'HttpHeaderMap(${map.toString()})';
  }
}

/// A raw header map where the keys are strings.
class HttpHeaderRawMap extends HttpHeaders {
  final Map<String, String> map;

  const HttpHeaderRawMap._(this.map);

  @override
  String toString() {
    return 'HttpHeaderRawMap(${map.toString()})';
  }
}

/// A raw header list.
/// This allows for multiple headers with the same name.
class HttpHeaderList extends HttpHeaders {
  final List<(String, String)> list;

  const HttpHeaderList._(this.list);

  @override
  String toString() {
    return 'HttpHeaderList(${list.toString()})';
  }
}

sealed class HttpBody {
  const HttpBody();

  /// A plain text body.
  const factory HttpBody.text(String text) = HttpBodyText._;

  /// A JSON body.
  /// The Content-Type header will be set to `application/json` if not provided.
  const factory HttpBody.json(Object? json) = HttpBodyJson._;

  /// A body of raw bytes.
  const factory HttpBody.bytes(Uint8List bytes) = HttpBodyBytes._;

  /// A body of a raw bytes stream.
  /// This is useful to avoid loading the entire body into memory.
  /// The Content-Length header will be set if [length] is provided.
  const factory HttpBody.stream(Stream<List<int>> stream, {int? length}) =
      HttpBodyBytesStream._;

  /// A www-form-urlencoded body.
  /// The Content-Type header will be set to `application/x-www-form-urlencoded`
  /// if not provided.
  const factory HttpBody.form(Map<String, String> form) = HttpBodyForm._;

  /// Multi-part form data.
  /// The Content-Type header will be overridden to `multipart/form-data`
  /// with a random boundary.
  factory HttpBody.multipart(Map<String, MultipartItem> formData) =
      HttpBodyMultipart.map;
}

/// A plain text body.
class HttpBodyText extends HttpBody {
  final String text;

  const HttpBodyText._(this.text);
}

/// A JSON body.
/// The Content-Type header will be set to `application/json` if not provided.
class HttpBodyJson extends HttpBody {
  final Object? json;

  const HttpBodyJson._(this.json);
}

/// A body of raw bytes.
class HttpBodyBytes extends HttpBody {
  final Uint8List bytes;

  const HttpBodyBytes._(this.bytes);
}

/// A body of a raw bytes stream.
/// This is useful to avoid loading the entire body into memory.
/// The Content-Length header will be set if [length] is provided.
class HttpBodyBytesStream extends HttpBody {
  final int? length;
  final Stream<List<int>> stream;

  const HttpBodyBytesStream._(this.stream, {this.length});
}

/// A www-form-urlencoded body.
/// The Content-Type header will be set to `application/x-www-form-urlencoded`
/// if not provided.
class HttpBodyForm extends HttpBody {
  final Map<String, String> form;

  const HttpBodyForm._(this.form);
}

/// Multi-part form data.
/// The Content-Type header will be overridden to `multipart/form-data`
/// with a random boundary.
class HttpBodyMultipart extends HttpBody {
  final List<(String, MultipartItem)> parts;

  const HttpBodyMultipart._(this.parts);

  factory HttpBodyMultipart.map(Map<String, MultipartItem> map) {
    return HttpBodyMultipart._([
      for (final entry in map.entries) (entry.key, entry.value),
    ]);
  }

  /// Public in case you want to create a list of form data manually.
  const factory HttpBodyMultipart.list(List<(String, MultipartItem)> list) =
      HttpBodyMultipart._;
}

sealed class MultipartItem {
  final String? fileName;
  final String? contentType;

  const MultipartItem({this.fileName, this.contentType});

  /// A plain text value.
  const factory MultipartItem.text({
    required String text,
    String? fileName,
    String? contentType,
  }) = MultiPartText._;

  /// A value of raw bytes.
  const factory MultipartItem.bytes({
    required Uint8List bytes,
    String? fileName,
    String? contentType,
  }) = MultiPartBytes._;

  /// A file path.
  const factory MultipartItem.file({
    required String file,
    String? fileName,
    String? contentType,
  }) = MultiPartFile._;
}

/// A plain text value.
class MultiPartText extends MultipartItem {
  final String text;

  const MultiPartText._({
    required this.text,
    super.fileName,
    super.contentType,
  });
}

/// A value of raw bytes.
class MultiPartBytes extends MultipartItem {
  final Uint8List bytes;

  const MultiPartBytes._({
    required this.bytes,
    super.fileName,
    super.contentType,
  });
}

/// A file path.
class MultiPartFile extends MultipartItem {
  final String file;

  const MultiPartFile._({
    required this.file,
    super.fileName,
    super.contentType,
  });
}

@internal
extension HttpExpectBodyExt on HttpExpectBody {
  rust.HttpExpectBody toRustType() {
    return switch (this) {
      HttpExpectBody.text => rust.HttpExpectBody.text,
      HttpExpectBody.bytes => rust.HttpExpectBody.bytes,
      HttpExpectBody.stream => throw UnimplementedError(),
    };
  }
}
