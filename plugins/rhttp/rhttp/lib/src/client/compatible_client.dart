import 'package:http/http.dart';
import 'package:rhttp/src/client/rhttp_client.dart';
import 'package:rhttp/src/interceptor/interceptor.dart';
import 'package:rhttp/src/model/cancel_token.dart';
import 'package:rhttp/src/model/exception.dart';
import 'package:rhttp/src/model/request.dart';
import 'package:rhttp/src/model/settings.dart';

/// An HTTP client that is compatible with the `http` package.
/// This minimizes the changes needed to switch from `http` to `rhttp`
/// and also avoids vendor lock-in.
///
/// This comes with some downsides, such as:
/// - inferior type safety due to the flaw that `body` is of type `Object?`
///   instead of a sane supertype.
/// - body of type [Map] is implicitly interpreted as `x-www-form-urlencoded`
///   that is only documented in StackOverflow (as of writing this).
/// - no support for cancellation
/// - no out-of-the-box support for multipart requests
class RhttpCompatibleClient with BaseClient {
  /// The actual client that is used to make requests.
  final RhttpClient client;

  /// Creates a new HTTP client from an existing [RhttpClient].
  /// Only for advanced use cases.
  RhttpCompatibleClient.of(this.client);

  /// Creates a new HTTP client asynchronously.
  /// Use this method if your app is already running to avoid blocking the UI.
  static Future<RhttpCompatibleClient> create({
    ClientSettings? settings,
    List<Interceptor>? interceptors,
  }) async {
    final client = await RhttpClient.create(
      settings: (settings ?? const ClientSettings()).digest(),
      interceptors: interceptors,
    );
    return RhttpCompatibleClient.of(client);
  }

  /// Creates a new HTTP client synchronously.
  /// Use this method if your app is starting up to simplify the code
  /// that might arise by using async/await.
  ///
  /// Note:
  /// This method crashes when configured to use HTTP/3.
  /// See: https://codeberg.org/Tienisto/rhttp/issues/10
  factory RhttpCompatibleClient.createSync({
    ClientSettings? settings,
    List<Interceptor>? interceptors,
  }) {
    final client = RhttpClient.createSync(
      settings: (settings ?? const ClientSettings()).digest(),
      interceptors: interceptors,
    );
    return RhttpCompatibleClient.of(client);
  }

  @override
  Future<StreamedResponse> send(BaseRequest request) async {
    final CancelToken? cancelToken;
    switch (request) {
      case Abortable(abortTrigger: final trigger?):
        cancelToken = CancelToken();
        trigger.then((_) {
          cancelToken?.cancel();
        });
        break;
      case _:
        cancelToken = null;
    }

    try {
      final response = await client.requestStream(
        method: HttpMethod(request.method.toUpperCase()),
        url: request.url.toString(),
        headers: HttpHeaders.rawMap(request.headers),
        body: HttpBody.bytes(await request.finalize().toBytes()),
        cancelToken: cancelToken,
      );

      final responseHeaderMap = response.headerMapList.map(
        // Combine multiple values as per `http` package specification.
        (key, value) => MapEntry(key, value.join(', ')),
      );

      return StreamedResponse(
        response.body.handleError((e, st) {
          if (e is RhttpException) {
            if (e is RhttpCancelException) {
              Error.throwWithStackTrace(
                RhttpWrappedRequestAbortedException(request.url, e),
                st,
              );
            }
            Error.throwWithStackTrace(
              RhttpWrappedClientException(e.toString(), request.url, e),
              st,
            );
          }
          Error.throwWithStackTrace(
            ClientException(e.toString(), request.url),
            st,
          );
        }),
        response.statusCode,
        contentLength: switch (responseHeaderMap['content-length']) {
          String s => int.parse(s),
          null => null,
        },
        request: request,
        headers: responseHeaderMap,
        isRedirect: false,

        // TODO
        persistentConnection: true,

        // TODO: Is this even relevant nowadays?
        reasonPhrase: null,
      );
    } on RhttpException catch (e, st) {
      if (e is RhttpCancelException) {
        Error.throwWithStackTrace(
          RhttpWrappedRequestAbortedException(request.url, e),
          st,
        );
      }
      Error.throwWithStackTrace(
        RhttpWrappedClientException(e.toString(), request.url, e),
        st,
      );
    } catch (e, st) {
      Error.throwWithStackTrace(
        ClientException(e.toString(), request.url),
        st,
      );
    }
  }

  @override
  void close() {
    client.dispose(cancelRunningRequests: true);
  }
}

/// Every exception must be a subclass of [ClientException]
/// as per contract of [BaseClient].
class RhttpWrappedClientException extends ClientException {
  /// The original exception that was thrown by rhttp.
  final RhttpException rhttpException;

  RhttpWrappedClientException(super.message, super.uri, this.rhttpException);

  @override
  String toString() => rhttpException.toString();
}

/// Special case for [RequestAbortedException].
class RhttpWrappedRequestAbortedException extends RequestAbortedException {
  /// The original exception that was thrown by rhttp.
  final RhttpException rhttpException;

  RhttpWrappedRequestAbortedException(super.uri, this.rhttpException);

  @override
  String toString() => rhttpException.toString();
}

extension on ClientSettings {
  /// Makes sure that the settings conform to the requirements of [BaseClient].
  ClientSettings digest() {
    ClientSettings settings = this;
    if (throwOnStatusCode) {
      settings = settings.copyWith(
        throwOnStatusCode: false,
      );
    }

    return settings;
  }
}
