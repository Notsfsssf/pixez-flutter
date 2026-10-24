import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/services.dart' show MethodChannel;
import 'package:pixez/main.dart' show userSetting;

/// 统一文件导入、导出和图片保存的平台接口。
///
/// saveBytes/saveFile 按应用配置保存到目录或相册，
/// pickBytes/saveBytesAs 通过选择器读取文件或另存为。
/// 同时提供保存目录管理、文件存在检查和保存权限操作。
class FileServicePlugin {
  static const _safChannel = MethodChannel('com.perol.dev/saf');
  static const _saveChannel = MethodChannel('com.perol.dev/save');

  static Future<bool?> saveBytes(
    Uint8List data,
    String fileName, {
    bool clearOld = false,
    int? saveMode,
  }) {
    return _saveChannel.invokeMethod<bool>('save', {
      'data': data,
      'name': fileName,
      'save_mode': saveMode ?? userSetting.saveMode,
      'clear_old': clearOld,
    });
  }

  static Future<bool?> saveFile(
    String sourcePath,
    String fileName, {
    bool clearOld = false,
    int? saveMode,
  }) {
    return _saveChannel.invokeMethod<bool>('saveFromPath', {
      'source_path': sourcePath,
      'name': fileName,
      'save_mode': saveMode ?? userSetting.saveMode,
      'clear_old': clearOld,
    });
  }

  static Future<bool?> checkPermission() {
    return _saveChannel.invokeMethod<bool>('permissionStatus');
  }

  static Future<bool?> requestPermission() {
    return _saveChannel.invokeMethod<bool>('requestPermission');
  }

  static Future<bool?> exists(String fileName, {int? saveMode}) {
    return _saveChannel.invokeMethod<bool>('exist', {
      'name': fileName,
      'save_mode': saveMode ?? userSetting.saveMode,
    });
  }

  static Future<String?> getSaveDir({int? saveMode}) {
    return _saveChannel.invokeMethod<String>('get_path', {
      'save_mode': saveMode ?? userSetting.saveMode,
    });
  }

  static Future<dynamic> pickSaveDir({int? saveMode}) {
    return _saveChannel.invokeMethod('choice_folder', {
      'save_mode': saveMode ?? userSetting.saveMode,
    });
  }

  static Future<Uint8List?> pickBytes({
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

  static Future<bool> saveBytesAs({
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
