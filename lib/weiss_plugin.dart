import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:pixez/er/hoster.dart';

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
    return await platform.invokeMethod("start", {"port": "9876", "map": data});
  }

  static Future<void> stop() async {
    return await platform.invokeMethod("stop");
  }

  static Future<void> proxy() async {
    return await platform.invokeMethod("proxy");
  }
}
