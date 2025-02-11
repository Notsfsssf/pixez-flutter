import 'package:flutter/services.dart';

class Win32 {
  static MethodChannel channel = MethodChannel("com.perol.dev/win32");

  /// 判断系统build版本号是否大于 [build]
  static Future<bool> isBuildOrGreater(int build) async {
    try {
      return await channel.invokeMethod("isBuildOrGreater", {
        'build': build
      });
    } catch (e) {
      return false;
    }
  }
}
