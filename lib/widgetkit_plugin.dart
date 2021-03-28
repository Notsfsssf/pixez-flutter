import 'package:flutter/services.dart';

class WeissPlugin {
  static const platform = const MethodChannel('com.perol.dev/widgetkit');

  static Future<void> notify() async {
    return await platform.invokeMethod("notify");
  }
}
