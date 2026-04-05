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
                      headers: const HttpHeaders.rawMap({
                        'x-api-key': 'reqres-free-v1',
                      }),
                      settings: const ClientSettings(
                        httpVersionPref: HttpVersionPref.http3,
                      ),
                    );
                    setState(() {
                      response = res;
                    });
                  } catch (e, st) {
                    print(e);
                    print(st);
                  }
                },
                child: const Text('Test'),
              ),
              if (response != null) ResponseCard(response: response!),
              // if (response != null) Text(response!.headers.toString()),
            ],
          ),
        ),
      ),
    );
  }
}
