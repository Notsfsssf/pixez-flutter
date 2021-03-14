import 'dart:io';

import 'package:flutter/services.dart';

class CustomTabPlugin {
  static const platform = const MethodChannel('com.perol.dev/custom_tab');

  static Future<void> launch(String url) async {
    if (Platform.isAndroid)
      return await platform.invokeMethod("launch", {'url': url});
    else
      return await launch(url);
  }
}
