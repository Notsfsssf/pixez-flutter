// ignore_for_file: avoid_print

import 'dart:typed_data';

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
                      'http://localhost:3000/',
                      body: HttpBody.multipart({
                        'name': const MultipartItem.text(
                          text: 'Tom',
                          fileName: 'name.txt',
                        ),
                        'binary': MultipartItem.bytes(
                          bytes: Uint8List.fromList([
                            for (int i = 0; i < 256; i++) i,
                          ]),
                          fileName: 'test.txt',
                        ),
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
                child: const Text('Test'),
              ),
              if (response != null) Text(response!.version.toString()),
              if (response != null) Text(response!.statusCode.toString()),
              if (response != null)
                Text(response!.body.codeUnits.take(100).toString()),
              // if (response != null) Text(response!.headers.toString()),
            ],
          ),
        ),
      ),
    );
  }
}
