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

  test('Should cancel request with same CancelToken during retry', () async {
    bool receivedCancelRequest = false;
    mockApi.mockCancelRequest(
      onAnswer: (cancelRef) {
        receivedCancelRequest = true;
      },
    );

    int called = 0;
    mockApi.mockCustomResponse(
      statusCode: 200,
      body: 'Hello, world!',
      cancelRef: FakeCancellationToken(),
      cancelDelay: const Duration(milliseconds: 10),
      delay: const Duration(milliseconds: 100),
      onAnswer: (_) {
        called++;
        if (called == 1) {
          throw fakeRhttpError('Error 123');
        }
        if (receivedCancelRequest) {
          throw fakeCancelError();
        }
      },
    );

    final cancelToken = CancelToken();
    int retryCount = 0;
    final responseFuture = Rhttp.post(
      'https://example.com',
      cancelToken: cancelToken,
      interceptors: [
        RetryInterceptor(
          beforeRetry: (attempt, request, response, exception) async {
            retryCount++;
            return null;
          },
        ),
      ],
    );

    await Future.delayed(const Duration(milliseconds: 50));

    expect(retryCount, 0);

    await Future.delayed(const Duration(milliseconds: 150));

    expect(called, 1);
    expect(retryCount, 1);

    await cancelToken.cancel();
    expect(receivedCancelRequest, true);

    Object? exception;
    try {
      await responseFuture;
    } catch (e) {
      exception = e;
    }

    expect(exception, isA<RhttpCancelException>());
  });

  test('Should cancel request with same CancelToken before retry', () async {
    bool receivedCancelRequest = false;
    mockApi.mockCancelRequest(
      onAnswer: (cancelRef) {
        receivedCancelRequest = true;
      },
    );

    int called = 0;
    mockApi.mockCustomResponse(
      statusCode: 200,
      body: 'Hello, world!',
      cancelRef: FakeCancellationToken(),
      cancelDelay: const Duration(milliseconds: 10),
      delay: const Duration(milliseconds: 100),
      onAnswer: (_) {
        called++;
        if (called == 1) {
          throw fakeRhttpError('Error 123');
        }
        if (receivedCancelRequest) {
          throw fakeCancelError();
        }
      },
    );

    final cancelToken = CancelToken();
    int retryCount = 0;
    final responseFuture = Rhttp.post(
      'https://example.com',
      cancelToken: cancelToken,
      interceptors: [
        RetryInterceptor(
          beforeRetry: (attempt, request, response, exception) async {
            retryCount++;
            return null;
          },
        ),
      ],
    );

    await Future.delayed(const Duration(milliseconds: 50));

    expect(retryCount, 0);
    expect(called, 0);

    await cancelToken.cancel();
    expect(receivedCancelRequest, true);

    Object? exception;
    try {
      await responseFuture;
    } catch (e) {
      exception = e;
    }

    expect(exception, isA<RhttpCancelException>());
  });

  test('Should do nothing with same CancelToken after retry', () async {
    bool receivedCancelRequest = false;
    mockApi.mockCancelRequest(
      onAnswer: (cancelRef) {
        receivedCancelRequest = true;
      },
    );

    int called = 0;
    mockApi.mockCustomResponse(
      statusCode: 200,
      body: 'Hello, world!',
      cancelRef: FakeCancellationToken(),
      cancelDelay: const Duration(milliseconds: 10),
      delay: const Duration(milliseconds: 100),
      onAnswer: (_) {
        called++;
        if (called == 1) {
          throw fakeRhttpError('Error 123');
        }
        if (receivedCancelRequest) {
          throw fakeCancelError();
        }
      },
    );

    final cancelToken = CancelToken();
    int retryCount = 0;
    final responseFuture = Rhttp.post(
      'https://example.com',
      cancelToken: cancelToken,
      interceptors: [
        RetryInterceptor(
          beforeRetry: (attempt, request, response, exception) async {
            retryCount++;
            return null;
          },
        ),
      ],
    );

    await Future.delayed(const Duration(milliseconds: 50));

    expect(retryCount, 0);

    await Future.delayed(const Duration(milliseconds: 150));

    expect(called, 1);
    expect(retryCount, 1);

    await Future.delayed(const Duration(milliseconds: 250));

    expect(called, 2);
    expect(retryCount, 1);

    await cancelToken.cancel();
    expect(receivedCancelRequest, true);

    HttpTextResponse? response;
    Object? exception;
    try {
      response = await responseFuture;
    } catch (e) {
      exception = e;
    }

    expect(
      response,
      isA<HttpTextResponse>().having((r) => r.body, 'body', 'Hello, world!'),
    );
    expect(exception, null);
  });
}
