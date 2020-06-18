import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobx/mobx.dart';
import 'package:pixez/generated/l10n.dart';
import 'package:pixez/network/api_client.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'user_setting.g.dart';

class UserSetting = _UserSettingBase with _$UserSetting;

abstract class _UserSettingBase with Store {
  static const platform = const MethodChannel('com.perol.dev/save');
  SharedPreferences prefs;
  static const String ZOOM_QUALITY_KEY = "zoom_quality";
  static const String SINGLE_FOLDER_KEY = "single_folder";
  static const String SAVE_FORMAT_KEY = "save_format";
  static const String LANGUAGE_NUM_KEY = "language_num";
  @observable
  int zoomQuality = 0;
  @observable
  int languageNum = 0;
  @observable
  bool singleFolder = false;
  @observable
  String path = "";
  @observable
  String format = "";
  static const String intialFormat = "{illust_id}_p{part}";

  @action
  Future<void> init() async {
    prefs = await SharedPreferences.getInstance();
    zoomQuality = prefs.getInt(ZOOM_QUALITY_KEY) ?? 0;
    singleFolder = prefs.getBool(SINGLE_FOLDER_KEY) ?? false;
    path = prefs.getString("store_path");
    if (Platform.isAndroid) {
      if (path == null)
        path = (await platform.invokeMethod('get_path')) as String;
      await prefs.setString("store_path", path);
    }
    debugPrint("path==========${path}");
    languageNum = prefs.getInt(LANGUAGE_NUM_KEY) ?? 0;
    format = prefs.getString(SAVE_FORMAT_KEY) ?? intialFormat;
    debugPrint("language:${languageNum}");
    ApiClient.Accept_Language = languageList[languageNum];
    I18n.load(I18n.delegate.supportedLocales[languageNum]);
  }

  @action
  Future<void> setSingleFolder(bool value) async {
    singleFolder = value;
    await prefs.setBool(SINGLE_FOLDER_KEY, value);
  }

  @action
  Future<String> getPath() async {
    path = prefs.getString("store_path");
    return path;
  }

  @action
  setPath(result) {
    path = result;
  }

  final languageList = ['en-US', 'zh-CN', 'zh-TW'];

  @action
  setLanguageNum(int value) async {
    await prefs.setInt(LANGUAGE_NUM_KEY, value);
    languageNum = value;
    ApiClient.Accept_Language = languageList[languageNum];
    final local = I18n.delegate.supportedLocales[languageNum];
    I18n.load(local);
  }

  @action
  setFormat(String format) async {
    await prefs.setString(SAVE_FORMAT_KEY, format.trim());
    this.format = format;
  }

  @action
  Future<void> change(int value) async {
    await prefs.setInt(ZOOM_QUALITY_KEY, value);
    zoomQuality = value;
  }
}
