import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/services.dart';

class SAFPlugin {
  static const platform = const MethodChannel('com.perol.dev/saf');

  static Future<String?> createFile(String name, String type) async {
    final result = await platform.invokeMethod("createFile", {
      'name': name,
      'mimeType': type,
    });
    if (result != null) {
      return result;
    }
    return null;
  }

  static Future<void> writeUri(String uri, Uint8List data) async {
    return platform.invokeMethod("writeUri", {'uri': uri, 'data': data});
  }

  /// 直接写入公共下载目录（Download/<relativePath>/name），不弹系统另存为对话框。
  /// 仅 Android 10+ 支持，低版本或失败时返回 null，由调用方回退到 createFile。
  static Future<String?> saveToDownloads(
    String name,
    String mimeType,
    String text, {
    String relativePath = 'PixEz',
  }) async {
    try {
      return await platform.invokeMethod<String>("saveToDownloads", {
        'name': name,
        'mimeType': mimeType,
        'data': utf8.encode(text),
        'relativePath': relativePath,
      });
    } catch (e) {
      return null;
    }
  }

  /// 打开系统目录选择器，返回 {"uri": treeUri, "display": 可读路径}。
  /// 用户取消或异常时返回 null。
  static Future<Map<String, String>?> pickSaveDir() async {
    try {
      final result = await platform.invokeMethod("pickSaveDir");
      if (result is Map) {
        return {
          'uri': '${result['uri']}',
          'display': '${result['display']}',
        };
      }
    } catch (e) {}
    return null;
  }

  /// 写入用户选定的目录（SAF tree uri）。同名文件会被覆盖。
  /// [subDir] 非空时写入该子目录（不存在会自动创建），用于整系列归档。
  static Future<String?> saveToTree(
    String treeUri,
    String name,
    String mimeType,
    String text, {
    String? subDir,
  }) async {
    try {
      return await platform.invokeMethod<String>("saveToTree", {
        'treeUri': treeUri,
        'name': name,
        'mimeType': mimeType,
        'data': utf8.encode(text),
        if (subDir != null && subDir.isNotEmpty) 'subDir': subDir,
      });
    } catch (e) {
      return null;
    }
  }

  static Future<Uint8List?> openFile() async {
    if (Platform.isIOS) {
      try {
        final result = await FilePicker.pickFile();
        return await result!.readAsBytes();
      } catch (e) {}
      return null;
    }
    return platform.invokeMethod<Uint8List>("openFile", {
      'type': "application/json",
    });
  }
}
