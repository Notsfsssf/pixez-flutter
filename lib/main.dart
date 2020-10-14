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
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:pixez/generated/l10n.dart';
import 'package:pixez/page/history/history_store.dart';
import 'package:pixez/page/splash/splash_page.dart';
import 'package:pixez/store/account_store.dart';
import 'package:pixez/store/mute_store.dart';
import 'package:pixez/store/save_store.dart';
import 'package:pixez/store/tag_history_store.dart';
import 'package:pixez/store/top_store.dart';
import 'package:pixez/store/user_setting.dart';

final UserSetting userSetting = UserSetting();
final SaveStore saveStore = SaveStore();
final MuteStore muteStore = MuteStore();
final AccountStore accountStore = AccountStore();
final TagHistoryStore tagHistoryStore = TagHistoryStore();
final HistoryStore historyStore = HistoryStore();
final TopStore topStore = TopStore();

main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void dispose() {
    saveStore?.dispose();
    super.dispose();
  }

  @override
  void initState() {
    accountStore.fetch();
    userSetting.init();
    muteStore.fetchBanUserIds();
    muteStore.fetchBanIllusts();
    muteStore.fetchBanTags();
    initMethod();
    super.initState();
  }

  initMethod() async {}

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
    return Observer(builder: (_) {
      return MaterialApp(
        navigatorObservers: [BotToastNavigatorObserver()],
        home: Builder(builder: (context) {
          return AnnotatedRegion<SystemUiOverlayStyle>(
              value: SystemUiOverlayStyle(
                statusBarColor: Colors.transparent,
              ),
              child: SplashPage());
        }),
        title: 'PixEz',
        builder: BotToastInit(),
        themeMode: userSetting.themeMode,
        theme: userSetting.themeData,
        darkTheme: ThemeData.dark().copyWith(
            accentColor: userSetting.themeData.accentColor,
            indicatorColor: userSetting.themeData.accentColor),
        supportedLocales: I18n.delegate.supportedLocales,
        localizationsDelegates: [
          I18n.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate
        ],
      );
    });
  }
}
