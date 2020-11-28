import 'package:flutter/services.dart';

class ResolvePack {
  final String package;
  final String name;

  ResolvePack(this.package, this.name);
}

class SupportorPlugin {
  static const platform = const MethodChannel('com.perol.dev/supporter');

  static Future<bool> processText() async {
    bool result = await platform.invokeMethod("process_text");
    return result;
  }

  static Future<void> start(String text) async {
    await platform.invokeMethod("process", {"text": text});
  }
}
