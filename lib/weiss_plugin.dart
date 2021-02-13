import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:pixez/er/leader.dart';
import 'package:pixez/er/lprinter.dart';

class WeissPlugin {
  static const platform = const MethodChannel('com.perol.dev/weiss');

  static Future<void> launch(String url) async {
    platform.invokeMethod("launch", {"url": url});
  }

  static Future<void> start() async {
    return await platform.invokeMethod("start");
  }

  static Future<void> stop() async {
    return await platform.invokeMethod("stop");
  }

  static Future<void> proxy() async {
    return await platform.invokeMethod("proxy");
  }

  static invoke(BuildContext context) {
    platform.setMethodCallHandler((call) async {
      if (call.method == "invoke") {
        String url = call.arguments['url'];
        LPrinter.d("url:$url");
        Leader.pushWithUri(context, Uri.parse(url));
      }
    });
  }
}
