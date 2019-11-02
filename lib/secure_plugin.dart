import 'dart:io';

import 'package:flutter/services.dart';

class SecurePlugin {
  static const platform = const MethodChannel('com.perol.dev/secure');

  static Future<void> configSecureWindow(bool enabled) async {
    try {
      if (Platform.isAndroid) {
        await platform.invokeMethod("configSecureWindow", {'value': enabled});
      }
    } catch (e) {}
  }
}
