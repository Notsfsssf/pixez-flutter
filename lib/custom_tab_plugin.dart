import 'dart:io';

import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart' as url_launcher;

class CustomTabPlugin {
  static const platform = const MethodChannel('com.perol.dev/custom_tab');

  static Future<void> launch(String url) async {
    if (Platform.isAndroid)
      return await platform.invokeMethod("launch", {'url': url});
    else
      await url_launcher.launch(url);
    return null;
  }
}