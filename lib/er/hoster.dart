import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pixez/component/pixiv_image.dart';
import 'package:pixez/er/lprinter.dart';
import 'package:pixez/main.dart';
import 'package:path/path.dart' as Path;

class Hoster {
  static Map<String, dynamic> _map = Map();
  static Map<String, dynamic> _constMap = {
    "app-api.pixiv.net": "210.140.131.199",
    "oauth.secure.pixiv.net": "210.140.131.199",
    "i.pximg.net": "210.140.92.143",
    "s.pximg.net": "210.140.92.140",
    "doh": "1.0.0.1"
  };

  static init() async {
    try {
      final cacheDir = await getApplicationSupportDirectory();
      String fileName = Path.join(cacheDir.path, 'host.json');
      final jsonFile = File(fileName);
      if (!jsonFile.existsSync()) {
        jsonFile.createSync();
        String data = await rootBundle.loadString('assets/json/host.json');
        jsonFile.writeAsStringSync(data, flush: true);
      } else {}
      String data = jsonFile.readAsStringSync();
      if (data.isEmpty) {
        jsonFile.deleteSync();
        init();
        return;
      }
      final jsonData = json.decode(data);
      _map.addAll(jsonData);
      LPrinter.d(_map);
    } catch (e) {
      LPrinter.d(e);
    }
  }

  static final String _hostJsonUrl =
      "https://cdn.jsdelivr.net/gh/Notsfsssf/pixez-flutter@master/assets/json/host.json";

  static syncRemote() async {
    try {
      LPrinter.d("sync remote =========");
      final dio = Dio(BaseOptions(baseUrl: _hostJsonUrl));
      Response response = await dio.get("");
      String data = json.encode(response.data!);
      final cacheDir = await getApplicationSupportDirectory();
      String fileName = Path.join(cacheDir.path, 'host.json');
      final jsonFile = File(fileName);
      if (jsonFile.existsSync()) {
        jsonFile.deleteSync();
      }
      jsonFile.createSync();
      jsonFile.writeAsStringSync(data, flush: true);
      _map.clear();
      _map.addAll(response.data);
      LPrinter.d(_map);
    } catch (e) {
      LPrinter.d(e);
    }
  }

  static String iPximgNet() {
    final key = "i.pximg.net";
    final result = _map[key];
    if (result == null) return _constMap[key];
    return result;
  }

  static String sPximgNet() {
    final key = "s.pximg.net";
    final result = _map[key];
    if (result == null) return _constMap[key];
    return result;
  }

  static String doh() {
    final key = "doh";
    final result = _map[key];
    if (result == null) return _constMap[key];
    return result;
  }

  static String oauth() {
    final key = "oauth.secure.pixiv.net";
    final result = _map[key];
    if (result == null) return _constMap[key];
    return result;
  }

  static String api() {
    final key = "app-api.pixiv.net";
    final result = _map[key];
    if (result == null) return _constMap[key];
    return result;
  }

  static String host(String url) {
    try {} catch (e) {}
    return splashStore.host;
  }

  static Map<String, String> header({String? url}) {
    Map<String, String> map = {
      "referer": "https://app-api.pixiv.net/",
      "User-Agent": "PixivIOSApp/5.8.0",
      "Host": "i.pximg.net"
    };
    if (url != null) {
      String host = Uri.parse(url).host;
      if (host == ImageHost) {
        if (userSetting.disableBypassSni) return map;
        map['Host'] = userSetting.pictureSource!;
      } else {
        if (userSetting.pictureSource == ImageHost) {
          map['Host'] = host;
        } else {
          map['Host'] = userSetting.pictureSource!;
        }
      }
    }
    return map;
  }
}
