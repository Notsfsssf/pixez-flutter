import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/services.dart' show MethodChannel;

class FileServicePlugin {
  static const _safChannel = MethodChannel('com.perol.dev/saf');

  /// 弹窗选择文件并读取其二进制字节。
  ///
  /// - `mimeType`: 筛选的文件 MIME 类型
  /// - `allowedExtensions`: 允许的文件扩展名列表（主要用于桌面端过滤，如 `['json', 'txt']`）。
  ///
  /// 常用 `mimeType` 示例：
  ///
  /// | MIME 类型 | 文件内容 |
  /// | :---: | :---: |
  /// | `application/json` | JSON 数据 |
  /// | `text/plain` | 纯文本数据 (如 TXT 小说) |
  /// | `application/zip` | ZIP 压缩包 |
  /// | `*/*` | 任意类型 (默认) |
  ///
  /// 若用户取消选择或操作失败，则返回 `null`。
  static Future<Uint8List?> pickFileBytes({
    String mimeType = '*/*',
    List<String>? allowedExtensions,
  }) async {
    if (Platform.isAndroid) {
      return _safChannel.invokeMethod<Uint8List>('openFile', {
        'type': mimeType,
      });
    }
    final file = await FilePicker.pickFile(
      type: allowedExtensions == null ? FileType.any : FileType.custom,
      allowedExtensions: allowedExtensions,
    );
    if (file == null) return null;
    return file.readAsBytes();
  }

  /// 弹窗选择保存路径并写入二进制数据.
  ///
  /// - `data` : 待写入的二进制字节.
  /// - `fileName`: 建议的默认文件名.
  /// - `mimeType`: 目标文件的 MIME 类型.
  /// 
  ///   默认为 `application/octet-stream` (通用二进制流).
  static Future<bool> saveFileAs({
    required Uint8List data,
    required String fileName,
    String mimeType = 'application/octet-stream',
  }) async {
    if (Platform.isAndroid) {
      final uri = await _safChannel.invokeMethod<String>('createFile', {
        'name': fileName,
        'mimeType': mimeType,
      });
      if (uri == null) return false;
      await _safChannel.invokeMethod('writeUri', {'uri': uri, 'data': data});
      return true;
    }

    final uri = await FilePicker.saveFile(
      fileName: fileName,
      bytes: data,
      mimeType: mimeType,
    );
    return uri != null;
  }
}
