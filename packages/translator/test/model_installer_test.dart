/*
 * Copyright (C) 2020. by perol_notsf, All rights reserved
 *
 * This program is free software: you can redistribute it and/or modify it under
 * the terms of the GNU General Public License as published by the Free Software
 * Foundation, either version 3 of the License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful, but WITHOUT ANY
 * WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
 * FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License along with
 * this program. If not, see <http://www.gnu.org/licenses/>.
 *
 */

/// 下载 URL 安全校验的边界测试（validateDownloadUrl），
/// 以及可注入下载通道（DownloadChannel）的续传 / 取消行为测试。
library;

import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:translator/src/model/model_installer.dart';
import 'package:test/test.dart';

bool _rejected(String url) {
  try {
    ModelInstaller.validateDownloadUrl(url);
    return false;
  } on ModelInstallException {
    return true;
  }
}

/// 可编程的假下载通道：记录请求头，按脚本返回数据块 / 中途取消 / open 即取消。
class _FakeChannel implements DownloadChannel {
  final int statusCode;

  /// 响应体数据块。
  final List<Uint8List> chunks;

  /// open 阶段直接抛出的错误（如 [ModelDownloadCancelled]）。
  final Object? openError;

  /// >= 0 时在发出第 N 个块后向流中注入取消错误。
  final int cancelAfterChunks;
  final List<Map<String, String>?> seenHeaders = [];

  _FakeChannel({
    this.statusCode = 200,
    this.chunks = const [],
    this.openError,
    this.cancelAfterChunks = -1,
  });

  @override
  Future<DownloadResponse> open(
    String url, {
    Map<String, String>? headers,
  }) async {
    seenHeaders.add(headers);
    if (openError != null) throw openError!;
    final Stream<List<int>> stream;
    if (cancelAfterChunks >= 0 && cancelAfterChunks < chunks.length) {
      final controller = StreamController<List<int>>();
      for (var i = 0; i <= cancelAfterChunks; i++) {
        controller.add(chunks[i]);
      }
      controller.addError(ModelDownloadCancelled());
      controller.close();
      stream = controller.stream;
    } else {
      stream = Stream<List<int>>.fromIterable(chunks);
    }
    return DownloadResponse(
      statusCode: statusCode,
      headers: const {},
      stream: stream,
    );
  }
}

/// 构造可通过校验的 GGUF 假内容：magic 头 + 补足到 4MiB 下限之上。
Uint8List _ggufPayload({int extra = 16}) {
  final bytes = Uint8List(4 * 1024 * 1024 + extra);
  bytes[0] = 0x47; // G
  bytes[1] = 0x47; // G
  bytes[2] = 0x55; // U
  bytes[3] = 0x46; // F
  return bytes;
}

