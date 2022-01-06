import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:pixez/er/hoster.dart';

/// 目前这些调用原生的方法,只在Android端进行了实现,iOS端一点就崩溃,先用try-catch进行守护
class WeissPlugin {
  static const platform = const MethodChannel('com.perol.dev/weiss');

  static Future<void> start() async {
    final map = Hoster.hardMap();

    String data = "";
    try {
      if (map.containsKey("doh")) {
        final iMap = Map();
        iMap["doh"] = map["doh"];
        data = json.encode(iMap);
      }
    } catch (e) {}

    try {
      return await platform.invokeMethod("start", {"port": "9876", "map": data});
    } catch (error) {
      return;
    }
  }

  static Future<void> stop() async {
    try {
      return await platform.invokeMethod("stop");
    } catch (error) {
      return;
    }
  }

  static Future<void> proxy() async {
    try {
      return await platform.invokeMethod("proxy");
    } catch (error) {
      return;
    }
  }
}
