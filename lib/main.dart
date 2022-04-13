/*
 * Copyright (C) 2020. by perol_notsf, All rights reserved
 *
 * This program is free software: you can redistribute it and/or modify it under
 * the terms of the GNU General Public License as published by the Free Software
 * Foundation, either version 3 of the License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful, but WITHOUT ANY
 * WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
 * FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License along with
 * this program. If not, see <http://www.gnu.org/licenses/>.
 *
 */
import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:flutter_acrylic/flutter_acrylic.dart' as acrylic;
import 'package:pixez/constants.dart';
import 'package:pixez/er/fetcher.dart';
import 'package:pixez/er/hoster.dart';
import 'package:pixez/er/kver.dart';
import 'package:pixez/er/leader.dart';
import 'package:pixez/fluent_app_state.dart';
import 'package:pixez/material_app_state.dart';
import 'package:pixez/network/onezero_client.dart';
import 'package:pixez/page/history/history_store.dart';
import 'package:pixez/page/novel/history/novel_history_store.dart';
import 'package:pixez/page/splash/splash_store.dart';
import 'package:pixez/store/account_store.dart';
import 'package:pixez/store/book_tag_store.dart';
import 'package:pixez/store/mute_store.dart';
import 'package:pixez/store/save_store.dart';
import 'package:pixez/store/tag_history_store.dart';
import 'package:pixez/store/top_store.dart';
import 'package:pixez/store/user_setting.dart';
import 'package:in_app_purchase_android/in_app_purchase_android.dart';
import 'package:flutter/foundation.dart';
import 'package:pixez/win32_utils.dart' as win32_utils;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:win32/win32.dart' as win32;
import 'package:windows_single_instance/windows_single_instance.dart' as wsi;

final RouteObserver<ModalRoute<void>> routeObserver =
    RouteObserver<ModalRoute<void>>();
final UserSetting userSetting = UserSetting();
final SaveStore saveStore = SaveStore();
final MuteStore muteStore = MuteStore();
final AccountStore accountStore = AccountStore();
final TagHistoryStore tagHistoryStore = TagHistoryStore();
final HistoryStore historyStore = HistoryStore();
final NovelHistoryStore novelHistoryStore = NovelHistoryStore();
final TopStore topStore = TopStore();
final BookTagStore bookTagStore = BookTagStore();
OnezeroClient onezeroClient = OnezeroClient();
final SplashStore splashStore = SplashStore(onezeroClient);
final Fetcher fetcher = new Fetcher();
final KVer kVer = KVer();

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

main(List<String> args) async {
  // HttpOverrides.global = new MyHttpOverrides();
  WidgetsFlutterBinding.ensureInitialized();

  if (Constants.isFluentUI) {
    if (Platform.isWindows) {
      await wsi.WindowsSingleInstance.ensureSingleInstance(
          args, "pixez-{4db45356-86ec-449e-8d11-dab0feaf41b0}",
          onSecondWindow: (args) {
        print(
            "[WindowsSingleInstance]::Arguments(): \"${args.join("\" \"")}\"");
        if (args.length == 2 && args[0] == "--uri") {
          final uri = Uri.tryParse(args[1]);
          if (uri != null) {
            print(
                "[WindowsSingleInstance]::UriParser(): Legal uri: \"${uri}\"");
            Leader.pushWithUri(routeObserver.navigator!.context, uri);
          }
        }
      });

      final buildNumber = int.parse(win32_utils.getRegistryValue(
          win32.HKEY_LOCAL_MACHINE,
          'SOFTWARE\\Microsoft\\Windows NT\\CurrentVersion\\',
          'CurrentBuildNumber') as String);
      final isDarkTheme = (win32_utils.getRegistryValue(
              win32.HKEY_CURRENT_USER,
              'Software\\Microsoft\\Windows\\CurrentVersion\\Themes\\Personalize',
              'AppsUseLightTheme') as int) ==
          0;
      // See https://alexmercerind.github.io/docs/flutter_acrylic/#available-effects
      await acrylic.Window.initialize();
      if (buildNumber >= 22523)
        await acrylic.Window.setEffect(
          effect: acrylic.WindowEffect.tabbed,
          dark: isDarkTheme,
        );
      else if (buildNumber >= 22000)
        await acrylic.Window.setEffect(
          effect: acrylic.WindowEffect.mica,
          dark: isDarkTheme,
        );
      else if (buildNumber >= 17134)
        await acrylic.Window.setEffect(
          effect: acrylic.WindowEffect.acrylic,
          color: isDarkTheme ? Color(0xCC222222) : Color(0xCCDDDDDD),
          dark: isDarkTheme,
        );
      else
        await acrylic.Window.setEffect(
          effect: acrylic.WindowEffect.disabled,
          color: isDarkTheme ? Color(0xCC222222) : Color(0xCCDDDDDD),
          dark: isDarkTheme,
        );
    }
  } else {
    if (defaultTargetPlatform == TargetPlatform.android &&
        Constants.isGooglePlay) {
      InAppPurchaseAndroidPlatformAddition.enablePendingPurchases();
    }
  }
  sqfliteFfiInit();
  print(
      "[databaseFactoryFfi]::getDatabasesPath(): ${await databaseFactoryFfi.getDatabasesPath()}");
  runApp(App());
}

class App extends StatefulWidget {
  @override
  AppStateBase createState() {
    if (Constants.isFluentUI)
      return FluentAppState();
    else
      return MaterialAppState();
  }
}

abstract class AppStateBase extends State<App> with WidgetsBindingObserver {
  AppLifecycleState? appState;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    setState(() {
      appState = state;
    });
  }

  @override
  void dispose() {
    saveStore.dispose();
    topStore.dispose();
    fetcher.stop();
    if (Platform.isIOS) WidgetsBinding.instance?.removeObserver(this);
    super.dispose();
  }

  @override
  void initState() {
    Hoster.init();
    Hoster.syncRemote();
    userSetting.init();
    accountStore.fetch();
    bookTagStore.init();
    muteStore.fetchBanUserIds();
    muteStore.fetchBanIllusts();
    muteStore.fetchBanTags();
    initMethod();
    kVer.open();
    fetcher.start();
    super.initState();
    if (Platform.isIOS) WidgetsBinding.instance?.addObserver(this);
  }

  initMethod() async {
    if (userSetting.disableBypassSni) return;
  }

  Future<void> clean() async {
    final path = await saveStore.findLocalPath();
    Directory directory = Directory(path);
    List<FileSystemEntity> list = directory.listSync(recursive: true);
    if (list.length > 180) {
      directory.deleteSync(recursive: true);
    }
  }
}
