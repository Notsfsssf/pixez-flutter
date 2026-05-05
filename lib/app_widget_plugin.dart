import 'dart:io';

import 'package:flutter/services.dart';

class AppWidgetPlugin {
  static const platform = MethodChannel('com.perol.dev/app_widget');

  static Future<void> setRecommendType(String type) async {
    if (!Platform.isAndroid && !Platform.isIOS) {
      return;
    }
    await platform.invokeMethod<void>('setRecommendType', {'type': type});
  }
}
