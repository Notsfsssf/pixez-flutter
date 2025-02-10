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

import 'package:bot_toast/bot_toast.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:pixez/custom_tab_plugin.dart';
import 'package:pixez/er/leader.dart';
import 'package:pixez/fluent/page/login/token_page.dart';
import 'package:pixez/fluent/page/webview/webview_page.dart';
import 'package:pixez/i18n.dart';
import 'package:pixez/main.dart';
import 'package:pixez/network/oauth_client.dart';
import 'package:pixez/fluent/page/about/about_page.dart';
import 'package:pixez/fluent/page/hello/setting/setting_quality_page.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
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
    return ScaffoldPage(
        bottomBar: CommandBar(
          primaryItems: [
            CommandBarButton(
                icon: Icon(FluentIcons.settings),
                onPressed: () {
                  Leader.push(
                    context,
                    SettingQualityPage(),
                    icon: Icon(FluentIcons.settings),
                    title: Text(I18n.of(context).quality_setting),
                  );
                }),
            CommandBarButton(
                icon: Icon(FluentIcons.message),
                onPressed: () {
                  Leader.push(
                    context,
                    AboutPage(),
                    icon: Icon(FluentIcons.message),
                    title: Text(I18n.of(context).about),
                  );
                })
          ],
        ),
        content: Builder(builder: (context) {
          return _buildBody(context);
        }));
  }

  Widget _buildBody(BuildContext context) {
    return FluentTheme(
      data: FluentThemeData(
          accentColor: FluentTheme.of(context).accentColor,
          brightness: FluentTheme.of(context).brightness),
      child: Padding(
        padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
        child: SingleChildScrollView(
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
                Padding(
                  padding: EdgeInsets.only(bottom: 20),
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: AutofillGroup(
                      child: Column(
                        children: <Widget>[
                          SizedBox(height: 10),
                          FilledButton(
                              child: Text(
                                I18n.of(context).login,
                              ),
                              onPressed: () async {
                                try {
                                  String url =
                                      await OAuthClient.generateWebviewUrl();
                                  _launch(url);
                                } catch (e) {}
                              }),
                          SizedBox(height: 4),
                          FilledButton(
                            onPressed: () async {
                              try {
                                String url =
                                    await OAuthClient.generateWebviewUrl(
                                        create: true);
                                _launch(url);
                              } catch (e) {}
                            },
                            child: Text(I18n.of(context).dont_have_account),
                          ),
                          SizedBox(height: 4),
                          OutlinedButton(
                            onPressed: () async {
                              Leader.push(context, TokenPage());
                            },
                            child: Text("Token"),
                          ),
                          SizedBox(height: 4),
                          HyperlinkButton(
                            child: Text(
                              I18n.of(context).terms,
                            ),
                            onPressed: () async {
                              final url =
                                  'https://www.pixiv.net/terms/?page=term';
                              try {
                                await _launch(url);
                              } catch (e) {}
                            },
                          ),
                        ],
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                      ),
                    ),
                  ),
                ),
              ],
            )),
      ),
    );
  }

  _launch(url) async {
    if (!userSetting.disableBypassSni) {
      // await WeissServer.listener();
      // await WeissPlugin.start();
      // await WeissPlugin.proxy();
      Leader.push(
        context,
        WebViewPage(url: url),
        icon: Icon(FluentIcons.signin),
        title: Text(I18n.of(context).login),
      );
    } else {
      try {
        CustomTabPlugin.launch(url);
      } catch (e) {
        BotToast.showText(text: e.toString());
      }
    }
  }
}
