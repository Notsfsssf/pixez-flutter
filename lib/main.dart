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
import 'dart:typed_data';
import 'dart:ui';

import 'package:bot_toast/bot_toast.dart';
import 'package:dio/dio.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:pixez/er/lprinter.dart';
import 'package:pixez/generated/l10n.dart';
import 'package:pixez/models/account.dart';
import 'package:pixez/models/recommend.dart';
import 'package:pixez/network/api_client.dart';
import 'package:pixez/network/onezero_client.dart';
import 'package:pixez/page/history/history_store.dart';
import 'package:pixez/page/splash/splash_page.dart';
import 'package:pixez/page/splash/splash_store.dart';
import 'package:pixez/store/account_store.dart';
import 'package:pixez/store/book_tag_store.dart';
import 'package:pixez/store/mute_store.dart';
import 'package:pixez/store/save_store.dart';
import 'package:pixez/store/tag_history_store.dart';
import 'package:pixez/store/top_store.dart';
import 'package:pixez/store/user_setting.dart';
import 'package:shared_preferences/shared_preferences.dart';

final UserSetting userSetting = UserSetting();
final SaveStore saveStore = SaveStore();
final MuteStore muteStore = MuteStore();
final AccountStore accountStore = AccountStore();
final TagHistoryStore tagHistoryStore = TagHistoryStore();
final HistoryStore historyStore = HistoryStore();
final TopStore topStore = TopStore();
final BookTagStore bookTagStore = BookTagStore();
final SplashStore splashStore = SplashStore(OnezeroClient());
main() {
  initAppWidget();
  runApp(MyApp());
}

initAppWidget() {
  if (Platform.isAndroid) {
    WidgetsFlutterBinding.ensureInitialized();
    const MethodChannel channel = MethodChannel('com.example.app/widget');
    final CallbackHandle callback =
        PluginUtilities.getCallbackHandle(onWidgetUpdate);
    final handle = callback.toRawHandle();
    channel.invokeMethod('initialize', handle);
  }
}

void onWidgetUpdate() {
  WidgetsFlutterBinding.ensureInitialized();
  const MethodChannel channel = MethodChannel('com.example.app/widget');
  ApiClient apiClient = ApiClient();
  channel.setMethodCallHandler(
    (call) async {
      if (call.method == 'update') {
        try {
          const NOW_POSITION = 'now_position';
          LPrinter.d("setMethodCallHandler");
          final id = call.arguments;
          SharedPreferences pref = await SharedPreferences.getInstance();
          int position = pref.getInt(NOW_POSITION) ?? 0; //Position Zero!
          AccountProvider accountProvider = AccountProvider();
          await accountProvider.open();
          List<AccountPersist> accounts =
              await accountProvider.getAllAccount(); //bug  token refresh
          Response response;
          if (accounts.isNotEmpty)
            response = await apiClient.getIllustRanking("day", null);
          else
            response = await apiClient.walkthroughIllusts();
          Recommend recommend = Recommend.fromJson(response.data);
          print('on Dart ${call.method}!:${recommend.illusts[position].title}');
          Dio dio = Dio(BaseOptions(headers: {
            "referer": "https://app-api.pixiv.net/",
            "User-Agent": "PixivIOSApp/5.8.0",
            "Host": 'i.pximg.net'
          }, responseType: ResponseType.bytes));
          String url = recommend.illusts[position].imageUrls.squareMedium;
          int fPosition = position + 1;
          if (fPosition >= recommend.illusts.length) {
            fPosition = 0;
          }
          await pref.setInt(NOW_POSITION, fPosition);
          LPrinter.d("setMethodCallHandler:Success");
          return {
            'code': 200,
            'message': 'success',
            'id': id,
            'iid': recommend.illusts[position].id,
            'value': url,
          };
        } catch (e) {
          LPrinter.d("setMethodCallHandler:Fail=$e");
          return {'code': 400, 'message': e.toString()};
        }
      }
    },
  );
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
    bookTagStore.init();
    muteStore.fetchBanUserIds();
    muteStore.fetchBanIllusts();
    muteStore.fetchBanTags();
    initMethod();
    super.initState();
  }

  initMethod() async {
    if (userSetting.disableBypassSni) return;
    HttpClient client = ExtendedNetworkImageProvider.httpClient as HttpClient;
    client.badCertificateCallback =
        (X509Certificate cert, String host, int port) {
      return true;
    };
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
