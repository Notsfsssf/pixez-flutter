// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rhttp/rhttp.dart';
import 'package:rhttp_example/widgets/response_card.dart';

class Auth {
  final String refreshToken;
  final String accessToken;

  Auth({
    required this.refreshToken,
    required this.accessToken,
  });
}

final authProvider = StateProvider<Auth?>((ref) {
  return null;
});

final clientProvider = Provider<RhttpClient>((ref) {
  return RhttpClient.createSync(
    interceptors: [
      AuthInterceptor(ref),
      RefreshTokenInterceptor(ref),
      LoggingInterceptor(),
    ],
  );
});

/// This interceptor adds the Authorization header to the request.
class AuthInterceptor extends Interceptor {
  final Ref ref;

  AuthInterceptor(this.ref);

  @override
  Future<InterceptorResult<HttpRequest>> beforeRequest(
    HttpRequest request,
  ) async {
    final auth = ref.read(authProvider);
    if (auth != null) {
      return Interceptor.next(request.addHeader(
        name: HttpHeaderName.authorization,
        value: 'Bearer ${auth.accessToken}',
      ));
    }
    return Interceptor.next();
  }
}

/// This interceptor refreshes the token if the request fails with a 401 or 403.
class RefreshTokenInterceptor extends RetryInterceptor {
  final Ref ref;

  RefreshTokenInterceptor(this.ref);

  @override
  int get maxRetries => 1;

  @override
  bool shouldRetry(HttpResponse? response, RhttpException? exception) {
    return exception is RhttpStatusCodeException &&
        (exception.statusCode == 401 || exception.statusCode == 403);
  }

  @override
  Future<HttpRequest?> beforeRetry(
    int attempt,
    HttpRequest request,
    HttpResponse? response,
    RhttpException? exception,
  ) async {
    ref.read(authProvider.notifier).state = await refresh();
    return null;
  }

  Future<Auth?> refresh() async {
    print('Refreshing token...');
    final response = await Rhttp.post(
      'https://dummyjson.com/auth/login',
      interceptors: [LoggingInterceptor()],
      body: const HttpBody.json({
        'username': 'emilys',
        'password': 'emilyspass',
      }),
    );

    final body = response.bodyToJson;

    return Auth(
      refreshToken: body['refreshToken'] as String,
      accessToken: body['token'] as String,
    );
  }
}

class LoggingInterceptor extends SimpleInterceptor {
  @override
  Future<InterceptorResult<HttpRequest>> beforeRequest(
    HttpRequest request,
  ) async {
    print('Request: ${request.url}, headers: ${request.headers}');
    return Interceptor.next();
  }
}

Future<void> main() async {
  await Rhttp.init();

  runApp(const ProviderScope(
    child: MyApp(),
  ));
}

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  HttpTextResponse? response;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Test Page'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              ElevatedButton(
                onPressed: () async {
                  try {
                    final res = await ref.read(clientProvider).get(
                          'https://dummyjson.com/auth/me',
                        );

                    setState(() {
                      response = res;
                    });
                  } catch (e) {
                    if (e is RhttpStatusCodeException) {
                      print('Body: ${e.body}');
                    }
                  }
                },
                child: const Text('Test'),
              ),
              if (response != null) ResponseCard(response: response!),
            ],
          ),
        ),
      ),
    );
  }
}
