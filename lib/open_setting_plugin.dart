import 'dart:typed_data';

import 'package:flutter/services.dart';

class OpenSettingPlugin {
  static const platform = const MethodChannel('com.perol.dev/open');

  //ACTION_APP_OPEN_BY_DEFAULT_SETTINGS
  static Future<void> open() async {
    platform.invokeMethod("open");
  }
}