import 'dart:io';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_acrylic/flutter_acrylic.dart';
import 'package:pixez/constants.dart';
import 'package:pixez/main.dart';
import 'package:pixez/windows.dart' as windows;
import 'package:window_manager/window_manager.dart';
import 'package:windows_single_instance/windows_single_instance.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'er/leader.dart';

initFluent(List<String> args) async {
  Constants.isFluent = true;
  if (kDebugMode) {
    // 向操作系统注册协议
    // 仅在调试时使用这个, 发布时使用msix 已经自动注册了所以不需要手动修改了
    windows.registerProtocol('pixez', 'URL:Pixez protocol', '"%1"');
    windows.registerProtocol('pixiv', 'URL:Pixiv protocol', '"%1"');
  }

  if (Platform.isWindows) {
    databaseFactory.setDatabasesPath(windows.getAppDataFolderPath()!);
    // 使同一时间只允许运行一个PixEz实例
    await WindowsSingleInstance.ensureSingleInstance(
      args,
      "Pixez::{fe97f8e1-32e5-44ec-9bfb-cde274b87f61}",
      onSecondWindow: (args) {
        debugPrint("从另一实例接收到的参数: $args");
        _argsParser(args);
      },
    );
  } else {
    // TODO: 在此处实现一个IPC服务，使PixEz能以单例模式运行
  }

  // Must add this line.
  await windowManager.ensureInitialized();
  await windowManager.waitUntilReadyToShow(
    WindowOptions(
      titleBarStyle: TitleBarStyle.hidden,
      center: true,
      skipTaskbar: false,
      minimumSize: const Size(350, 600),
    ),
    () async {
      WindowEffect effect = WindowEffect.disabled;

      switch (Platform.operatingSystem) {
        case "windows":
          // 根据系统版本号自动使用不同的效果
          // 不需要从用户设置中读取, 这个只要跟随系统设置就可以了
          if (windows.isBuildOrGreater(22523)) {
            effect = WindowEffect.tabbed;
          } else if (windows.isBuildOrGreater(22000)) {
            effect = WindowEffect.mica;
            // 亚克力效果由于存在一些问题所以先不启用
            // } else if (windows.isBuildOrGreater(17134)) {
            //   effect = WindowEffect.acrylic;
          }
          break;
        case "linux":
        case "macos":
        default:
      }

      final dark = Platform.isWindows ? windows.isDarkMode() : true;

      Constants.disableWindowEffect = effect == WindowEffect.disabled;
      if (!Constants.disableWindowEffect) {
        await windowManager.setBackgroundColor(Colors.transparent);
      }

      debugPrint("使用的背景特效: $effect; 暗色主题: ${dark};");
      await Window.initialize();
      await Window.setEffect(
        effect: effect,
        dark: dark,
      );

      await windowManager.show();
      await windowManager.focus();
    },
  );
}

// 解析命令行参数字符串
_argsParser(List<String> args) async {
  if (args.length < 1) return;

  final uri = Uri.tryParse(args[0]);
  if (uri != null) {
    debugPrint("::_argsParser(): 合法的Uri: \"${uri}\"");
    Leader.pushWithUri(routeObserver.navigator!.context, uri);
  }
}
