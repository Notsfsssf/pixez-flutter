// ignore_for_file: avoid_print

import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:http/http.dart';
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

const _url =
    'https://github.com/localsend/localsend/releases/download/v1.15.3/LocalSend-1.15.3-linux-x86-64.AppImage';

class _MyAppState extends State<MyApp> {
  RhttpClient? client;
  HttpResponse? response;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Test Page'),
        ),
        body: Row(
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () async {
                    try {
                      final cancelToken = CancelToken();
                      client ??= await RhttpClient.create(
                        settings: const ClientSettings(
                          timeoutSettings: TimeoutSettings(
                            timeout: Duration(seconds: 10),
                          ),
                        ),
                      );
                      final resFuture = client!.requestBytes(
                        method: HttpMethod.get,
                        url: _url,
                        cancelToken: cancelToken,
                      );

                      Future.delayed(const Duration(seconds: 1), () async {
                        await cancelToken.cancel();
                        //client!.dispose(cancelRunningRequests: true);
                      });

                      final res = await resFuture;

                      setState(() {
                        response = res;
                      });
                    } catch (e) {
                      print(e);
                    }
                  },
                  child: const Text('Cancel after 1 second'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    try {
                      final cancelToken = CancelToken();
                      client ??= await RhttpClient.create(
                        settings: const ClientSettings(
                          timeoutSettings: TimeoutSettings(
                            timeout: Duration(seconds: 10),
                          ),
                        ),
                      );

                      final resFuture = client!.requestStream(
                        method: HttpMethod.get,
                        url: _url,
                        cancelToken: cancelToken,
                      );

                      Future.delayed(const Duration(seconds: 1), () async {
                        await cancelToken.cancel();
                      });

                      final res = await resFuture;

                      res.body.listen(
                        (event) {},
                        onError: (e) {
                          print('Stream error: $e');
                        },
                      );

                      setState(() {
                        response = res;
                      });
                    } catch (e) {
                      print(e);
                    }
                  },
                  child: const Text('Cancel after 1 second (stream version)'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    try {
                      final completer = Completer<void>();

                      final request = AbortableRequest(
                        'GET',
                        Uri.parse(_url),
                        abortTrigger: completer.future,
                      );

                      final client = await RhttpCompatibleClient.create();

                      final resFuture = client.send(request);

                      Future.delayed(const Duration(seconds: 1), () {
                        completer.complete();
                      });

                      final res = await resFuture;

                      res.stream.listen(
                        (event) {},
                        onError: (e) {
                          print('Stream error: ${e.runtimeType} $e');
                        },
                      );
                    } catch (e) {
                      print(e);
                    }
                  },
                  child:
                      const Text('Cancel after 1 second (compatible version)'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    try {
                      final cancelToken = CancelToken();
                      client ??= await RhttpClient.create(
                        settings: const ClientSettings(
                          timeoutSettings: TimeoutSettings(
                            timeout: Duration(seconds: 10),
                          ),
                        ),
                      );
                      final resFuture = client!.requestBytes(
                        method: HttpMethod.get,
                        url: _url,
                        cancelToken: cancelToken,
                      );

                      await cancelToken.cancel();

                      final res = await resFuture;

                      setState(() {
                        response = res;
                      });
                    } catch (e) {
                      print(e);
                    }
                  },
                  child: const Text('Cancel immediately'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    try {
                      final cancelToken = CancelToken();
                      client ??= await RhttpClient.create(
                        settings: const ClientSettings(
                          timeoutSettings: TimeoutSettings(
                            timeout: Duration(seconds: 10),
                          ),
                        ),
                      );
                      final resFuture = client!.requestBytes(
                        method: HttpMethod.get,
                        url: _url,
                        cancelToken: cancelToken,
                      );

                      await cancelToken.cancel();
                      await cancelToken.cancel();

                      final res = await resFuture;

                      setState(() {
                        response = res;
                      });
                    } catch (e) {
                      print(e);
                    }
                  },
                  child: const Text('Cancel multiple times'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final cancelToken = CancelToken();
                    client ??= await RhttpClient.create(
                      settings: const ClientSettings(
                        timeoutSettings: TimeoutSettings(
                          timeout: Duration(seconds: 10),
                        ),
                      ),
                    );

                    final resFuture = client!.requestBytes(
                      method: HttpMethod.get,
                      url: _url,
                      cancelToken: cancelToken,
                    );

                    final resFuture2 = client!.requestBytes(
                      method: HttpMethod.get,
                      url: _url,
                      cancelToken: cancelToken,
                    );

                    Future.delayed(const Duration(seconds: 1), () async {
                      await cancelToken.cancel();
                    });

                    try {
                      await resFuture;
                    } catch (e) {
                      print(e);
                    }

                    try {
                      await resFuture2;
                    } catch (e) {
                      print(e);
                    }
                  },
                  child: const Text('Cancel multiple requests'),
                ),
                if (response != null) ResponseCard(response: response!),
              ],
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () async {
                    try {
                      final cancelToken = CancelToken();
                      client ??= await RhttpClient.create(
                        settings: const ClientSettings(
                          timeoutSettings: TimeoutSettings(
                            timeout: Duration(seconds: 10),
                          ),
                        ),
                      );

                      final resFuture = client!.requestBytes(
                        method: HttpMethod.patch,
                        url: 'https://example.com',
                        cancelToken: cancelToken,
                        onSendProgress: (sent, total) {
                          print('Sent: $sent, Total: $total');
                        },
                        body: HttpBody.bytes(
                          _generateBytes(100 * 1024 * 1024),
                        ),
                      );

                      await cancelToken.cancel();

                      final res = await resFuture;

                      setState(() {
                        response = res;
                      });
                    } catch (e) {
                      print(e);
                    }
                  },
                  child: const Text('Cancel upload'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

Uint8List _generateBytes(int length) {
  final list = Uint8List(length);
  for (var i = 0; i < length; i++) {
    list[i] = i % 256;
  }
  return list;
}
