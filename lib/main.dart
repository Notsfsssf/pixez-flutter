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
import 'dart:async';
import 'dart:io';

import 'package:bot_toast/bot_toast.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:pixez/constants.dart';
import 'package:pixez/er/fetcher.dart';
import 'package:pixez/fluent/fluentui.dart';
import 'package:pixez/i18n.dart';
import 'package:pixez/page/novel/history/novel_history_store.dart';
import 'package:pixez/page/splash/splash_page.dart';
import 'package:pixez/page/splash/splash_store.dart';
import 'package:pixez/paths_plugin.dart';
import 'package:pixez/single_instance_plugin.dart';
import 'package:pixez/src/generated/i18n/app_localizations.dart';
import 'package:pixez/store/account_store.dart';
import 'package:pixez/store/book_tag_store.dart';
import 'package:pixez/store/fullscreen_store.dart';
import 'package:pixez/store/mute_store.dart';
import 'package:pixez/store/save_store.dart';
import 'package:pixez/store/tag_history_store.dart';
import 'package:pixez/store/top_store.dart';
import 'package:pixez/store/user_setting.dart';
import 'package:rhttp/rhttp.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

final RouteObserver<ModalRoute<void>> routeObserver =
    RouteObserver<ModalRoute<void>>();
final UserSetting userSetting = UserSetting();
final SaveStore saveStore = SaveStore();
final MuteStore muteStore = MuteStore();
final AccountStore accountStore = AccountStore();
final TagHistoryStore tagHistoryStore = TagHistoryStore();
final NovelHistoryStore novelHistoryStore = NovelHistoryStore();
final TopStore topStore = TopStore();
final BookTagStore bookTagStore = BookTagStore();
final SplashStore splashStore = SplashStore();
final Fetcher fetcher = new Fetcher();
final FullScreenStore fullScreenStore = FullScreenStore();

main(List<String> args) async {
  await Rhttp.init();

  WidgetsFlutterBinding.ensureInitialized();

  if (Platform.isWindows || Platform.isLinux) {
    // sqflite ffi init
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;

    final dbPath = await Paths.getDatabaseFolderPath();
    if (dbPath != null) databaseFactory.setDatabasesPath(dbPath);

    // 确保只有一个实例正在运行
    // Android 和 iOS 应用本身就是单例程序，无需额外操作
    SingleInstancePlugin.initialize();
  }
  await initFluent(args);

  runApp(ProviderScope(
    child: MyApp(arguments: args),
  ));
}

class MyApp extends StatefulWidget {
  final List<String> arguments;

  const MyApp({super.key, required this.arguments});
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  AppLifecycleState? _appState;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    setState(() {
      _appState = state;
    });
  }

  @override
  void dispose() {
    saveStore.dispose();
    topStore.dispose();
    fetcher.stop();
    subscription.cancel();
    if (Platform.isIOS) WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  late StreamSubscription<String> subscription;

  @override
  void initState() {
    subscription = topStore.topStream.listen((event) {
      if (event == "main") {
        setState(() {});
      }
    });
    userSetting.askInit();
    userSetting.init();
    accountStore.fetch();
    bookTagStore.init();
    muteStore.fetchBanAI();
    muteStore.fetchBanUserIds();
    muteStore.fetchBanIllusts();
    muteStore.fetchBanTags();

    super.initState();
    if (Platform.isIOS) WidgetsBinding.instance.addObserver(this);

    Future.delayed(Duration.zero, () {
      SingleInstancePlugin.argsParser(widget.arguments);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Constants.isFluent
        ? buildFluentUI(context)
        : _buildMaterial(context);
  }

  Widget _buildMaterial(BuildContext context) {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarDividerColor: Colors.transparent,
      statusBarColor: Colors.transparent,
    ));
    final botToastBuilder = BotToastInit();
    return DynamicColorBuilder(
        builder: (ColorScheme? lightDynamic, ColorScheme? darkDynamic) {
      return Observer(builder: (context) {
        ColorScheme lightColorScheme;
        ColorScheme darkColorScheme;
        if (userSetting.useDynamicColor &&
            lightDynamic != null &&
            darkDynamic != null) {
          lightColorScheme = lightDynamic.harmonized();
          darkColorScheme = darkDynamic.harmonized();
        } else {
          Color primary = userSetting.seedColor;
          lightColorScheme = ColorScheme.fromSeed(
            seedColor: primary,
          );
          darkColorScheme = ColorScheme.fromSeed(
            seedColor: primary,
            brightness: Brightness.dark,
          );
        }
        final brightness =
            SchedulerBinding.instance.platformDispatcher.platformBrightness;
        if (userSetting.themeInitState != 1) {
          return MaterialApp(
            home: Container(
              color:
                  brightness == Brightness.dark ? Colors.black : Colors.white,
              child: Center(child: CircularProgressIndicator()),
            ),
          );
        }
        return MaterialApp(
          navigatorObservers: [BotToastNavigatorObserver(), routeObserver],
          locale: userSetting.locale,
          home: Builder(builder: (context) {
            return AnnotatedRegion<SystemUiOverlayStyle>(
                value: SystemUiOverlayStyle(
                  systemNavigationBarColor: Colors.transparent,
                  systemNavigationBarDividerColor: Colors.transparent,
                  statusBarColor: Colors.transparent,
                ),
                child: SplashPage());
          }),
          title: 'PixEz',
          builder: (context, child) {
            if (Platform.isIOS) child = _buildMaskBuilder(context, child);
            child = botToastBuilder(context, child);
            I18n.context = context;
            return child;
          },
          themeMode: userSetting.themeMode,
          theme: ThemeData.light().copyWith(
              primaryColor: lightColorScheme.primary,
              colorScheme: lightColorScheme,
              scaffoldBackgroundColor: lightColorScheme.surface,
              cardColor: lightColorScheme.surfaceContainer,
              chipTheme: ChipThemeData(
                backgroundColor: lightColorScheme.surface,
              ),
              canvasColor: lightColorScheme.surfaceContainer,
              dialogTheme: DialogThemeData(
                  backgroundColor: lightColorScheme.surfaceContainer)),
          darkTheme: ThemeData.dark().copyWith(
              scaffoldBackgroundColor:
                  userSetting.isAMOLED ? Colors.black : null,
              tabBarTheme: TabBarTheme(dividerColor: Colors.transparent),
              colorScheme: darkColorScheme),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
        );
      });
    });
  }

  _buildMaskBuilder(BuildContext context, Widget? widget) {
    if (userSetting.nsfwMask) {
      final needShowMask = (Platform.isAndroid
          ? (_appState == AppLifecycleState.paused ||
              _appState == AppLifecycleState.paused)
          : _appState == AppLifecycleState.inactive);
      return Stack(
        children: [
          widget ?? Container(),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 500),
            child: needShowMask
                ? Container(
                    color: Theme.of(context).canvasColor,
                    child: Center(
                      child: Icon(Icons.privacy_tip_outlined),
                    ),
                  )
                : null,
          )
        ],
      );
    } else {
      return widget;
    }
  }
}