void main() {
  group('validateDownloadUrl 放行', () {
    test('https 公网域名', () {
      expect(_rejected(ModelSpec.hyMt2.modelScopeUrl), isFalse);
      expect(_rejected(ModelSpec.hyMt2.hfUrl), isFalse);
      expect(_rejected(ModelSpec.hyMt2.mirrorUrl), isFalse);
      expect(_rejected(ModelSpec.hyMt2.mirrorNetUrl), isFalse);
    });
    test('http 协议与公网 IPv4', () {
      expect(_rejected('http://example.com/model.gguf'), isFalse);
      expect(_rejected('https://8.8.8.8/model.gguf'), isFalse);
    });
  });

  group('validateDownloadUrl 拒绝', () {
    test('非 http/https 协议与畸形 URL', () {
      expect(_rejected('ftp://example.com/model.gguf'), isTrue);
      expect(_rejected('file:///etc/passwd'), isTrue);
      expect(_rejected('https:///no-host.gguf'), isTrue);
      expect(_rejected('not a url'), isTrue);
    });
    test('localhost 与环回', () {
      expect(_rejected('http://localhost/model.gguf'), isTrue);
      expect(_rejected('http://sub.localhost/model.gguf'), isTrue);
      expect(_rejected('http://127.0.0.1/model.gguf'), isTrue);
      expect(_rejected('http://[::1]/model.gguf'), isTrue);
      expect(_rejected('http://[::]/model.gguf'), isTrue);
    });
    test('IPv4 私有 / 保留网段', () {
      expect(_rejected('http://10.0.0.1/model.gguf'), isTrue);
      expect(_rejected('http://192.168.1.1/model.gguf'), isTrue);
      expect(_rejected('http://172.16.0.1/model.gguf'), isTrue);
      expect(_rejected('http://172.31.255.255/model.gguf'), isTrue);
      expect(_rejected('http://169.254.1.1/model.gguf'), isTrue);
      expect(_rejected('http://100.64.0.1/model.gguf'), isTrue);
      expect(_rejected('http://0.0.0.0/model.gguf'), isTrue);
      expect(_rejected('http://224.0.0.1/model.gguf'), isTrue);
      expect(_rejected('http://192.0.2.1/model.gguf'), isTrue); // TEST-NET-1
      // 172.15 与 172.32 在私有段之外，应放行
      expect(_rejected('http://172.15.0.1/model.gguf'), isFalse);
      expect(_rejected('http://172.32.0.1/model.gguf'), isFalse);
    });
    test('IPv6 链路本地 / ULA / IPv4 映射', () {
      expect(_rejected('http://[fe80::1]/model.gguf'), isTrue);
      expect(_rejected('http://[fd00::1]/model.gguf'), isTrue);
      expect(_rejected('http://[::ffff:127.0.0.1]/model.gguf'), isTrue);
    });
  });

  group('DownloadChannel 注入下载', () {
    late Directory tmpDir;
    const declaredSize = 5 * 1024 * 1024; // 校验下限 = 4 MiB

    setUp(() {
      tmpDir = Directory.systemTemp.createTempSync('installer_test');
    });
    tearDown(() {
      tmpDir.deleteSync(recursive: true);
    });

    test('通道 200 全量下载成功并完成 GGUF 校验', () async {
      final savePath =
          '${tmpDir.path}${Platform.pathSeparator}model.gguf';
      final payload = _ggufPayload();
      final installer = ModelInstaller();
      final states = await installer
          .download(
            url: 'https://example.com/model.gguf',
            savePath: savePath,
            declaredSize: declaredSize,
            channel: _FakeChannel(chunks: [payload]),
          )
          .toList();
      // 完成帧以 total（此处无 Content-Length，回落 declaredSize）上报
      expect(states.last.downloaded, declaredSize);
      expect(states.last.total, declaredSize);
      expect(File(savePath).existsSync(), isTrue);
      expect(await installer.verify(savePath, declaredSize), isTrue);
      expect(File('$savePath.tmp').existsSync(), isFalse);
    });

    test('.tmp 续传：携带 Range 头，206 追加剩余数据', () async {
      final savePath =
          '${tmpDir.path}${Platform.pathSeparator}model.gguf';
      final payload = _ggufPayload();
      final head = payload.sublist(0, 1024 * 1024);
      final tail = payload.sublist(1024 * 1024);
      File('$savePath.tmp').writeAsBytesSync(head); // 上次已下载 1MiB
      final channel = _FakeChannel(statusCode: 206, chunks: [tail]);
      await ModelInstaller()
          .download(
            url: 'https://example.com/model.gguf',
            savePath: savePath,
            declaredSize: declaredSize,
            channel: channel,
          )
          .drain();
      expect(channel.seenHeaders.single?['range'], 'bytes=${head.length}-');
      expect(await ModelInstaller().verify(savePath, declaredSize), isTrue);
    });

    test('流中途取消：抛出「已取消」且 .tmp 保留已写进度', () async {
      final savePath =
          '${tmpDir.path}${Platform.pathSeparator}model.gguf';
      final payload = _ggufPayload();
      final first = payload.sublist(0, 1024 * 1024);
      final channel = _FakeChannel(
        chunks: [first, payload.sublist(1024 * 1024)],
        cancelAfterChunks: 0, // 第一块后取消
      );
      await expectLater(
        ModelInstaller()
            .download(
              url: 'https://example.com/model.gguf',
              savePath: savePath,
              declaredSize: declaredSize,
              channel: channel,
            )
            .drain(),
        throwsA(
          isA<ModelInstallException>().having(
            (e) => e.message,
            'message',
            contains('已取消'),
          ),
        ),
      );
      expect(File('$savePath.tmp').lengthSync(), first.length);
    });

    test('open 阶段取消：抛出「已取消」', () async {
      final savePath =
          '${tmpDir.path}${Platform.pathSeparator}model.gguf';
      await expectLater(
        ModelInstaller()
            .download(
              url: 'https://example.com/model.gguf',
              savePath: savePath,
              declaredSize: declaredSize,
              channel: _FakeChannel(openError: ModelDownloadCancelled()),
            )
            .drain(),
        throwsA(
          isA<ModelInstallException>().having(
            (e) => e.message,
            'message',
            contains('已取消'),
          ),
        ),
      );
    });
  });
}
