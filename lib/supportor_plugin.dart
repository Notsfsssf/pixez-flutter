import 'package:flutter/services.dart';

class ResolvePack {
  final String package;
  final String name;

  ResolvePack(this.package, this.name);
}

class SupportorPlugin {
  static const platform = const MethodChannel('com.perol.dev/supporter');
  static var supportTranslate = false;

  static Future<bool> processText() async {
    bool result = await platform.invokeMethod("process_text");
    supportTranslate = result;
    return result;
  }

  static Future<void> start(String text) async {
    await platform.invokeMethod("process", {"text": text});
  }

  static Future<void> existApp() async {
    try {
      await platform.invokeMethod("exist");
    } catch (e) {}
  }
}
