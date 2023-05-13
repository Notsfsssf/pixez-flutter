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
import 'package:fluent_ui/fluent_ui.dart' as fluentui;
import 'package:flutter/material.dart' as material;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
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
import 'package:pixez/windows.dart' as windows;
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

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

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

const _brandBlue = Color(0xFF1E88E5);

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  AppLifecycleState? _appState;
  late fluentui.AccentColor _accentColor;

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
    if (Platform.isIOS) WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  // CustomFooter _buildCustomFooter() {
  //   return CustomFooter(
  //     builder: (BuildContext context, LoadStatus? mode) {
  //       Widget body;
  //       if (mode == LoadStatus.idle) {
  //         body = Text(I18n.of(context).pull_up_to_load_more);
  //       } else if (mode == LoadStatus.loading) {
  //         body = CircularProgressIndicator();
  //       } else if (mode == LoadStatus.failed) {
  //         body = Text(I18n.of(context).loading_failed_retry_message);
  //       } else if (mode == LoadStatus.canLoading) {
  //         body = Text(I18n.of(context).let_go_and_load_more);
  //       } else {
  //         body = Text(I18n.of(context).no_more_data);
  //       }
  //       return Container(
  //         height: 55.0,
  //         child: Center(child: body),
  //       );
  //     },
  //   );
  // }
  @override
  void initState() {
    Hoster.init();
    Hoster.syncRemote();
    userSetting.init();
    accountStore.fetch();
    bookTagStore.init();
    muteStore.fetchBanAI();
    muteStore.fetchBanUserIds();
    muteStore.fetchBanIllusts();
    muteStore.fetchBanTags();
    initMethod();
    fetcher.start();
    super.initState();
    if (Platform.isIOS) WidgetsBinding.instance.addObserver(this);
    if (Constants.isFluent) {
      _accentColor = Color(windows.getAccentColor()).toAccentColor();
    }
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

  @override
  Widget build(BuildContext context) {
    return Constants.isFluent
        ? _buildFluentUI(context)
        : _buildMaterial(context);
  }

  Widget _buildMaterial(BuildContext context) {
    return Observer(builder: (_) {
      final botToastBuilder = BotToastInit();
      final myBuilder = (BuildContext context, Widget? widget) {
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
                        color: material.Theme.of(context).canvasColor,
                        child: Center(
                          child: Icon(material.Icons.privacy_tip_outlined),
                        ),
                      )
                    : null,
              )
            ],
          );
        } else {
          return widget;
        }
      };
      return DynamicColorBuilder(
          builder: (ColorScheme? lightDynamic, ColorScheme? darkDynamic) {
        ColorScheme lightColorScheme;
        ColorScheme darkColorScheme;

        if (lightDynamic != null && darkDynamic != null) {
          lightColorScheme = lightDynamic.harmonized();
          darkColorScheme = darkDynamic.harmonized();
        } else {
          lightColorScheme = ColorScheme.fromSeed(
            seedColor: _brandBlue,
          );
          darkColorScheme = ColorScheme.fromSeed(
            seedColor: _brandBlue,
            brightness: Brightness.dark,
          );
        }
        return material.MaterialApp(
          navigatorObservers: [BotToastNavigatorObserver(), routeObserver],
          locale: userSetting.locale,
          home: Builder(builder: (context) {
            return AnnotatedRegion<SystemUiOverlayStyle>(
                value: SystemUiOverlayStyle(
                  systemNavigationBarColor: material.Colors.transparent,
                  systemNavigationBarDividerColor: material.Colors.transparent,
                  statusBarColor: material.Colors.transparent,
                ),
                child: SplashPage());
          }),
          title: 'PixEz',
          builder: (context, child) {
            if (Platform.isIOS) child = myBuilder(context, child);
            child = botToastBuilder(context, child);
            return child;
          },
          themeMode: userSetting.themeMode,
          theme: material.ThemeData.light()
              .copyWith(useMaterial3: true, colorScheme: lightColorScheme),
          darkTheme: material.ThemeData.dark().copyWith(
              useMaterial3: true,
              scaffoldBackgroundColor:
                  userSetting.isAMOLED ? material.Colors.black : null,
              colorScheme: darkColorScheme),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales, // Add this line
        );
      });
    });
  }

  Widget _buildFluentUI(BuildContext context) {
    return Observer(builder: (context) {
      final botToastBuilder = BotToastInit();
      return fluentui.FluentApp(
        home: Builder(builder: (context) {
          return AnnotatedRegion<SystemUiOverlayStyle>(
            value: SystemUiOverlayStyle(
                statusBarColor: fluentui.Colors.transparent),
            child: SplashPage(),
          );
        }),
        builder: (context, child) {
          child = botToastBuilder(context, child);
          return Directionality(
            textDirection: TextDirection.ltr,
            child: fluentui.NavigationPaneTheme(
              data: fluentui.NavigationPaneThemeData(
                backgroundColor: fluentui.Colors.transparent,
              ),
              child: child,
            ),
          );
        },
        title: 'PixEz',
        locale: userSetting.locale,
        navigatorObservers: [
          BotToastNavigatorObserver(),
          routeObserver,
        ],
        themeMode: userSetting.themeMode,
        darkTheme: fluentui.FluentThemeData(
          brightness: Brightness.dark,
          visualDensity: fluentui.VisualDensity.standard,
          accentColor: _accentColor,
          focusTheme: fluentui.FocusThemeData(
            glowFactor: fluentui.is10footScreen(context) ? 2.0 : 0.0,
          ),
        ),
        theme: fluentui.FluentThemeData(
          brightness: Brightness.light,
          visualDensity: fluentui.VisualDensity.standard,
          accentColor: _accentColor,
          focusTheme: fluentui.FocusThemeData(
            glowFactor: fluentui.is10footScreen(context) ? 2.0 : 0.0,
          ),
        ),
        localizationsDelegates: [
          _FluentLocalizationsDelegate(),
          ...AppLocalizations.localizationsDelegates
        ],
        supportedLocales: AppLocalizations.supportedLocales, // Add this line
      );
    });
  }
}

class _FluentLocalizationsDelegate
    extends LocalizationsDelegate<fluentui.FluentLocalizations> {
  const _FluentLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return AppLocalizations.supportedLocales.contains(locale);
  }

  @override
  Future<fluentui.FluentLocalizations> load(Locale locale) {
    return fluentui.FluentLocalizations.delegate.load(locale);
  }

  @override
  bool shouldReload(
      covariant LocalizationsDelegate<fluentui.FluentLocalizations> old) {
    return false;
  }
}
