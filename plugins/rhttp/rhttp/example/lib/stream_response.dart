// ignore_for_file: avoid_print

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:rhttp/rhttp.dart';

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
  HttpStreamResponse? response;
  String text = '';

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
                  print('Sending request...');

                  final res = await Rhttp.requestStream(
                    method: HttpMethod.get,
                    url: 'https://reqres.in/api/users',
                    query: {'page': '5'},
                    headers: const HttpHeaders.map({
                      HttpHeaderName.lastModified: 'application/json',
                    }),
                    settings: const ClientSettings(
                      httpVersionPref: HttpVersionPref.http3,
                    ),
                  );

                  print('Got response: $res');

                  setState(() {
                    response = res;
                  });

                  final bytes = <int>[];
                  res.body.listen((event) {
                    print('Bytes: $event');
                    bytes.addAll(event);
                    setState(() {
                      try {
                        text = utf8.decode(bytes);
                        print('Text: $text');
                      } catch (e) {
                        text = 'Error: $e';
                      }
                    });
                  }, onDone: () {
                    print('Stream done');
                  });
                },
                child: const Text('Test'),
              ),
              if (response != null) Text(response!.version.toString()),
              if (response != null) Text(response!.statusCode.toString()),
              if (response != null) Text(text),
              if (response != null) Text(response!.headers.toString()),
            ],
          ),
        ),
      ),
    );
  }
}
