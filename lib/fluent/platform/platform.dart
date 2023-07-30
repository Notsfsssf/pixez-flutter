import 'dart:io';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_acrylic/flutter_acrylic.dart';
import 'package:pixez/fluent/platform/windows/win32.dart' as windows;
import 'package:pixez/fluent/platform/windows/paths.dart' as windows;
import 'package:windows_single_instance/windows_single_instance.dart';

/// 这个函数是确保同一时间有且只有一个Pixez实例存在的
///
/// 它需要将其他实例的命令行参数转发给第一个实例
/// 然后结束自己的进程
///
///
/// [args] 是当前实例的命令行参数
///
/// [pipeName] 是命名管道的名字 它应该是在操作系统范围内唯一的
///
/// [callback] 这是第一个实例的回调函数，它的参数是其他实例的命令行参数
Future singleInstance(
  List<String> args,
  String pipeName,
  Function(List<String> args) callback,
) async {
  switch (Platform.operatingSystem) {
    case "windows":
      await WindowsSingleInstance.ensureSingleInstance(
        args,
        pipeName,
        onSecondWindow: callback,
      );
      return;
    case "linux":
    case "macos":
    default:
      debugPrint('Not Impliment');
      return;
  }
}

/// 这个函数是获取数据库位置的，当返回有值的时候将数据库存到这个地方
Future<String?> getDBPath() async {
  switch (Platform.operatingSystem) {
    case "windows":
      return windows.getAppDataFolderPath();
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
      if (windows.isBuildOrGreater(22523)) {
        return WindowEffect.tabbed;
      } else if (windows.isBuildOrGreater(22000)) {
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
