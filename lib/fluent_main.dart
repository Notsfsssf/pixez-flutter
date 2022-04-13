import 'dart:io';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_acrylic/flutter_acrylic.dart';
import 'package:pixez/er/leader.dart';
import 'package:pixez/main.dart';
import 'package:pixez/fluent_app.dart';
import 'package:pixez/win32_utils.dart';
import 'package:win32/win32.dart';
import 'package:windows_single_instance/windows_single_instance.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

Future fluentMain(List<String> args) async {
  var isDarkTheme;
  var accentColor;
  await Window.initialize();
  if (Platform.isWindows) {
    await WindowsSingleInstance.ensureSingleInstance(
        args, "pixez-{4db45356-86ec-449e-8d11-dab0feaf41b0}",
        onSecondWindow: (args) {
      print("[WindowsSingleInstance]::Arguments(): \"${args.join("\" \"")}\"");
      if (args.length == 2 && args[0] == "--uri") {
        final uri = Uri.tryParse(args[1]);
        if (uri != null) {
          print("[WindowsSingleInstance]::UriParser(): Legal uri: \"${uri}\"");
          Leader.pushWithUri(routeObserver.navigator!.context, uri);
        }
      }
    });
    final buildNumber = int.parse(getRegistryValue(
        HKEY_LOCAL_MACHINE,
        'SOFTWARE\\Microsoft\\Windows NT\\CurrentVersion\\',
        'CurrentBuildNumber') as String);
    isDarkTheme = (getRegistryValue(
            HKEY_CURRENT_USER,
            'Software\\Microsoft\\Windows\\CurrentVersion\\Themes\\Personalize',
            'AppsUseLightTheme') as int) ==
        0;
    accentColor = getAccentColor();
    // See https://alexmercerind.github.io/docs/flutter_acrylic/#available-effects
    if (buildNumber >= 22523)
      await Window.setEffect(
        effect: WindowEffect.tabbed,
        dark: isDarkTheme,
      );
    else if (buildNumber >= 22000)
      await Window.setEffect(
        effect: WindowEffect.mica,
        dark: isDarkTheme,
      );
    else if (buildNumber >= 17134) {
      await Window.setEffect(
        effect: WindowEffect.acrylic,
        color: Color(accentColor),
        dark: isDarkTheme,
      );
    }
  }
  sqfliteFfiInit();
  print(
      "[databaseFactoryFfi]::getDatabasesPath(): ${await databaseFactoryFfi.getDatabasesPath()}");
  runApp(MyFluentApp(Color(accentColor)));
}
