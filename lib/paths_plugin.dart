import 'package:flutter/services.dart';

class Paths {
  static MethodChannel channel = MethodChannel("com.perol.dev/paths");

  static Future<String?> getDatabaseFolderPath() async {
    return await channel.invokeMethod("getDatabaseFolderPath");
  }
}
