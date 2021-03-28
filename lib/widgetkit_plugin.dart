import 'dart:io';

import 'package:flutter/services.dart';

class WidgetkitPlugin {
  static const platform = const MethodChannel('com.perol.dev/widgetkit');

  static Future<void> notify() async {
    if(!Platform.isIOS){
      return;
    }
    return await platform.invokeMethod("notify");
  }
}
