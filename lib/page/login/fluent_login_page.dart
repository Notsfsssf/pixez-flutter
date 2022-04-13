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
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/widgets.dart';
import 'package:pixez/custom_tab_plugin.dart';
import 'package:pixez/er/leader.dart';
import 'package:pixez/i18n.dart';
import 'package:pixez/main.dart';
import 'package:pixez/network/oauth_client.dart';
import 'package:pixez/page/about/about_page.dart';
import 'package:pixez/page/hello/setting/setting_quality_page.dart';
import 'package:pixez/page/webview/webview_page.dart';
import 'package:pixez/weiss_plugin.dart';
import 'package:url_launcher/url_launcher.dart';

class FluentLoginPage extends StatefulWidget {
  @override
  _FluentLoginPageState createState() => _FluentLoginPageState();
}

class _FluentLoginPageState extends State<FluentLoginPage> {
  TextEditingController userNameController = TextEditingController();
  TextEditingController passWordController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    userNameController.dispose();
    passWordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        // bottomNavigationBar: BottomAppBar(
        //   child: Row(
        //     mainAxisAlignment: MainAxisAlignment.end,
        //     children: <Widget>[
        //       IconButton(
        //           icon: Icon(Icons.settings),
        //           onPressed: () {
        //             Navigator.of(context).push(MaterialPageRoute(
        //                 builder: (context) => SettingQualityPage()));
        //           }),
        //       IconButton(
        //           icon: Icon(Icons.message),
        //           onPressed: () {
        //             Navigator.of(context).push(
        //                 MaterialPageRoute(builder: (context) => AboutPage()));
        //           })
        //     ],
        //   ),
        // ),
        // appBar: AppBar(
        //   elevation: 0.0,
        //   backgroundColor: Colors.transparent,
        // ),
        // extendBody: true,
        // extendBodyBehindAppBar: true,
        child: Builder(builder: (context) {
      return _buildBody(context);
    }));
  }

  Widget _buildBody(BuildContext context) {
    return FluentTheme(
      data: ThemeData(
          accentColor: FluentTheme.of(context).accentColor,
          brightness: FluentTheme.of(context).brightness),
      child: ContentDialog(
        title: Text("Login"),
        actions: [
          Button(
            onPressed: () async {
              try {
                String url = await OAuthClient.generateWebviewUrl(create: true);
                _launch(url);
              } catch (e) {}
            },
            child: Text(I18n.of(context).dont_have_account),
          ),
          FilledButton(
              child: Text(
                I18n.of(context).login,
              ),
              onPressed: () async {
                try {
                  String url = await OAuthClient.generateWebviewUrl();
                  _launch(url);
                } catch (e) {}
              }),
        ],
        content: SingleChildScrollView(
            padding: EdgeInsets.all(0),
            child: Column(
              children: <Widget>[
                Container(
                  height: 20,
                ),
                Image.asset(
                  'assets/images/icon.png',
                  height: 80,
                  width: 80,
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.all(10),
                      ),
                      TextButton(
                        child: Text(
                          I18n.of(context).terms,
                        ),
                        onPressed: () async {
                          final url = 'https://www.pixiv.net/terms/?page=term';
                          try {
                            await launch(url);
                          } catch (e) {}
                        },
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: <Widget>[
                          IconButton(
                              icon: Icon(FluentIcons.settings),
                              onPressed: () {
                                Navigator.of(context).push(FluentPageRoute(
                                    builder: (context) =>ContentDialog(
                                      content: SettingQualityPage(),
                                    )));
                              }),
                          IconButton(
                              icon: Icon(FluentIcons.message),
                              onPressed: () {
                                Navigator.of(context).push(FluentPageRoute(
                                    builder: (context) => ContentDialog(
                                      content: AboutPage(),
                                    )));
                              })
                        ],
                      ),
                    ],
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                  ),
                ),
              ],
            )),
      ),
    );
  }

  _launch(url) async {
    try {
      await launch(url);
    } catch (e) {
      BotToast.showText(text: e.toString());
    }
  }
}
