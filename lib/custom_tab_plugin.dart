import 'dart:io';

import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher_string.dart';

class CustomTabPlugin {
  static const platform = const MethodChannel('com.perol.dev/custom_tab');

  static Future<void> launch(String url) async {
    if (Platform.isAndroid)
      return await platform.invokeMethod("launch", {'url': url});
    else
      await launchUrlString(url);
    return null;
  }
}