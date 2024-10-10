import 'dart:io';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_acrylic/flutter_acrylic.dart';
import 'package:pixez/fluent/platform/windows/windows.dart' as windows;

/// 这个函数是获取数据库位置的，当返回有值的时候将数据库存到这个地方
Future<String?> getDBPath() async {
  switch (Platform.operatingSystem) {
    case "windows":
      return await windows.Paths.getAppDataFolderPath();
    case "linux":
    case "macos":
    default:
      debugPrint('Not Impliment');
      return null;
  }
}

Future<WindowEffect> getEffect() async {
  switch (Platform.operatingSystem) {
    case "windows":
      if (await windows.Win32.isBuildOrGreater(22523)) {
        return WindowEffect.tabbed;
      } else if (await windows.Win32.isBuildOrGreater(22000)) {
        return WindowEffect.mica;
        // 亚克力效果由于存在一些问题所以先不启用
        // } else if (windows.isBuildOrGreater(17134)) {
        //   effect = WindowEffect.acrylic;
      }
      return WindowEffect.disabled;
    case "linux":
    case "macos":
    default:
      debugPrint('Not Impliment');
      return WindowEffect.disabled;
  }
}
