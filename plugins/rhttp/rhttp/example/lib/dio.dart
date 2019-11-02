import 'package:dio/dio.dart';
import 'package:dio_compatibility_layer/dio_compatibility_layer.dart';
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
  Dio? _client;
  Response? response;

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
                  _client ??= await _createDioClient();

                  final res = await _client!.getUri(
                    Uri.https('tienisto.com'),
                  );
                  setState(() {
                    response = res;
                  });
                },
                child: const Text('Test'),
              ),
              if (response != null) Text(response!.statusCode.toString()),
              if (response != null)
                Card(
                  child: Text(response!.data.substring(0, 100).toString()),
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

Future<Dio> _createDioClient() async {
  final dio = Dio();
  final compatibleClient = await RhttpCompatibleClient.create();
  dio.httpClientAdapter = ConversionLayerAdapter(compatibleClient);
  return dio;
}
