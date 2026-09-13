import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class LoginPlugin {
  static const MethodChannel _channel = MethodChannel('com.perol.dev/login');

  static Future<String?> open(String url, {String? title}) async {
    try {
      final result = await _channel.invokeMethod<String>('open', {
        'url': url,
        if (title != null) 'title': title,
      });
      return result;
    } catch (e) {
      debugPrint("LoginPlugin.open error: $e");
      return null;
    }
  }
}
