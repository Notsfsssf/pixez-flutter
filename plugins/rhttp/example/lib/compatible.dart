// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
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
  http.Client? _client;
  http.Response? response;

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
                    _client ??= await RhttpCompatibleClient.create();

                    final res = await _client!.get(
                      Uri.https('reqres.in', '/apis/users', {'page': '5'}),
                    );
                    setState(() {
                      response = res;
                    });
                  } on RhttpWrappedClientException catch (e) {
                    print(e);
                  }
                },
                child: const Text('Test'),
              ),
              if (response != null) Text(response!.statusCode.toString()),
              if (response != null)
                Card(
                  child: Text(response!.body.substring(0, 100).toString()),
                ),
              if (response != null)
                Card(
                  child: Text(response!.headers.toString()),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
