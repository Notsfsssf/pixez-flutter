import 'package:flutter_test/flutter_test.dart';
import 'package:rhttp/rhttp.dart';
import 'package:rhttp/src/rust/frb_generated.dart';

import '../mocks.dart';

void main() {
  late MockRustLibApi mockApi;

  setUpAll(() async {
    mockApi = MockRustLibApi.createAndRegister();

    RustLib.initMock(api: mockApi);
  });

  test('Should cancel request', () async {
    bool receivedCancelRequest = false;
    mockApi.mockCancelRequest(
      onAnswer: (cancelRef) {
        receivedCancelRequest = true;
      },
    );

    mockApi.mockCustomResponse(
      statusCode: 200,
      body: 'Hello, world!',
      cancelRef: FakeCancellationToken(),
      cancelDelay: const Duration(milliseconds: 10),
      delay: const Duration(milliseconds: 100),
      onAnswer: (_) {
        if (receivedCancelRequest) {
          throw fakeCancelError();
        }
      },
    );

    final cancelToken = CancelToken();
    HttpResponse? response;
    Object? exception;
    try {
      final responseFuture = Rhttp.get(
        'http://localhost:8080',
        cancelToken: cancelToken,
      );

      await cancelToken.cancel();

      response = await responseFuture;
    } catch (e) {
      exception = e;
    }

    expect(receivedCancelRequest, true);
    expect(response, isNull);
    expect(exception, isA<RhttpCancelException>());
  });

  test('Should not fail if cancelled multiple times', () async {
    bool receivedCancelRequest = false;
    mockApi.mockCancelRequest(
      onAnswer: (cancelRef) {
        receivedCancelRequest = true;
      },
    );

    mockApi.mockCustomResponse(
      statusCode: 200,
      body: 'Hello, world!',
      cancelRef: FakeCancellationToken(),
      cancelDelay: const Duration(milliseconds: 10),
      delay: const Duration(milliseconds: 100),
      onAnswer: (_) {
        if (receivedCancelRequest) {
          throw fakeCancelError();
        }
      },
    );

    final cancelToken = CancelToken();
    HttpResponse? response;
    Object? exception;
    try {
      final responseFuture = Rhttp.get(
        'http://localhost:8080',
        cancelToken: cancelToken,
      );

      await cancelToken.cancel();
      await cancelToken.cancel();

      response = await responseFuture;
    } catch (e) {
      exception = e;
    }

    expect(receivedCancelRequest, true);
    expect(response, isNull);
    expect(exception, isA<RhttpCancelException>());
  });
}
