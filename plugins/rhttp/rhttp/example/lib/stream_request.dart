// ignore_for_file: avoid_print

import 'dart:convert';

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
                  print('Sending request...');

                  final payload = {
                    'name': 'rhttp!',
                    'job': 'leader',
                  };

                  final bytes = utf8.encode(jsonEncode(payload));

                  final res = await Rhttp.post(
                    'https://reqres.in/api/users',
                    headers: const HttpHeaders.map({
                      HttpHeaderName.contentType: 'application/json',
                    }),
                    body: HttpBody.stream(Stream.fromIterable([bytes]), length: bytes.length),
                  );

                  print('Got response: $res');

                  setState(() {
                    response = res;
                  });
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
