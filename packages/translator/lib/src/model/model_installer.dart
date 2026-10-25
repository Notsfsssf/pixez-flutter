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

/// 模型下载 / 校验 / 删除（对齐参考 LlmModelInstaller.kt 的校验语义，规格 §9）。
///
/// 仅依赖 dart:io + dio：路径由 app 侧注入；不支持 web。
library;

import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';

/// 模型清单（规格 §9.1）。
class ModelSpec {
  final String repo;
  final String fileName;
  final int sizeBytes;
  final String hfUrl;
  final String mirrorUrl;

  /// hf-mirror.net 镜像（2026-10 实测 hf-mirror.com 连接超时，此域名可用）。
  final String mirrorNetUrl;

  /// ModelScope（魔搭）直链：`/resolve/master/` 为其默认分支。
  final String modelScopeUrl;

  const ModelSpec({
    required this.repo,
    required this.fileName,
    required this.sizeBytes,
    required this.hfUrl,
    required this.mirrorUrl,
    required this.mirrorNetUrl,
    required this.modelScopeUrl,
  });

  static const hyMt2 = ModelSpec(
    repo: 'tencent/Hy-MT2-1.8B-GGUF',
    fileName: 'Hy-MT2-1.8B-Q4_K_M.gguf',
    sizeBytes: 1133080448,
    hfUrl:
        'https://huggingface.co/tencent/Hy-MT2-1.8B-GGUF/resolve/main/Hy-MT2-1.8B-Q4_K_M.gguf',
    mirrorUrl:
        'https://hf-mirror.com/tencent/Hy-MT2-1.8B-GGUF/resolve/main/Hy-MT2-1.8B-Q4_K_M.gguf',
    mirrorNetUrl:
        'https://hf-mirror.net/tencent/Hy-MT2-1.8B-GGUF/resolve/main/Hy-MT2-1.8B-Q4_K_M.gguf',
    modelScopeUrl:
        'https://modelscope.cn/models/tencent/Hy-MT2-1.8B-GGUF/resolve/master/Hy-MT2-1.8B-Q4_K_M.gguf',
  );
}

/// 下载进度（节流 1MiB 上报）。
class ModelDownloadProgress {
  final int downloaded;
  final int total;
  final int speedBps;

  const ModelDownloadProgress({
    required this.downloaded,
    required this.total,
    required this.speedBps,
  });
}

/// 下载 / 校验错误。
class ModelInstallException implements Exception {
  final String message;

  ModelInstallException(this.message);

  @override
  String toString() => 'ModelInstallException: $message';
}

/// 用户主动取消（区别于失败：`.tmp` 有意保留，UI 不当作错误提示）。
class ModelInstallCancelledException extends ModelInstallException {
  ModelInstallCancelledException() : super('已取消（进度保留，可续传）');
}

/// 用户主动取消下载（通道内部抛出，安装器据此保留 `.tmp`）。
class ModelDownloadCancelled implements Exception {}

/// 一次下载请求的响应：状态码、响应头与正文字节流。
class DownloadResponse {
  final int statusCode;

  /// 大小写不敏感地取值时用 [_headerOf] 辅助。
  final Map<String, List<String>> headers;
  final Stream<List<int>> stream;

  const DownloadResponse({
    required this.statusCode,
    required this.headers,
    required this.stream,
  });
}

/// 下载通道抽象：默认 [DioDownloadChannel] 走 dio（系统网络栈）；
/// 宿主 app 可注入其它实现（如 rhttp 直连通道）以接管网络层。
abstract class DownloadChannel {
  /// 发起 GET 请求。取消时抛 [ModelDownloadCancelled]（含流消费过程中）。
  Future<DownloadResponse> open(
    String url, {
    Map<String, String>? headers,
  });
}

/// dio 实现的下载通道（默认）。
class DioDownloadChannel implements DownloadChannel {
  final Dio dio;
  final CancelToken? cancelToken;

  DioDownloadChannel({required this.dio, this.cancelToken});

  @override
  Future<DownloadResponse> open(
    String url, {
    Map<String, String>? headers,
  }) async {
    final Response<ResponseBody> response;
    try {
      response = await dio.get<ResponseBody>(
        url,
        options: Options(responseType: ResponseType.stream, headers: headers),
        cancelToken: cancelToken,
      );
    } on DioException catch (e) {
      if (e.type == DioExceptionType.cancel) throw ModelDownloadCancelled();
      rethrow;
    }
    return DownloadResponse(
      statusCode: response.statusCode ?? 0,
      headers: response.headers.map,
      // dio 在取消时向响应流注入 DioException(cancel)，统一转为
      // [ModelDownloadCancelled]，让安装器对取消的处理与通道无关。
      stream: response.data!.stream.transform(
        StreamTransformer.fromHandlers(
          handleError: (error, stackTrace, sink) {
            if (error is DioException && error.type == DioExceptionType.cancel) {
              sink.addError(ModelDownloadCancelled());
              return;
            }
            sink.addError(error, stackTrace);
          },
        ),
      ),
    );
  }
}

