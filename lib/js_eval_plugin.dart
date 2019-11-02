import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:pixez/models/illust.dart';

class JSEvalPlugin {
  static const platform = const MethodChannel('com.perol.dev/eval');

  static Future<String?> eval(
      Illusts illusts, String func, int part, String memType) async {
    final result = await platform.invokeMethod("eval", {
      'json': jsonEncode(illusts.toJson()),
      'func': func,
      'part': part,
      'mime': memType
    });
    if (result != null) {
      return result;
    }
    return null;
  }
}
