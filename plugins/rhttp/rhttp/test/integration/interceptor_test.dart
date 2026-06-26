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

  group('beforeRequest', () {
    test('Should call beforeRequest before sending', () async {
      bool called = false;
      bool receivedAfterCalled = false;
      mockApi.mockDefaultResponse(
        onAnswer: (_) {
          if (called) {
            receivedAfterCalled = true;
          }
        },
      );

      await Rhttp.get(
        'https://example.com',
        interceptors: [
          SimpleInterceptor(
            beforeRequest: (request) async {
              called = true;
              return Interceptor.next();
            },
          ),
        ],
      );

      expect(called, true);
      expect(receivedAfterCalled, true);
    });

    test('Should resolve response', () async {
      mockApi.mockErrorResponse();

      final response = await Rhttp.get(
        'https://example.com',
        interceptors: [
          SimpleInterceptor(
            beforeRequest: (request) async {
              return Interceptor.resolve(FakeHttpResponse('before123'));
            },
          ),
        ],
      );

      expect(
        response,
        isA<FakeHttpResponse>().having((r) => r.body, 'body', 'before123'),
      );
    });

    test('Should wrap exception', () async {
      mockApi.mockErrorResponse();

      Object? exception;
      StackTrace? stackTrace;
      try {
        await Rhttp.get(
          'https://some-url-123',
          interceptors: [
            SimpleInterceptor(
              beforeRequest: (request) async {
                throw 'Test 123';
              },
            ),
          ],
        );
      } catch (e, st) {
        exception = e;
        stackTrace = st;
      }

      expect(
        exception,
        isA<RhttpInterceptorException>().having(
          (e) => e.error,
          'error',
          'Test 123',
        ),
      );
      expect(
        exception,
        isA<RhttpInterceptorException>().having(
          (e) => stackTrace.toString(),
          'stackTrace',
          contains('interceptor_test.dart'),
        ),
      );
      expect(
        exception,
        isA<RhttpInterceptorException>().having(
          (e) => e.request.url,
          'request.url',
          'https://some-url-123',
        ),
      );
    });

    test('Should rethrow RhttpException', () async {
      mockApi.mockErrorResponse();

      Object? exception;
      try {
        await Rhttp.get(
          'https://url-456',
          interceptors: [
            SimpleInterceptor(
              beforeRequest: (request) async {
                throw RhttpStatusCodeException(
                  request: request,
                  statusCode: 222,
                  headers: [],
                  body: null,
                );
              },
            ),
          ],
        );
      } catch (e) {
        exception = e;
      }

      expect(
        exception,
        isA<RhttpStatusCodeException>().having(
          (e) => e.statusCode,
          'statusCode',
          222,
        ),
      );
      expect(
        exception,
        isA<RhttpStatusCodeException>().having(
          (e) => e.request.url,
          'request.url',
          'https://url-456',
        ),
      );
    });

    test('Should not modify request', () async {
      mockApi.mockDefaultResponse();

      final response = await Rhttp.get(
        'https://example.com',
        interceptors: [
          SimpleInterceptor(
            beforeRequest: (request) async {
              return Interceptor.next();
            },
          ),
        ],
      );

      expect(response.request.url, 'https://example.com');
    });

    test('Should modify request', () async {
      String detectedUrl = '';
      mockApi.mockDefaultResponse(
        onAnswer: (url) => detectedUrl = url,
      );

      final response = await Rhttp.get(
        'https://example.com',
        interceptors: [
          SimpleInterceptor(
            beforeRequest: (request) async {
              return Interceptor.next(
                request.copyWith(
                  url: 'https://example.com/modified',
                ),
              );
            },
          ),
        ],
      );

      expect(response.request.url, 'https://example.com/modified');
      expect(detectedUrl, 'https://example.com/modified');
    });
  });

  group('afterResponse', () {
    test('Should call afterResponse after receiving', () async {
      bool received = false;
      mockApi.mockDefaultResponse(onAnswer: (_) => received = true);

      bool calledAfterReceived = false;
      final response = await Rhttp.get(
        'https://example.com',
        interceptors: [
          SimpleInterceptor(
            afterResponse: (request) async {
              if (received) {
                calledAfterReceived = true;
              }
              return Interceptor.next();
            },
          ),
        ],
      );

      expect(calledAfterReceived, true);
      expect(response, isA<HttpTextResponse>());
    });

    test('Should resolve response', () async {
      mockApi.mockDefaultResponse();

      final response = await Rhttp.get(
        'https://example.com',
        interceptors: [
          SimpleInterceptor(
            afterResponse: (response) async {
              return Interceptor.resolve(FakeHttpResponse('after123'));
            },
          ),
        ],
      );

      expect(
        response,
        isA<FakeHttpResponse>().having((r) => r.body, 'body', 'after123'),
      );
    });

    test('Should wrap exception', () async {
      mockApi.mockDefaultResponse();

      Object? exception;
      StackTrace? stackTrace;
      try {
        await Rhttp.get(
          'https://some-url-123',
          interceptors: [
            SimpleInterceptor(
              afterResponse: (response) async {
                throw 'Test 123';
              },
            ),
          ],
        );
      } catch (e, st) {
        exception = e;
        stackTrace = st;
      }

      expect(
        exception,
        isA<RhttpInterceptorException>().having(
          (e) => e.error,
          'error',
          'Test 123',
        ),
      );
      expect(
        exception,
        isA<RhttpInterceptorException>().having(
          (e) => stackTrace.toString(),
          'stackTrace',
          contains('interceptor_test.dart'),
        ),
      );
    });

    test('Should rethrow RhttpException', () async {
      mockApi.mockDefaultResponse();

      Object? exception;
      try {
        await Rhttp.get(
          'https://url-456',
          interceptors: [
            SimpleInterceptor(
              afterResponse: (response) async {
                throw RhttpStatusCodeException(
                  request: response.request,
                  statusCode: 222,
                  headers: [],
                  body: null,
                );
              },
            ),
          ],
        );
      } catch (e) {
        exception = e;
      }

      expect(
        exception,
        isA<RhttpStatusCodeException>().having(
          (e) => e.statusCode,
          'statusCode',
          222,
        ),
      );
      expect(
        exception,
        isA<RhttpStatusCodeException>().having(
          (e) => e.request.url,
          'request.url',
          'https://url-456',
        ),
      );
    });

    test('Should not modify response', () async {
      mockApi.mockCustomResponse(body: 'original-response');

      final response = await Rhttp.get(
        'https://example.com',
        interceptors: [
          SimpleInterceptor(
            afterResponse: (response) async {
              return Interceptor.next();
            },
          ),
        ],
      );

      expect(response.body, 'original-response');
    });

    test('Should modify response', () async {
      mockApi.mockCustomResponse(body: 'original-response');

      final response = await Rhttp.get(
        'https://example.com',
        interceptors: [
          SimpleInterceptor(
            afterResponse: (response) async {
              return Interceptor.next(FakeHttpResponse('modified-response'));
            },
          ),
        ],
      );

      expect(response.body, 'modified-response');
    });
  });

  group('onError', () {
    test('Should be called on exception', () async {
      mockApi.mockErrorResponse(exception: fakeRhttpError('Test exception'));

      bool called = false;
      Object? exceptionInInterceptor;
      Object? exceptionAfterReturn;
      try {
        await Rhttp.get(
          'https://example.com',
          interceptors: [
            SimpleInterceptor(
              onError: (exception) async {
                called = true;
                exceptionInInterceptor = exception;
                return Interceptor.next();
              },
            ),
          ],
        );
      } catch (e) {
        exceptionAfterReturn = e;
      }

      expect(called, true);
      expect(
        exceptionInInterceptor,
        isA<RhttpUnknownException>().having(
          (e) => e.message,
          'message',
          'Test exception',
        ),
      );
      expect(
        exceptionAfterReturn,
        isA<RhttpUnknownException>().having(
          (e) => e.message,
          'message',
          'Test exception',
        ),
      );
    });

    test('Should resolve response', () async {
      mockApi.mockErrorResponse(exception: fakeRhttpError('Test exception'));

      final response = await Rhttp.get(
        'https://example.com',
        interceptors: [
          SimpleInterceptor(
            onError: (exception) async {
              return Interceptor.resolve(FakeHttpResponse('resolved'));
            },
          ),
        ],
      );

      expect(
        response,
        isA<FakeHttpResponse>().having((r) => r.body, 'body', 'resolved'),
      );
    });

    test('Should wrap exception', () async {
      mockApi.mockErrorResponse(exception: fakeRhttpError('Test exception'));

      Object? exception;
      StackTrace? stackTrace;
      try {
        await Rhttp.get(
          'https://example.com',
          interceptors: [
            SimpleInterceptor(
              onError: (exception) async {
                throw 'Test 123';
              },
            ),
          ],
        );
      } catch (e, st) {
        exception = e;
        stackTrace = st;
      }

      expect(
        exception,
        isA<RhttpInterceptorException>().having(
          (e) => e.error,
          'error',
          'Test 123',
        ),
      );
      expect(
        exception,
        isA<RhttpInterceptorException>().having(
          (e) => stackTrace.toString(),
          'stackTrace',
          contains('interceptor_test.dart'),
        ),
      );
    });

    test('Should rethrow RhttpException', () async {
      mockApi.mockErrorResponse(exception: fakeRhttpError('Test exception'));

      Object? exception;
      try {
        await Rhttp.get(
          'https://example.com',
          interceptors: [
            SimpleInterceptor(
              onError: (exception) async {
                throw RhttpStatusCodeException(
                  request: exception.request,
                  statusCode: 222,
                  headers: [],
                  body: null,
                );
              },
            ),
          ],
        );
      } catch (e) {
        exception = e;
      }

      expect(
        exception,
        isA<RhttpStatusCodeException>().having(
          (e) => e.statusCode,
          'statusCode',
          222,
        ),
      );
      expect(
        exception,
        isA<RhttpStatusCodeException>().having(
          (e) => e.request.url,
          'request.url',
          'https://example.com',
        ),
      );
    });

    test('Should not modify exception', () async {
      mockApi.mockErrorResponse(exception: fakeRhttpError('Test exception'));

      Object? exception;
      try {
        await Rhttp.get(
          'https://example.com',
          interceptors: [
            SimpleInterceptor(
              onError: (exception) async {
                return Interceptor.next();
              },
            ),
          ],
        );
      } catch (e) {
        exception = e;
      }

      expect(
        exception,
        isA<RhttpUnknownException>().having(
          (e) => e.message,
          'message',
          'Test exception',
        ),
      );
    });

    test('Should modify exception', () async {
      mockApi.mockErrorResponse(exception: fakeRhttpError('Test exception'));

      Object? exception;
      try {
        await Rhttp.get(
          'https://example.com',
          interceptors: [
            SimpleInterceptor(
              onError: (exception) async {
                return Interceptor.next(
                  RhttpUnknownException(
                    exception.request,
                    'modified exception',
                  ),
                );
              },
            ),
          ],
        );
      } catch (e) {
        exception = e;
      }

      expect(
        exception,
        isA<RhttpUnknownException>().having(
          (e) => e.message,
          'message',
          'modified exception',
        ),
      );
    });

    test('Should not catch exception from interceptor', () async {
      mockApi.mockDefaultResponse();

      bool called = false;
      Object? exception;
      try {
        await Rhttp.get(
          'https://example.com',
          interceptors: [
            SimpleInterceptor(
              afterResponse: (request) async {
                throw 'Test 123';
              },
              onError: (exception) async {
                called = true;
                return Interceptor.next();
              },
            ),
          ],
        );
      } catch (e) {
        exception = e;
      }

      expect(
        exception,
        isA<RhttpInterceptorException>().having(
          (e) => e.error,
          'error',
          'Test 123',
        ),
      );
      expect(called, false);
    });
  });
}
