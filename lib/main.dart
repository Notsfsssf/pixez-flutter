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
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:pixez/constants.dart';
import 'package:pixez/er/fetcher.dart';
import 'package:pixez/er/hoster.dart';
import 'package:pixez/fluentui.dart';
import 'package:pixez/network/onezero_client.dart';
import 'package:pixez/page/history/history_store.dart';
import 'package:pixez/page/novel/history/novel_history_store.dart';
import 'package:pixez/page/splash/splash_page.dart';
import 'package:pixez/page/splash/splash_store.dart';
import 'package:pixez/store/account_store.dart';
import 'package:pixez/store/book_tag_store.dart';
import 'package:pixez/store/mute_store.dart';
import 'package:pixez/store/save_store.dart';
import 'package:pixez/store/tag_history_store.dart';
import 'package:pixez/store/top_store.dart';
import 'package:pixez/store/user_setting.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

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

main(List<String> args) async {
  if (Platform.isWindows || Platform.isLinux) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }
  WidgetsFlutterBinding.ensureInitialized();

  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    await initFluent(args);
  }

  runApp(ProviderScope(
    child: MyApp(),
  ));
}

class MyApp extends StatefulWidget {
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
    Hoster.init();
    Hoster.syncRemote();
    userSetting.init();
    accountStore.fetch();
    bookTagStore.init();
    muteStore.fetchBanAI();
    muteStore.fetchBanUserIds();
    muteStore.fetchBanIllusts();
    muteStore.fetchBanTags();
    fetcher.start();
    super.initState();
    if (Platform.isIOS) WidgetsBinding.instance.addObserver(this);
  }

  @override
  Widget build(BuildContext context) {
    return Constants.isFluent
        ? buildFluentUI(context)
        : _buildMaterial(context);
  }

  Widget _buildMaterial(BuildContext context) {
    final botToastBuilder = BotToastInit();
    return DynamicColorBuilder(
        builder: (ColorScheme? lightDynamic, ColorScheme? darkDynamic) {
      ColorScheme lightColorScheme;
      ColorScheme darkColorScheme;
      if (userSetting.useDynamicColor &&
          lightDynamic != null &&
          darkDynamic != null) {
        lightColorScheme = lightDynamic.harmonized();
        darkColorScheme = darkDynamic.harmonized();
      } else {
        Color primary = userSetting.themeData.colorScheme.primary;
        lightColorScheme = ColorScheme.fromSeed(
          seedColor: primary,
        );
        darkColorScheme = ColorScheme.fromSeed(
          seedColor: primary,
          brightness: Brightness.dark,
        );
      }
      return Observer(builder: (_) {
        return MaterialApp(
          navigatorObservers: [BotToastNavigatorObserver(), routeObserver],
          locale: userSetting.locale,
          home: Builder(builder: (context) {
            return AnnotatedRegion<SystemUiOverlayStyle>(
                value: SystemUiOverlayStyle(
                  systemNavigationBarColor: Colors.transparent,
                  systemNavigationBarDividerColor: Colors.transparent,
                  statusBarColor: Colors.transparent,
                  systemNavigationBarContrastEnforced: false,
                  systemNavigationBarIconBrightness:
                      Theme.of(context).brightness == Brightness.light
                          ? Brightness.dark
                          : Brightness.light,
                ),
                child: SplashPage());
          }),
          title: 'PixEz',
          builder: (context, child) {
            if (Platform.isIOS) child = _buildMaskBuilder(context, child);
            child = botToastBuilder(context, child);
            return child;
          },
          themeMode: userSetting.themeMode,
          theme: ThemeData.light()
              .copyWith(useMaterial3: true, colorScheme: lightColorScheme),
          darkTheme: ThemeData.dark().copyWith(
              useMaterial3: true,
              scaffoldBackgroundColor:
                  userSetting.isAMOLED ? Colors.black : null,
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
