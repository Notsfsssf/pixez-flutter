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

import 'package:dio/dio.dart';
import 'package:flutter/widgets.dart';
import 'package:pixez/constants.dart';
import 'package:pixez/er/updater.dart';
import 'package:pixez/page/hello/setting/state/fluent_setting_state.dart';
import 'package:pixez/page/hello/setting/state/material_setting_state.dart';

class SettingPage extends StatefulWidget {
  const SettingPage({Key? key}) : super(key: key);

  @override
  SettingPageStateBase createState() {
    if (Constants.isFluentUI)
      return FluentSettingPageState();
    else
      return MaterialSettingPageState();
  }
}

abstract class SettingPageStateBase extends State<SettingPage> {
  @override
  void initState() {
    super.initState();
    initMethod();
  }

  bool hasNewVersion = false;

  initMethod() async {
    if (Constants.isGooglePlay || Platform.isIOS) return;
    if (Updater.result != Result.timeout) {
      bool hasNew = Updater.result == Result.yes;
      if (mounted)
        setState(() {
          hasNewVersion = hasNew;
        });
      return;
    }
    Result result = await Updater.check();
    switch (result) {
      case Result.yes:
        if (mounted) {
          setState(() {
            hasNewVersion = true;
          });
        }
        break;
      default:
        if (mounted) {
          setState(() {
            hasNewVersion = false;
          });
        }
    }
  }

  showMessage(BuildContext context) async {
    final link =
        "https://cdn.jsdelivr.net/gh/Notsfsssf/pixez-flutter@master/assets/json/host.json";
    try {
      final dio = Dio(BaseOptions(baseUrl: link));
      Response response = await dio.get("");
      final data = response.data as Map;
      print("${data['doh']}");
    } catch (e) {
      print(e);
    }
  }
}
