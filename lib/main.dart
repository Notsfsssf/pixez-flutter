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
import 'dart:isolate';
import 'dart:math';
import 'dart:ui';
import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:pixez/constraint.dart';
import 'package:pixez/generated/l10n.dart';
import 'package:pixez/page/history/history_store.dart';
import 'package:pixez/page/splash/splash_page.dart';
import 'package:pixez/store/account_store.dart';
import 'package:pixez/store/mute_store.dart';
import 'package:pixez/store/save_store.dart';
import 'package:pixez/store/tag_history_store.dart';
import 'package:pixez/store/user_setting.dart';
import 'package:provider/provider.dart';

final UserSetting userSetting = UserSetting();
final SaveStore saveStore = SaveStore();
final MuteStore muteStore = MuteStore();
final AccountStore accountStore = AccountStore();
final TagHistoryStore tagHistoryStore = TagHistoryStore();
final HistoryStore historyStore = HistoryStore();

main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FlutterDownloader.initialize(debug: false);
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ReceivePort _port = ReceivePort();

  @override
  void dispose() {
    IsolateNameServer.removePortNameMapping('downloader');
    super.dispose();
  }

  static int time;

  @override
  void initState() {
    accountStore.fetch();
    userSetting.init();
    muteStore.fetchBanUserIds();
    muteStore.fetchBanIllusts();
    muteStore.fetchBanTags();
    time = _port.hashCode;
    initMethod();
    super.initState();
  }

  initMethod() async {
    bool success =
        IsolateNameServer.registerPortWithName(_port.sendPort, 'downloader');
    if (!success) return;
    _port.listen((dynamic data) async {
      String id = data[0];
      DownloadTaskStatus status = data[1];
      if (status == DownloadTaskStatus.complete) {
        String queryString = 'SELECT * FROM task WHERE task_id=\'${id}\'';
        final tasks = await FlutterDownloader.loadTasksWithRawQuery(
            query: queryString); //迷惑行为
        if (tasks != null && tasks.isNotEmpty) {
          saveStore.urls.remove(tasks.first.url);
          String fullPath =
              '${tasks.first.savedDir}${Platform.pathSeparator}${tasks.first.filename}';
          File file = File(fullPath);
          final uint8list = await file.readAsBytes();
          final data = saveStore.maps[id];
          await saveStore.saveToGallery(uint8list, data.illusts, data.fileName);
          saveStore.streamController
              .add(SaveStream(SaveState.SUCCESS, saveStore.maps[id].illusts));
        }
      }
      if (status == DownloadTaskStatus.canceled) {
        await removeUrl(id);
      }
      if (status == DownloadTaskStatus.failed) {
        await removeUrl(id);
      }
    });
    FlutterDownloader.registerCallback(downloadCallback);
  }

  removeUrl(String id) async {
    saveStore.maps[id] = null;
    String queryString = 'SELECT * FROM task WHERE task_id=\'${id}\'';
    final tasks =
        await FlutterDownloader.loadTasksWithRawQuery(query: queryString);
    if (tasks != null && tasks.isNotEmpty) {
      saveStore.urls.remove(tasks.first.url);
    }
  }

  static void downloadCallback(
      String id, DownloadTaskStatus status, int progress) {
    SendPort send = IsolateNameServer.lookupPortByName('downloader');
    if (send != null) send.send([id, status, progress]);
    final SendPort send1 = IsolateNameServer.lookupPortByName('downloader_pro');
    if (send1 != null) send1.send([id, status, progress]);
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider(
          create: (BuildContext context) => saveStore,
        ),
      ],
      child: MaterialApp(
        navigatorObservers: [BotToastNavigatorObserver()],
        home: AnnotatedRegion<SystemUiOverlayStyle>(
            value: SystemUiOverlayStyle(statusBarColor: Colors.transparent),
            child: SplashPage()),
        title: 'PixEz',
        builder: BotToastInit(),
        theme: ThemeData(
          brightness: Brightness.light,
          primaryColor: Colors.cyan[500],
          accentColor: Colors.cyan[400],
          indicatorColor: Colors.cyan[500],
        ),
        darkTheme: ThemeData(
          brightness: Brightness.dark,
          accentColor: Colors.cyan[500],
        ),
        supportedLocales: I18n.delegate.supportedLocales,
        localizationsDelegates: [
          I18n.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate
        ],
      ),
    );
  }
}