/// 大小写不敏感地取响应头首个值。
String? headerOf(Map<String, List<String>> headers, String name) {
  for (final entry in headers.entries) {
    if (entry.key.toLowerCase() == name && entry.value.isNotEmpty) {
      return entry.value.first;
    }
  }
  return null;
}

/// 模型安装器。
class ModelInstaller {
  final Dio dio;

  /// 校验下限：max(4 MiB, 标称体积 × 80%)（规格 §9.2）。
  static int minValidBytes(int declaredSize) {
    const fourMiB = 4 * 1024 * 1024;
    final eightyPercent = (declaredSize * 0.8).floor();
    return fourMiB > eightyPercent ? fourMiB : eightyPercent;
  }

  ModelInstaller({Dio? dio})
    : dio = dio ?? Dio(BaseOptions(followRedirects: true, maxRedirects: 8));

  String tmpPathFor(String savePath) => '$savePath.tmp';

  /// 下载 URL 安全校验：仅允许 http/https，且 host 不得为
  /// localhost / 环回 / 私有网段 / 链路本地 / 保留地址（含自定义镜像）。
  static void validateDownloadUrl(String raw) {
    final uri = Uri.tryParse(raw.trim());
    if (uri == null ||
        (uri.scheme != 'https' && uri.scheme != 'http') ||
        uri.host.isEmpty) {
      throw ModelInstallException('下载地址不合法：仅支持 http/https URL');
    }
    if (_isRestrictedHost(uri.host)) {
      throw ModelInstallException('下载地址被拒绝：不允许 localhost / 内网 / 保留地址');
    }
  }

  /// 是否为受限 host（localhost / 环回 / 私有 / 链路本地 / 保留地址）。
  /// 公开给宿主复用：如校验 DNS 解析结果的实际连接 IP。
  static bool isRestrictedHost(String host) => _isRestrictedHost(host);

  static bool _isRestrictedHost(String host) {
    final h = host.toLowerCase();
    if (h == 'localhost' || h.endsWith('.localhost')) return true;
    final v4 = RegExp(
      r'^(\d{1,3})\.(\d{1,3})\.(\d{1,3})\.(\d{1,3})$',
    ).firstMatch(h);
    if (v4 != null) {
      final o = [
        for (var i = 1; i <= 4; i++) int.parse(v4.group(i)!),
      ];
      if (o.any((v) => v > 255)) return true;
      final a = o[0], b = o[1], c = o[2];
      return a == 0 || // 0.0.0.0/8（含未指定地址）
          a == 10 || // 私有
          a == 127 || // 环回
          (a == 100 && b >= 64 && b <= 127) || // CGNAT
          (a == 169 && b == 254) || // 链路本地
          (a == 172 && b >= 16 && b <= 31) || // 私有
          (a == 192 && b == 0) || // 192.0.0.0/24 与 TEST-NET-1
          (a == 192 && b == 168) || // 私有
          (a == 198 && (b == 18 || b == 19)) || // 基准测试
          (a == 198 && b == 51 && c >= 100) || // TEST-NET-2
          (a == 203 && b == 0 && c == 113) || // TEST-NET-3
          a >= 224; // 组播 / 广播 / 保留
    }
    if (h.contains(':')) {
      // IPv6（Uri.host 不含方括号）
      if (h.contains('::ffff:')) return true; // IPv4 映射地址一律拒绝
      return h == '::' ||
          h == '::1' || // 未指定 / 环回
          RegExp(r'^fe[89ab]').hasMatch(h) || // 链路本地 fe80::/10
          RegExp(r'^f[cd]').hasMatch(h); // ULA fc00::/7
    }
    return false;
  }

  /// 确保 savePath 的父目录存在（Dart 的 openSync/copy 不会自动创建父目录，
  /// 否则首次下载在 `<documents>/models/llm/` 上抛 PathNotFoundException）。
  void _ensureParentDir(String savePath) {
    final parent = Directory(File(savePath).parent.path);
    if (!parent.existsSync()) parent.createSync(recursive: true);
  }

  /// 文件是否为有效 GGUF：前 4 字节 magic + 长度下限。
  Future<bool> verify(String path, int declaredSize) async {
    final file = File(path);
    if (!file.existsSync()) return false;
    final length = file.lengthSync();
    if (length < minValidBytes(declaredSize)) return false;
    final raf = file.openSync();
    try {
      final magic = raf.readSync(4);
      return magic.length == 4 &&
          magic[0] == 0x47 && // G
          magic[1] == 0x47 && // G
          magic[2] == 0x55 && // U
          magic[3] == 0x46; // F
    } finally {
      await raf.close();
    }
  }

