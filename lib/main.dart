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
import 'dart:isolate';
import 'dart:ui';
import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:pixez/generated/l10n.dart';
import 'package:pixez/models/login_error_response.dart';
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

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  ReceivePort _port = ReceivePort();
  @override
  void didChangePlatformBrightness() {
    super.didChangePlatformBrightness();
    final Brightness brightness =
        WidgetsBinding.instance.window.platformBrightness;
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      systemNavigationBarIconBrightness:
          brightness == Brightness.light ? Brightness.dark : Brightness.light,
      systemNavigationBarColor: brightness == Brightness.light
          ? Color(0xFFFAFAFA)
          : Color(0xFF303030), //我的朋友，这边只能写死，我没招了
      statusBarColor: Colors.transparent,
    ));
  }

  @override
  void dispose() {
    IsolateNameServer.removePortNameMapping('downloader');
    saveStore?.cleanTasks();
    saveStore?.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    accountStore.fetch();
    userSetting.init();
    muteStore.fetchBanUserIds();
    muteStore.fetchBanIllusts();
    muteStore.fetchBanTags();
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
        final tasks =
            await FlutterDownloader.loadTasksWithRawQuery(query: queryString);
        if (tasks != null && tasks.isNotEmpty) {
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
      if (status == DownloadTaskStatus.canceled) {}
      if (status == DownloadTaskStatus.failed) {}
    });
    FlutterDownloader.registerCallback(downloadCallback);
  }

  static void downloadCallback(
      String id, DownloadTaskStatus status, int progress) {
    SendPort send = IsolateNameServer.lookupPortByName('downloader');
    if (send != null) send.send([id, status, progress]);
    final SendPort send1 = IsolateNameServer.lookupPortByName('downloader_pro');
    if (send1 != null) send1.send([id, status, progress]);
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
    return Observer(builder: (_) {
      return MaterialApp(
        navigatorObservers: [BotToastNavigatorObserver()],
        home: Builder(builder: (context) {
          return AnnotatedRegion<SystemUiOverlayStyle>(
              value: SystemUiOverlayStyle(
                systemNavigationBarIconBrightness:
                    MediaQuery.of(context).platformBrightness ==
                            Brightness.light
                        ? Brightness.dark
                        : Brightness.light,
                systemNavigationBarColor:
                    MediaQuery.of(context).platformBrightness ==
                            Brightness.light
                        ? Color(0xFFFAFAFA)
                        : Color(0xFF303030),
                statusBarColor: Colors.transparent,
              ),
              child: SplashPage());
        }),
        title: 'PixEz',
        builder: BotToastInit(),
        theme: userSetting.themeData,
        darkTheme: ThemeData(
          brightness: Brightness.dark,
          accentColor: userSetting.themeData.accentColor,
        ),
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
