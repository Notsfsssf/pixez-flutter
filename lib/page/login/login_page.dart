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

import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/widgets.dart';
import 'package:pixez/constants.dart';
import 'package:pixez/custom_tab_plugin.dart';
import 'package:pixez/er/leader.dart';
import 'package:pixez/main.dart';
import 'package:pixez/page/login/state/fluent.dart';
import 'package:pixez/page/login/state/material.dart';
import 'package:pixez/page/webview/webview_page.dart';
import 'package:pixez/weiss_plugin.dart';

class LoginPage extends StatefulWidget {
  @override
  LoginPageStateBase createState() {
    if (Constants.isFluentUI)
      return FluentLoginPageState();
    else
      return MaterialLoginPageState();
  }
}

abstract class LoginPageStateBase extends State<LoginPage> {
  // TextEditingController userNameController = TextEditingController();
  // TextEditingController passWordController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    // userNameController.dispose();
    // passWordController.dispose();
    super.dispose();
  }

  launch(url) async {
    if (Platform.isIOS) {
      final result = await Leader.push(
          context,
          WebViewPage(
            url: url,
          ));
      if (result == "OK") {
        Leader.pushUntilHome(context);
      }
      return;
    }
    if (!userSetting.disableBypassSni) {
      // await WeissServer.listener();
      await WeissPlugin.start();
      await WeissPlugin.proxy();
      Leader.push(
          context,
          WebViewPage(
            url: url,
          ));
    } else {
      try {
        CustomTabPlugin.launch(url);
      } catch (e) {
        BotToast.showText(text: e.toString());
      }
    }
  }
}
