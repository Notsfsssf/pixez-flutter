import 'package:flutter/services.dart';

class Paths {
  static MethodChannel channel = MethodChannel("com.perol.dev/paths");

  static Future<void> setApplicationSupportDirectory(String path) async {
    return await channel.invokeMethod("setApplicationSupportDirectory", {
      'path': path,
    });
  }
}
