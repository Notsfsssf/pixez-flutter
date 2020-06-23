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

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_displaymode/flutter_displaymode.dart';
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
  int displayMode;
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
    displayMode = prefs.getInt('display_mode');
    if (Platform.isAndroid) {
      if (path == null)
        path = (await platform.invokeMethod('get_path')) as String;
      await prefs.setString("store_path", path);
      var modeList = await FlutterDisplayMode.supported;
      if (displayMode != null && modeList.length > displayMode) {
        await FlutterDisplayMode.setMode(modeList[displayMode]);
      }
    }
    debugPrint("path==========${path}");
    languageNum = prefs.getInt(LANGUAGE_NUM_KEY) ?? 0;
    format = prefs.getString(SAVE_FORMAT_KEY) ?? intialFormat;
    debugPrint("language:${languageNum}");
    ApiClient.Accept_Language = languageList[languageNum];
    I18n.load(I18n.delegate.supportedLocales[languageNum]);
  }

  @action
  setDisplayMode(int value) async {
    await prefs.setInt('display_mode', value);
    displayMode = value;
  }

  @action
  Future<void> setSingleFolder(bool value) async {
    await prefs.setBool(SINGLE_FOLDER_KEY, value);
    singleFolder = value;
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
