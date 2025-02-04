import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/services.dart';

class SAFPlugin {
  static const platform = const MethodChannel('com.perol.dev/saf');

  static Future<String?> createFile(String name, String type) async {
    final result = await platform
        .invokeMethod("createFile", {'name': name, 'mimeType': type});
    if (result != null) {
      return result;
    }
    return null;
  }

  static Future<void> writeUri(String uri, Uint8List data) async {
    return platform.invokeMethod("writeUri", {'uri': uri, 'data': data});
  }

  static Future<Uint8List?> openFile() async {
    if (Platform.isIOS) {
      try {
        FilePickerResult? result = await FilePicker.platform.pickFiles();
        if (result != null) {
          return File(result.files.single.path!).readAsBytes();
        }
      } catch (e) {}
      return null;
    }
    return platform
        .invokeMethod<Uint8List>("openFile", {'type': "application/json"});
  }
}
