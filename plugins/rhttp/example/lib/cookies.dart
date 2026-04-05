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
  HttpResponse? response;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Test Page'),
        ),
        body: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () async {
                  try {
                    final client = await RhttpClient.create(
                      settings: const ClientSettings(
                          cookieSettings: CookieSettings(storeCookies: true)),
                    );

                    final res = await client.requestText(
                      method: HttpMethod.get,
                      url:
                          'https://httpbin.org/cookies/set?cookie1=value1&cookie2=value2',
                    );

                    setState(() {
                      response = res;
                    });
                  } catch (e) {
                    print(e);
                  }
                },
                child: const Text('Store Cookies'),
              ),
              ElevatedButton(
                onPressed: () async {
                  try {
                    final client = await RhttpClient.create(
                      settings: const ClientSettings(
                          cookieSettings: CookieSettings.none()),
                    );

                    final res = await client.requestText(
                      method: HttpMethod.get,
                      url:
                          'https://httpbin.org/cookies/set?cookie1=value1&cookie2=value2',
                    );

                    setState(() {
                      response = res;
                    });
                  } catch (e) {
                    print(e);
                  }
                },
                child: const Text('Ignore Cookies'),
              ),
              if (response != null) ResponseCard(response: response!),
            ],
          ),
        ),
      ),
    );
  }
}
