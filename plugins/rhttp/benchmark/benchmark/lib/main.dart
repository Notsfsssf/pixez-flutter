import 'dart:io';
import 'dart:typed_data';

import 'package:benchmark/benchmark.dart';
import 'package:benchmark/widgets/benchmark_card.dart';
import 'package:benchmark/widgets/benchmark_section.dart';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:http/io_client.dart';
import 'package:rhttp/rhttp.dart';

void main() async {
  await Rhttp.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp();

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Flutter Demo',
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage();

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final benchmarks = <BenchmarkMetadata, BenchmarkState>{};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        children: [
          BenchmarkSection(
            title: 'Download',
            children: [
              [
                BenchmarkCard(
                  benchmark: BenchmarkMetadata.download(
                    library: 'http',
                    tags: const ['small'],
                    downloadType: DownloadType.small,
                    executor: BenchmarkExecutor.downloadBytes(
                      createClient: _createHttpClient,
                      urlEncoder: (url) => Uri.parse(url),
                      runIteration: (client, url) async {
                        final response = await client.get(url);
                        return response.bodyBytes;
                      },
                    ),
                  ),
                  state: benchmarks,
                  rebuild: () => setState(() {}),
                ),
                BenchmarkCard(
                  benchmark: BenchmarkMetadata.download(
                    library: 'http',
                    tags: const ['large'],
                    downloadType: DownloadType.large,
                    executor: BenchmarkExecutor.downloadBytes(
                      createClient: _createHttpClient,
                      urlEncoder: (url) => Uri.parse(url),
                      runIteration: (client, url) async {
                        final response = await client.get(url);
                        return response.bodyBytes;
                      },
                    ),
                  ),
                  state: benchmarks,
                  rebuild: () => setState(() {}),
                ),
                BenchmarkCard(
                  benchmark: BenchmarkMetadata.download(
                    library: 'http',
                    tags: const ['large', 'stream'],
                    downloadType: DownloadType.large,
                    executor: BenchmarkExecutor.downloadStream(
                      createClient: _createHttpClient,
                      urlEncoder: (url) => Uri.parse(url),
                      runIteration: (client, url) async {
                        final response = await client.send(Request('GET', url));
                        return response.stream;
                      },
                    ),
                  ),
                  state: benchmarks,
                  rebuild: () => setState(() {}),
                ),
              ],
              [
                BenchmarkCard(
                  benchmark: BenchmarkMetadata.download(
                    library: 'dio',
                    tags: const ['small'],
                    downloadType: DownloadType.small,
                    executor: BenchmarkExecutor.downloadBytes(
                      createClient: _createDioClient,
                      urlEncoder: (url) => Uri.parse(url),
                      runIteration: (client, url) async {
                        final response = await client.getUri(
                          url,
                          options: Options(responseType: ResponseType.bytes),
                        );
                        return response.data;
                      },
                    ),
                  ),
                  state: benchmarks,
                  rebuild: () => setState(() {}),
                ),
                BenchmarkCard(
                  benchmark: BenchmarkMetadata.download(
                    library: 'dio',
                    tags: const ['large'],
                    downloadType: DownloadType.large,
                    executor: BenchmarkExecutor.downloadBytes(
                      createClient: _createDioClient,
                      urlEncoder: (url) => Uri.parse(url),
                      runIteration: (client, url) async {
                        final response = await client.getUri(
                          url,
                          options: Options(responseType: ResponseType.bytes),
                        );
                        return response.data;
                      },
                    ),
                  ),
                  state: benchmarks,
                  rebuild: () => setState(() {}),
                ),
                BenchmarkCard(
                  benchmark: BenchmarkMetadata.download(
                    library: 'dio',
                    tags: const ['large', 'progress'],
                    downloadType: DownloadType.large,
                    executor: BenchmarkExecutor.downloadBytes(
                      createClient: _createDioClient,
                      urlEncoder: (url) => Uri.parse(url),
                      runIteration: (client, url) async {
                        final response = await client.getUri(
                          url,
                          options: Options(responseType: ResponseType.bytes),
                          onReceiveProgress: (received, total) {},
                        );
                        return response.data;
                      },
                    ),
                  ),
                  state: benchmarks,
                  rebuild: () => setState(() {}),
                ),
                BenchmarkCard(
                  benchmark: BenchmarkMetadata.download(
                    library: 'dio',
                    tags: const ['large', 'stream'],
                    downloadType: DownloadType.large,
                    executor: BenchmarkExecutor.downloadStream(
                      createClient: _createDioClient,
                      urlEncoder: (url) => Uri.parse(url),
                      runIteration: (client, url) async {
                        final response = await client.getUri(
                          url,
                          options: Options(responseType: ResponseType.stream),
                        );
                        return (response.data as ResponseBody).stream;
                      },
                    ),
                  ),
                  state: benchmarks,
                  rebuild: () => setState(() {}),
                ),
                BenchmarkCard(
                  benchmark: BenchmarkMetadata.download(
                    library: 'dio',
                    tags: const ['large', 'stream', 'progress'],
                    downloadType: DownloadType.large,
                    executor: BenchmarkExecutor.downloadStream(
                      createClient: _createDioClient,
                      urlEncoder: (url) => Uri.parse(url),
                      runIteration: (client, url) async {
                        final response = await client.getUri(
                          url,
                          options: Options(responseType: ResponseType.stream),
                          onReceiveProgress: (received, total) {},
                        );
                        return (response.data as ResponseBody).stream;
                      },
                    ),
                  ),
                  state: benchmarks,
                  rebuild: () => setState(() {}),
                ),
              ],
              [
                BenchmarkCard(
                  benchmark: BenchmarkMetadata.download(
                    library: 'rhttp',
                    tags: const ['small'],
                    downloadType: DownloadType.small,
                    executor: BenchmarkExecutor.downloadBytes(
                      createClient: _createRhttpClient,
                      urlEncoder: (url) => url,
                      runIteration: (client, url) async {
                        final response = await client.getBytes(url);
                        return response.body;
                      },
                    ),
                  ),
                  state: benchmarks,
                  rebuild: () => setState(() {}),
                ),
                BenchmarkCard(
                  benchmark: BenchmarkMetadata.download(
                    library: 'rhttp',
                    tags: const ['large'],
                    downloadType: DownloadType.large,
                    executor: BenchmarkExecutor.downloadBytes(
                      createClient: _createRhttpClient,
                      urlEncoder: (url) => url,
                      runIteration: (client, url) async {
                        final response = await client.getBytes(url);
                        return response.body;
                      },
                    ),
                  ),
                  state: benchmarks,
                  rebuild: () => setState(() {}),
                ),
                BenchmarkCard(
                  benchmark: BenchmarkMetadata.download(
                    library: 'rhttp',
                    tags: const ['large', 'progress'],
                    downloadType: DownloadType.large,
                    executor: BenchmarkExecutor.downloadBytes(
                      createClient: _createRhttpClient,
                      urlEncoder: (url) => url,
                      runIteration: (client, url) async {
                        final response = await client.getBytes(
                          url,
                          onReceiveProgress: (received, total) {},
                        );
                        return response.body;
                      },
                    ),
                  ),
                  state: benchmarks,
                  rebuild: () => setState(() {}),
                ),
                BenchmarkCard(
                  benchmark: BenchmarkMetadata.download(
                    library: 'rhttp',
                    tags: const ['large', 'stream'],
                    downloadType: DownloadType.large,
                    executor: BenchmarkExecutor.downloadStream(
                      createClient: _createRhttpClient,
                      urlEncoder: (url) => url,
                      runIteration: (client, url) async {
                        final response = await client.getStream(url);
                        return response.body;
                      },
                    ),
                  ),
                  state: benchmarks,
                  rebuild: () => setState(() {}),
                ),
                BenchmarkCard(
                  benchmark: BenchmarkMetadata.download(
                    library: 'rhttp',
                    tags: const ['large', 'stream', 'progress'],
                    downloadType: DownloadType.large,
                    executor: BenchmarkExecutor.downloadStream(
                      createClient: _createRhttpClient,
                      urlEncoder: (url) => url,
                      runIteration: (client, url) async {
                        final response = await client.getStream(
                          url,
                          onReceiveProgress: (received, total) {},
                        );
                        return response.body;
                      },
                    ),
                  ),
                  state: benchmarks,
                  rebuild: () => setState(() {}),
                ),
              ],
            ],
          ),
          BenchmarkSection(
            title: 'Upload',
            children: [
              [
                BenchmarkCard(
                  benchmark: BenchmarkMetadata.upload(
                    library: 'http',
                    tags: const ['large'],
                    executor: BenchmarkExecutor.upload(
                      createClient: _createHttpClient,
                      urlEncoder: (url) => Uri.parse(url),
                      runIteration: (client, url) async {
                        final response = await client.post(url, body: _tenMb);
                        return response.body;
                      },
                    ),
                  ),
                  state: benchmarks,
                  rebuild: () => setState(() {}),
                ),
                BenchmarkCard(
                  benchmark: BenchmarkMetadata.upload(
                    library: 'http',
                    tags: const ['large', 'stream'],
                    executor: BenchmarkExecutor.upload(
                      createClient: _createHttpClient,
                      urlEncoder: (url) => Uri.parse(url),
                      runIteration: (client, url) async {
                        final request = StreamedRequest('POST', url);
                        request.contentLength = _tenMb.length;
                        _generateStream().listen(
                          request.sink.add,
                          onDone: request.sink.close,
                        );
                        final response = await client.send(request);
                        return response.stream.bytesToString();
                      },
                    ),
                  ),
                  state: benchmarks,
                  rebuild: () => setState(() {}),
                ),
              ],
              [
                BenchmarkCard(
                  benchmark: BenchmarkMetadata.upload(
                    library: 'dio',
                    tags: const ['large'],
                    executor: BenchmarkExecutor.upload(
                      createClient: _createDioClient,
                      urlEncoder: (url) => Uri.parse(url),
                      runIteration: (client, url) async {
                        final response = await client.postUri(
                          url,
                          options: Options(
                            contentType: 'application/octet-stream',
                          ),
                          data: _tenMb,
                        );
                        return response.data;
                      },
                    ),
                  ),
                  state: benchmarks,
                  rebuild: () => setState(() {}),
                ),
                BenchmarkCard(
                  benchmark: BenchmarkMetadata.upload(
                    library: 'dio',
                    tags: const ['large', 'progress'],
                    executor: BenchmarkExecutor.upload(
                      createClient: _createDioClient,
                      urlEncoder: (url) => Uri.parse(url),
                      runIteration: (client, url) async {
                        final response = await client.postUri(
                          url,
                          options: Options(
                            contentType: 'application/octet-stream',
                          ),
                          data: _tenMb,
                          onSendProgress: (sent, total) {},
                        );
                        return response.data;
                      },
                    ),
                  ),
                  state: benchmarks,
                  rebuild: () => setState(() {}),
                ),
                BenchmarkCard(
                  benchmark: BenchmarkMetadata.upload(
                    library: 'dio',
                    tags: const ['large', 'stream'],
                    executor: BenchmarkExecutor.upload(
                      createClient: _createDioClient,
                      urlEncoder: (url) => Uri.parse(url),
                      runIteration: (client, url) async {
                        final response = await client.postUri(
                          url,
                          options: Options(
                            contentType: 'application/octet-stream',
                          ),
                          data: _generateStream(),
                        );
                        return response.data;
                      },
                    ),
                  ),
                  state: benchmarks,
                  rebuild: () => setState(() {}),
                ),
                BenchmarkCard(
                  benchmark: BenchmarkMetadata.upload(
                    library: 'dio',
                    tags: const ['large', 'stream', 'progress'],
                    executor: BenchmarkExecutor.upload(
                      createClient: _createDioClient,
                      urlEncoder: (url) => Uri.parse(url),
                      runIteration: (client, url) async {
                        final response = await client.postUri(
                          url,
                          options: Options(
                            contentType: 'application/octet-stream',
                          ),
                          data: _generateStream(),
                          onSendProgress: (sent, total) {},
                        );
                        return response.data;
                      },
                    ),
                  ),
                  state: benchmarks,
                  rebuild: () => setState(() {}),
                ),
              ],
              [
                BenchmarkCard(
                  benchmark: BenchmarkMetadata.upload(
                    library: 'rhttp',
                    tags: const ['large'],
                    executor: BenchmarkExecutor.upload(
                      createClient: _createRhttpClient,
                      urlEncoder: (url) => url,
                      runIteration: (client, url) async {
                        final response = await client.post(
                          url,
                          body: HttpBody.bytes(_tenMb),
                        );
                        return response.body;
                      },
                    ),
                  ),
                  state: benchmarks,
                  rebuild: () => setState(() {}),
                ),
                BenchmarkCard(
                  benchmark: BenchmarkMetadata.upload(
                    library: 'rhttp',
                    tags: const ['large', 'progress'],
                    executor: BenchmarkExecutor.upload(
                      createClient: _createRhttpClient,
                      urlEncoder: (url) => url,
                      runIteration: (client, url) async {
                        final response = await client.post(
                          url,
                          body: HttpBody.bytes(_tenMb),
                          onSendProgress: (sent, total) {},
                        );
                        return response.body;
                      },
                    ),
                  ),
                  state: benchmarks,
                  rebuild: () => setState(() {}),
                ),
                BenchmarkCard(
                  benchmark: BenchmarkMetadata.upload(
                    library: 'rhttp',
                    tags: const ['large', 'stream'],
                    executor: BenchmarkExecutor.upload(
                      createClient: _createRhttpClient,
                      urlEncoder: (url) => url,
                      runIteration: (client, url) async {
                        final response = await client.post(
                          url,
                          body: HttpBody.stream(_generateStream()),
                        );
                        return response.body;
                      },
                    ),
                  ),
                  state: benchmarks,
                  rebuild: () => setState(() {}),
                ),
                BenchmarkCard(
                  benchmark: BenchmarkMetadata.upload(
                    library: 'rhttp',
                    tags: const ['large', 'stream', 'progress'],
                    executor: BenchmarkExecutor.upload(
                      createClient: _createRhttpClient,
                      urlEncoder: (url) => url,
                      runIteration: (client, url) async {
                        final response = await client.post(
                          url,
                          body: HttpBody.stream(_generateStream()),
                          onSendProgress: (sent, total) {},
                        );
                        return response.body;
                      },
                    ),
                  ),
                  state: benchmarks,
                  rebuild: () => setState(() {}),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

Future<IOClient> _createHttpClient() async {
  return IOClient(
    HttpClient()..badCertificateCallback = (_, __, ___) => true,
  );
}

Future<Dio> _createDioClient() async {
  final dio = Dio();
  dio.httpClientAdapter = IOHttpClientAdapter(
    createHttpClient: () {
      final client = HttpClient();
      client.badCertificateCallback = (cert, host, port) => true;
      return client;
    },
  );
  return dio;
}

Future<RhttpClient> _createRhttpClient() async {
  return await RhttpClient.create(
    settings: ClientSettings(
      tlsSettings: TlsSettings(
        verifyCertificates: false,
      ),
    ),
  );
}

final _oneKb = Uint8List(1024);

final _tenMb = Uint8List(1024 * 1024 * 10);

Stream<List<int>> _generateStream() async* {
  for (var i = 0; i < _tenMb.length; i += _oneKb.length) {
    yield _oneKb;
  }
}
