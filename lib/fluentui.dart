import 'dart:io';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_acrylic/flutter_acrylic.dart';
import 'package:flutter_single_instance/flutter_single_instance.dart';
import 'package:pixez/constants.dart';
import 'package:pixez/main.dart';
import 'package:pixez/windows.dart' as windows;
import 'package:window_manager/window_manager.dart';
import 'package:windows_single_instance/windows_single_instance.dart';

import 'er/leader.dart';

initFluent(List<String> args) async {
  Constants.isFluent = true;
  // 向操作系统注册协议
  registerProtocol('pixez', 'URL:Pixez protocol', '--uri:"%1"');
  registerProtocol('pixiv', 'URL:Pixiv protocol', '--uri:"%1"');

  if (Platform.isWindows) {
    // 使同一时间只允许运行一个PixEz实例
    await WindowsSingleInstance.ensureSingleInstance(
      args,
      "Pixez::{fe97f8e1-32e5-44ec-9bfb-cde274b87f61}",
      onSecondWindow: (args) {
        debugPrint("从另一实例接收到的参数: $args");
        _argsParser(args);
      },
    );
  } else if (!await FlutterSingleInstance.platform.isFirstInstance()) {
    // TODO: 在此处实现一个IPC服务，使PixEz能以单例模式运行
    print("App is already running");

    exit(0);
  }

  // Must add this line.
  await windowManager.ensureInitialized();
  await windowManager.waitUntilReadyToShow(
    WindowOptions(
      titleBarStyle: TitleBarStyle.hidden,
      center: true,
      skipTaskbar: false,
      minimumSize: const Size(350, 600),
      backgroundColor: Colors.transparent,
    ),
    () async {
      await windowManager.setBackgroundColor(Colors.transparent);

      WindowEffect effect = WindowEffect.disabled;

      switch (Platform.operatingSystem) {
        case "windows":
          // 根据系统版本号自动使用不同的效果
          // TODO： 改为从用户设置中读取
          if (windows.isBuildOrGreater(22523)) {
            effect = WindowEffect.tabbed;
          } else if (windows.isBuildOrGreater(22000)) {
            effect = WindowEffect.mica;
          } else if (windows.isBuildOrGreater(17134)) {
            effect = WindowEffect.acrylic;
          }
          break;
        case "linux":
        case "macos":
        default:
      }

      final dark = Platform.isWindows ? windows.isDarkMode() : true;

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

void registerProtocol(String scheme, String desc, String template) {
  if (Platform.isWindows) {
    windows.registerProtocol(scheme, desc, template);
    return;
  }
  // TODO: https://pub.dev/packages/protocol_handler
  print("尚不支持在当前平台上注册链接协议");
}

// 解析命令行参数字符串
_argsParser(List<String> args) async {
  if (args.length < 1) return;

  const arg = '--uri';
  String uri;
  final item = args.firstWhere((i) => i.startsWith(arg));
  if (item.contains('$arg:') || item.startsWith('$arg=')) {
    uri = item.substring(arg.length + 1);
  } else {
    final index = args.indexOf(item);
    uri = args[index + 1];
  }
  final _uri = Uri.tryParse(uri);
  if (_uri != null) {
    debugPrint("::_argsParser(): 合法的Uri: \"${_uri}\"");
    Leader.pushWithUri(routeObserver.navigator!.context, _uri);
  }
}
