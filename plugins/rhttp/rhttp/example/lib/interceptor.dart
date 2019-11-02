// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:rhttp/rhttp.dart';
import 'package:rhttp_example/widgets/response_card.dart';

Future<void> main() async {
  await Rhttp.init();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
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
                    final res = await Rhttp.get(
                      'https://reqres.in/api/users',
                      query: {'page': '5'},
                      settings: const ClientSettings(
                        httpVersionPref: HttpVersionPref.http3,
                      ),
                      interceptors: [
                        _ReturnFakeInterceptor(),
                      ],
                    );
                    setState(() {
                      response = res;
                    });
                  } catch (e, st) {
                    print(e);
                    print(st);
                  }
                },
                child: const Text('Fake before sending'),
              ),
              ElevatedButton(
                onPressed: () async {
                  try {
                    final res = await Rhttp.get(
                      'https://reqres.in/api/users',
                      query: {'page': '5'},
                      settings: const ClientSettings(
                        httpVersionPref: HttpVersionPref.http3,
                      ),
                      interceptors: [
                        _ReturnFakeAfterSendInterceptor(),
                      ],
                    );
                    setState(() {
                      response = res;
                    });
                  } catch (e, st) {
                    print(e);
                    print(st);
                  }
                },
                child: const Text('Fake after receiving'),
              ),
              ElevatedButton(
                onPressed: () async {
                  try {
                    final client = await RhttpClient.create(
                      interceptors: [
                        RetryInterceptor(
                          maxRetries: 1,
                          beforeRetry: (
                            int retryCount,
                            HttpRequest request,
                            HttpResponse? response,
                            RhttpException? exception,
                          ) async {
                            print('Got Retry!: $exception');
                            return request.copyWith(
                              url: 'https://reqres.in/api/users',
                              query: {'page': '2'},
                            );
                          },
                        ),
                      ],
                    );
                    final res = await client.get(
                      'https://reqres.in/apiw/usersa',
                      query: {'page': '5'},
                    );
                    setState(() {
                      response = res;
                    });
                  } catch (e, st) {
                    print(e);
                    print(st);
                  }
                },
                child: const Text('Handle 404'),
              ),
              if (response != null) ResponseCard(response: response!),
            ],
          ),
        ),
      ),
    );
  }
}

class _ReturnFakeInterceptor extends Interceptor {
  @override
  Future<InterceptorResult<HttpRequest>> beforeRequest(
      HttpRequest request) async {
    return Interceptor.resolve(HttpTextResponse(
      remoteIp: null,
      request: request,
      version: HttpVersion.http1_1,
      statusCode: 204,
      headers: [],
      body: 'Intercepted!',
    ));
  }
}

class _ReturnFakeAfterSendInterceptor extends Interceptor {
  @override
  Future<InterceptorResult<HttpResponse>> afterResponse(
      HttpResponse response) async {
    return Interceptor.resolve(HttpTextResponse(
      remoteIp: response.remoteIp,
      request: response.request,
      version: HttpVersion.http1_1,
      statusCode: 204,
      headers: [],
      body: 'Intercepted >> ${(response as HttpTextResponse).body}',
    ));
  }
}
