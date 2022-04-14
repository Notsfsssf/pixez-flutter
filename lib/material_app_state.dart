
import 'dart:io';

import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:pixez/main.dart';
import 'package:pixez/page/splash/common_splash_page.dart';

class MaterialAppState extends AppStateBase {

  @override
  Widget build(BuildContext context) {
    return Observer(builder: (_) {
      final botToastBuilder = BotToastInit();
      final myBuilder = (BuildContext context, Widget? widget) {
        if (userSetting.nsfwMask) {
          final needShowMask = (Platform.isAndroid
              ? (appState == AppLifecycleState.paused ||
                  appState == AppLifecycleState.paused)
              : appState == AppLifecycleState.inactive);
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
      };
      return MaterialApp(
        navigatorObservers: [BotToastNavigatorObserver(), routeObserver],
        locale: userSetting.locale,
        home: Builder(builder: (context) {
          return AnnotatedRegion<SystemUiOverlayStyle>(
              value: SystemUiOverlayStyle(statusBarColor: Colors.transparent),
              child: SplashPage());
        }),
        title: 'PixEz',
        builder: (context, child) {
          if (Platform.isIOS) child = myBuilder(context, child);
          child = botToastBuilder(context, child);
          return child;
        },
        themeMode: userSetting.themeMode,
        theme: ThemeData.light().copyWith(
            primaryColor: userSetting.themeData.colorScheme.primary,
            primaryColorLight: userSetting.themeData.colorScheme.primary,
            primaryColorDark: userSetting.themeData.colorScheme.primary,
            colorScheme: ThemeData.light().colorScheme.copyWith(
                  secondary: userSetting.themeData.colorScheme.secondary,
                  primary: userSetting.themeData.colorScheme.primary,
                )),
        darkTheme: ThemeData.dark().copyWith(
          scaffoldBackgroundColor: userSetting.isAMOLED ? Colors.black : null,
          primaryColor: userSetting.themeData.colorScheme.primary,
          primaryColorLight: userSetting.themeData.colorScheme.primary,
          primaryColorDark: userSetting.themeData.colorScheme.primary,
          colorScheme: ThemeData.dark().colorScheme.copyWith(
              secondary: userSetting.themeData.colorScheme.secondary,
              primary: userSetting.themeData.colorScheme.primary),
        ),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales, // Add this line
      );
    });
  }
}