  /// 已安装且校验通过时返回正式路径，否则 null。
  Future<String?> checkInstalled(String savePath, int declaredSize) async {
    final file = File(savePath);
    if (file.existsSync() && await verify(savePath, declaredSize)) {
      return savePath;
    }
    return null;
  }

  /// 断点续传下载。
  ///
  /// - `.tmp` 存在则 `Range: bytes={tmpLen}-`；206 追加写，200 覆盖写；
  /// - 进度节流 1MiB；取消后保留 `.tmp`；
  /// - 完成后校验（GGUF magic + 体积下限），通过 rename 为正式文件，
  ///   失败删除 `.tmp` 并抛 [ModelInstallException]；
  /// - [channel] 非空时由其接管 HTTP（宿主注入的直连通道），
  ///   为空时用自带的 dio。取消统一以 [ModelDownloadCancelled] 识别。
  Stream<ModelDownloadProgress> download({
    required String url,
    required String savePath,
    required int declaredSize,
    CancelToken? cancelToken,
    DownloadChannel? channel,
  }) async* {
    validateDownloadUrl(url);
    final tmpFile = File(tmpPathFor(savePath));
    _ensureParentDir(savePath);
    int tmpLen = 0;
    if (tmpFile.existsSync()) tmpLen = tmpFile.lengthSync();

    final effectiveChannel =
        channel ?? DioDownloadChannel(dio: dio, cancelToken: cancelToken);
    final DownloadResponse response;
    try {
      response = await effectiveChannel.open(
        url,
        headers: tmpLen > 0 ? {'range': 'bytes=$tmpLen-'} : null,
      );
    } on ModelDownloadCancelled {
      throw ModelInstallCancelledException();
    }
    final status = response.statusCode;
    final resumeAccepted = status == 206;
    if (status != 200 && status != 206) {
      throw ModelInstallException('下载失败（HTTP $status）');
    }

    // 优先用响应的 Content-Range / Content-Length 推总大小。
    int total = declaredSize;
    final contentRange = headerOf(response.headers, 'content-range');
    if (contentRange != null) {
      final match = RegExp(r'/(\d+)$').firstMatch(contentRange);
      if (match != null) total = int.parse(match.group(1)!);
    } else {
      final contentLength = headerOf(response.headers, 'content-length');
      if (contentLength != null) {
        total = resumeAccepted
            ? tmpLen + int.parse(contentLength)
            : int.parse(contentLength);
      }
    }

    final raf = tmpFile.openSync(
      mode: resumeAccepted ? FileMode.append : FileMode.write,
    );
    var downloaded = resumeAccepted ? tmpLen : 0;
    var lastReport = 0;
    var lastReportAt = DateTime.now().millisecondsSinceEpoch;
    var lastReportBytes = 0;
    int speedBps = 0;
    try {
      await for (final chunk in response.stream) {
        raf.writeFromSync(chunk);
        downloaded += chunk.length;
        final now = DateTime.now().millisecondsSinceEpoch;
        if (downloaded - lastReport >= 1 * 1024 * 1024) {
          final dt = now - lastReportAt;
          if (dt > 0) {
            speedBps = ((downloaded - lastReportBytes) * 1000 / dt).round();
          }
          lastReport = downloaded;
          lastReportAt = now;
          lastReportBytes = downloaded;
          yield ModelDownloadProgress(
            downloaded: downloaded,
            total: total,
            speedBps: speedBps,
          );
        }
      }
    } on ModelDownloadCancelled {
      // 取消：保留 .tmp 以便续传
      throw ModelInstallCancelledException();
    } finally {
      await raf.close();
    }

    // 完成校验
    if (!await verify(tmpFile.path, declaredSize)) {
      try {
        tmpFile.deleteSync();
      } catch (_) {}
      throw ModelInstallException('校验失败：文件损坏或被截断，已清理临时文件');
    }
    tmpFile.renameSync(savePath);
    yield ModelDownloadProgress(
      downloaded: total,
      total: total,
      speedBps: speedBps,
    );
  }

  /// 删除正式文件与 `.tmp`。
  Future<void> delete(String savePath) async {
    for (final path in [savePath, tmpPathFor(savePath)]) {
      final file = File(path);
      if (file.existsSync()) {
        try {
          file.deleteSync();
        } catch (_) {}
      }
    }
  }

  /// 本地导入：复制到模型目录 → 同一校验。
  Future<void> importLocal(
    String sourcePath,
    String savePath,
    int declaredSize,
  ) async {
    final source = File(sourcePath);
    if (!source.existsSync()) throw ModelInstallException('所选文件不存在');
    _ensureParentDir(savePath);
    final tmp = File(tmpPathFor(savePath));
    await source.copy(tmp.path);
    if (!await verify(tmp.path, declaredSize)) {
      try {
        tmp.deleteSync();
      } catch (_) {}
      throw ModelInstallException('校验失败：所选文件不是有效的 GGUF 或体积不符');
    }
    tmp.renameSync(savePath);
  }
}
