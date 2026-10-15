import 'dart:convert';
import 'dart:io';

import 'package:archive/archive.dart';
import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pixez/network/api_client.dart';
import 'package:pixez/page/picture/ugoira_store.dart';

const _illustId = 123;
const _pathProviderChannel = MethodChannel('plugins.flutter.io/path_provider');

Map<String, dynamic> _metadata() => jsonDecode(
  jsonEncode({
    'ugoira_metadata': {
      'zip_urls': {'medium': 'https://i.pximg.net/ugoira/$_illustId.zip'},
      'frames': [
        {'file': '000000.jpg', 'delay': 100},
        {'file': '000001.jpg', 'delay': 100},
      ],
    },
  }),
);

void _writeZip(Directory dir) {
  final archive = Archive()
    ..addFile(ArchiveFile('000000.jpg', 3, [1, 2, 3]))
    ..addFile(ArchiveFile('000001.jpg', 3, [4, 5, 6]));
  File(
    '${dir.path}/$_illustId.zip',
  ).writeAsBytesSync(ZipEncoder().encode(archive));
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory tempDir;

  setUp(() {
    tempDir = Directory.systemTemp.createTempSync('ugoira_store_test');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(_pathProviderChannel, (call) async {
          // Platform calls are asynchronous on a real device as well.
          await Future<void>.delayed(const Duration(milliseconds: 20));
          return tempDir.path;
        });
    apiClient.httpClient =
        Dio(BaseOptions(baseUrl: 'https://app-api.pixiv.net'))
          ..interceptors.add(
            InterceptorsWrapper(
              onRequest: (options, handler) {
                handler.resolve(
                  Response(
                    requestOptions: options,
                    statusCode: 200,
                    data: _metadata(),
                  ),
                );
              },
            ),
          );
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(_pathProviderChannel, null);
    tempDir.deleteSync(recursive: true);
  });

  test('downloadAndUnzip completes after the frames are extracted', () async {
    _writeZip(tempDir);
    final store = UgoiraStore(_illustId);

    await store.downloadAndUnzip();

    expect(store.status, UgoiraStatus.play);
    expect(store.ugoiraMetadataResponse, isNotNull);
    expect(
      store.drawPool.map((e) => e.uri.pathSegments.last).toList(),
      ['000000.jpg', '000001.jpg'],
    );
  });
}
