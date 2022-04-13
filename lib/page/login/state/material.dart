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


import 'package:flutter/material.dart';
import 'package:pixez/i18n.dart';
import 'package:pixez/network/oauth_client.dart';
import 'package:pixez/page/about/about_page.dart';
import 'package:pixez/page/hello/setting/setting_quality_page.dart';
import 'package:pixez/page/login/login_page.dart';
import 'package:url_launcher/url_launcher.dart';

class MaterialLoginPageState extends LoginPageStateBase {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        bottomNavigationBar: BottomAppBar(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              IconButton(
                  icon: Icon(Icons.settings),
                  onPressed: () {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => SettingQualityPage()));
                  }),
              IconButton(
                  icon: Icon(Icons.message),
                  onPressed: () {
                    Navigator.of(context).push(
                        MaterialPageRoute(builder: (context) => AboutPage()));
                  })
            ],
          ),
        ),
        appBar: AppBar(
          elevation: 0.0,
          backgroundColor: Colors.transparent,
        ),
        extendBody: true,
        extendBodyBehindAppBar: true,
        body: Builder(builder: (context) {
          return _buildBody(context);
        }));
  }

  Widget _buildBody(BuildContext context) {
    return Theme(
      data: ThemeData(
          primaryColor: Theme.of(context).colorScheme.secondary,
          brightness: Theme.of(context).brightness),
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
                          Padding(
                            padding: EdgeInsets.all(10),
                          ),
                          ElevatedButton(
                              child: Text(
                                I18n.of(context).login,
                              ),
                              onPressed: () async {
                                try {
                                  String url =
                                      await OAuthClient.generateWebviewUrl();
                                  launch(url);
                                } catch (e) {}
                              }),
                          ElevatedButton(
                            onPressed: () async {
                              try {
                                String url =
                                    await OAuthClient.generateWebviewUrl(
                                        create: true);
                                launch(url);
                              } catch (e) {}
                            },
                            child: Text(I18n.of(context).dont_have_account),
                          ),
                          TextButton(
                            child: Text(
                              I18n.of(context).terms,
                            ),
                            onPressed: () async {
                              final url =
                                  'https://www.pixiv.net/terms/?page=term';
                              try {
                                await launch(url);
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
}
