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
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:pixez/generated/l10n.dart';
import 'package:pixez/main.dart';
import 'package:pixez/models/create_user_response.dart';
import 'package:pixez/page/about/about_page.dart';
import 'package:pixez/page/create/user/create_user_page.dart';
import 'package:pixez/page/hello/android_hello_page.dart';
import 'package:pixez/page/hello/hello_page.dart';
import 'package:pixez/page/hello/setting/setting_quality_page.dart';
import 'package:pixez/page/login/login_store.dart';
import 'package:url_launcher/url_launcher.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController userNameController = TextEditingController();
  TextEditingController passWordController = TextEditingController();
  LoginStore _loginStore = LoginStore();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    userNameController?.dispose();
    passWordController?.dispose();
    context = null;
    super.dispose();
  }

  BuildContext context;

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
          this.context = context;
          return _buildBody(context);
        }));
  }

  Widget _buildBody(BuildContext context) {
    return Theme(
      data: ThemeData(
          primaryColor: Theme.of(context).accentColor,
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
                          TextFormField(
                            maxLines: 1,
                            decoration: const InputDecoration(
                              icon: Icon(Icons.supervised_user_circle),
                              hintText: 'Pixiv id/Email',
                              labelText: 'Pixiv id/Email',
                            ),
                            controller: userNameController,
                            autofillHints: [AutofillHints.username],
                          ),
                          Padding(
                            padding: EdgeInsets.all(10),
                          ),
                          TextFormField(
                            obscureText: true,
                            maxLines: 1,
                            decoration: const InputDecoration(
                              icon: Icon(Icons.kitchen),
                              hintText: 'Password',
                              labelText: 'Password *',
                            ),
                            controller: passWordController,
                            autofillHints: [AutofillHints.password],
                          ),
                          Padding(
                            padding: EdgeInsets.all(10),
                          ),
                          Observer(builder: (_) {
                            return Visibility(
                              visible: _loginStore.errorMessage != null,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 4.0, horizontal: 0),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.redAccent,
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(4.0)),
                                  ),
                                  padding: EdgeInsets.all(4.0),
                                  child: Text(
                                    (_loginStore.errorMessage ?? "")
                                            .contains('103')
                                        ? ((_loginStore.errorMessage ?? "\n") +
                                            I18n.of(context)
                                                .login_error_message)
                                        : _loginStore.errorMessage ?? "",
                                    textAlign: TextAlign.start,
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                              ),
                            );
                          }),
                          RaisedButton(
                              color: Theme.of(context).primaryColor,
                              child: Text(
                                I18n.of(context).login,
                              ),
                              onPressed: () async {
                                if (userNameController.value.text.isEmpty ||
                                    userNameController.value.text.isEmpty)
                                  return;
                                BotToast.showCustomText(
                                    onlyOne: true,
                                    duration: Duration(seconds: 1),
                                    toastBuilder: (textCancel) => Align(
                                          alignment: Alignment(0, 0.8),
                                          child: Card(
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: <Widget>[
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.all(8.0),
                                                  child: Icon(
                                                    Icons.scatter_plot,
                                                  ),
                                                ),
                                                Padding(
                                                  padding: const EdgeInsets
                                                          .symmetric(
                                                      horizontal: 8.0,
                                                      vertical: 8.0),
                                                  child: Text(I18n.of(context)
                                                      .attempting_to_log_in),
                                                )
                                              ],
                                            ),
                                          ),
                                        ));
                                bool isAuth = await _loginStore.auth(
                                    userNameController.value.text.trim(),
                                    passWordController.value.text.trim());
                                if (isAuth) {
                                  accountStore.fetch();
                                  Navigator.of(context).pushAndRemoveUntil(
                                    MaterialPageRoute(
                                        builder: (BuildContext context) =>
                                            Platform.isIOS
                                                ? HelloPage()
                                                : AndroidHelloPage()),
                                    (route) => route == null,
                                  );
                                }
                              }),
                          RaisedButton(
                            onPressed: () async {
                              final result = await Navigator.of(context).push(
                                  MaterialPageRoute(
                                      builder: (BuildContext context) {
                                return CreateUserPage();
                              }));
                              if (result != null &&
                                  result is CreateUserResponse) {
                                userNameController.text =
                                    result.body.userAccount;
                                passWordController.text = result.body.password;

                                bool isAuth = await _loginStore.auth(
                                    userNameController.value.text.trim(),
                                    passWordController.value.text.trim(),
                                    deviceToken: result.body.deviceToken);
                                if (isAuth) {
                                  accountStore.fetch();
                                  Navigator.of(context).pushAndRemoveUntil(
                                    MaterialPageRoute(
                                        builder: (BuildContext context) =>
                                            Platform.isIOS
                                                ? HelloPage()
                                                : AndroidHelloPage()),
                                    (route) => route == null,
                                  );
                                }
                              }
                            },
                            child: Text(I18n.of(context).dont_have_account),
                          ),
                          FlatButton(
                            child: Text(
                              I18n.of(context).terms,
                            ),
                            onPressed: () async {
                              final url =
                                  'https://www.pixiv.net/terms/?page=term';
                              if (await canLaunch(url)) {
                                await launch(url);
                              } else {}
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
