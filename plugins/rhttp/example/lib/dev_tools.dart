// ignore_for_file: avoid_print

import 'dart:convert';

import 'package:cupertino_http/cupertino_http.dart';
import 'package:flutter/material.dart';
import 'package:rhttp/rhttp.dart';
import 'package:http/http.dart' as http;
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
                    final res = await Rhttp.post(
                      'https://reqres.in/api/users',
                      body: const HttpBody.json({
                        'name': 'morpheus',
                        'job': 'leader',
                      }),
                    );
                    setState(() {
                      response = res;
                    });
                  } catch (e, st) {
                    print(e);
                    print(st);
                  }
                },
                child: const Text('Rhttp Test'),
              ),
              ElevatedButton(
                onPressed: () async {
                  try {
                    final res = await Rhttp.post(
                      'https://reqres.ina/api/users',
                      body: const HttpBody.json({
                        'name': 'morpheus',
                        'job': 'leader',
                      }),
                    );
                    setState(() {
                      response = res;
                    });
                  } catch (e, st) {
                    print(e);
                    print(st);
                  }
                },
                child: const Text('Rhttp Connection Error Test'),
              ),
              ElevatedButton(
                onPressed: () async {
                  try {
                    final res = await Rhttp.post(
                      'https://reqres.in/aapi/users',
                      body: const HttpBody.json({
                        'name': 'morpheus',
                        'job': 'leader',
                      }),
                    );
                    setState(() {
                      response = res;
                    });
                  } catch (e, st) {
                    print(e);
                    print(st);
                  }
                },
                child: const Text('Rhttp 404 Error Test'),
              ),
              ElevatedButton(
                onPressed: () async {
                  try {
                    await http.post(
                      Uri.parse('https://reqres.in/api/users'),
                      body: jsonEncode({
                        'name': 'morpheus',
                        'job': 'leader',
                      }),
                    );
                  } catch (e, st) {
                    print(e);
                    print(st);
                  }
                },
                child: const Text('Http Test'),
              ),
              ElevatedButton(
                onPressed: () async {
                  try {
                    final config = URLSessionConfiguration.ephemeralSessionConfiguration();
                    config.cache = null;
                    final client = CupertinoClient.fromSessionConfiguration(config);
                    await client.post(
                      Uri.parse('https://reqres.in/api/users'),
                      body: {
                        'name': 'morpheus',
                        'job': 'leader',
                      },
                    );
                  } catch (e, st) {
                    print(e);
                    print(st);
                  }
                },
                child: const Text('Cupertino Test'),
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
