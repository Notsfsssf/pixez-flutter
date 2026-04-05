// ignore_for_file: avoid_print

import 'dart:convert';
import 'dart:io';

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
  HttpClient? client;
  String? response;

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

                  client ??= await IoCompatibleClient.create();

                  final req = await client!.postUrl(
                    Uri.parse('https://reqres.in/api/users'),
                  );
                  req.headers.add('content-type', 'application/json');

                  final bytes = utf8.encode(jsonEncode(payload));
                  req.add(bytes);

                  final res = await req.close();
                  final resText = await res.transform(utf8.decoder).toList();

                  print('Response: ${resText.join()}');

                  setState(() {
                    response = resText.join();
                  });
                },
                child: const Text('Test'),
              ),
              if (response != null) Text(response!),
            ],
          ),
        ),
      ),
    );
  }
}
