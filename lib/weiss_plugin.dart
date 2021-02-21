import 'package:flutter/services.dart';

class WeissPlugin {
  static const platform = const MethodChannel('com.perol.dev/weiss');

  static Future<void> start() async {
    return await platform.invokeMethod("start");
  }

  static Future<void> stop() async {
    return await platform.invokeMethod("stop");
  }

  static Future<void> proxy() async {
    return await platform.invokeMethod("proxy");
  }
}
