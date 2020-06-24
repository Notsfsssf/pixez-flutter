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

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pixez/component/painter_avatar.dart';
import 'package:pixez/generated/l10n.dart';
import 'package:pixez/main.dart';
import 'package:pixez/page/about/about_page.dart';
import 'package:pixez/page/account/edit/account_edit_page.dart';
import 'package:pixez/page/account/select/account_select_page.dart';
import 'package:pixez/page/hello/setting/setting_quality_page.dart';
import 'package:pixez/page/history/history_page.dart';
import 'package:pixez/page/login/login_page.dart';
import 'package:pixez/page/platform/platform_page.dart';
import 'package:pixez/page/progress/progress_page.dart';
import 'package:pixez/page/saucenao/saucenao_page.dart';
import 'package:pixez/page/shield/shield_page.dart';

class SettingPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0.0,
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        actions: (Platform.isAndroid)
            ? <Widget>[
                IconButton(
                    icon: Icon(Icons.youtube_searched_for),
                    onPressed: () {
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => SauceNaoPage()));
                    }),
                IconButton(
                    icon: Icon(Icons.settings_ethernet),
                    onPressed: () {
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => PlatformPage()));
                    })
              ]
            : [],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Observer(builder: (context) {
                  if (accountStore.now != null)
                    return SingleChildScrollView(
                      child: Column(
                        children: <Widget>[
                          ListTile(
                            leading: PainterAvatar(
                              url: accountStore.now.userImage,
                              id: int.parse(accountStore.now.userId),
                            ),
                            title: Text(accountStore.now.name),
                            subtitle: Text(accountStore.now.mailAddress),
                            onTap: () {
                              Navigator.of(context, rootNavigator: true)
                                  .push(MaterialPageRoute(builder: (_) {
                                return AccountSelectPage();
                              }));
                            },
                          ),
                          ListTile(
                            leading: Icon(Icons.account_box),
                            title: Text(I18n.of(context).Account_Message),
                            onTap: () {
                              Navigator.of(context).push(MaterialPageRoute(
                                  builder: (BuildContext context) =>
                                      AccountEditPage()));
                            },
                          )
                        ],
                      ),
                    );
                  return Container();
                }),
                Divider(),
                Column(
                  children: <Widget>[
                    ListTile(
                      leading: Icon(Icons.history),
                      title: Text(I18n.of(context).History_record),
                      onTap: () {
                        Navigator.of(context).push(
                            MaterialPageRoute(builder: (BuildContext context) {
                          return HistoryPage();
                        }));
                      },
                    ),
                    ListTile(
                      leading: Icon(Icons.settings),
                      title: Text(I18n.of(context).Quality_Setting),
                      onTap: () {
                        Navigator.of(context).push(
                            MaterialPageRoute(builder: (BuildContext context) {
                          return SettingQualityPage();
                        }));
                      },
                    ),
                    ListTile(
                      leading: Icon(Icons.block),
                      title: Text(I18n.of(context).Shielding_settings),
                      onTap: () => Navigator.of(context).push(MaterialPageRoute(
                          builder: (BuildContext context) => ShieldPage())),
                    ),
                    ListTile(
                      leading: Icon(Icons.description),
                      title: Text(I18n.of(context).Task_progress),
                      onTap: () => Navigator.of(context).push(MaterialPageRoute(
                          builder: (BuildContext context) => ProgressPage())),
                    ),
                    ListTile(
                      onTap: () async {
                        final result = await showDialog(
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: Text(I18n.of(context).Warning),
                                content: Text(I18n.of(context).Clear_message),
                                actions: <Widget>[
                                  FlatButton(
                                    child: Text("OK"),
                                    onPressed: () {
                                      Navigator.of(context).pop("OK");
                                    },
                                  ),
                                  FlatButton(
                                    child: Text("CANCEL"),
                                    onPressed: () {
                                      Navigator.of(context).pop("CANCEL");
                                    },
                                  )
                                ],
                              );
                            },
                            context: context);
                        switch (result) {
                          case "OK":
                            {
                              Directory tempDir = await getTemporaryDirectory();
                              tempDir.deleteSync(recursive: true);
                            }
                            break;
                        }
                      },
                      title: Text(I18n.of(context).Clearn_cache),
                      leading: Icon(Icons.clear),
                    ),
                  ],
                ),
                Divider(),
                Column(
                  children: <Widget>[
                    ListTile(
                      leading: Icon(Icons.message),
                      title: Text(I18n.of(context).About),
                      onTap: () {
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => AboutPage()));
                      },
                    ),
                    Observer(builder: (context) {
                      if (accountStore.now != null)
                        return ListTile(
                          leading: Icon(Icons.arrow_back),
                          title: Text(I18n.of(context).Logout),
                          onTap: () async {
                            /*                            final result = await showCupertinoDialog(
                                builder: (BuildContext context) {
                                  return CupertinoAlertDialog(
                                    title: Text(I18n.of(context).Logout),
                                    content: Text(
                                        I18n.of(context).Logout_message),
                                    actions: <Widget>[
                                      CupertinoDialogAction(
                                        child: Text("OK"),
                                        onPressed: () {
                                          Navigator.of(context).pop("OK");
                                        },
                                      ),
                                      CupertinoDialogAction(
                                        child: Text("CANCEL"),
                                        onPressed: () {
                                          Navigator.of(context)
                                              .pop("CANCEL");
                                        },
                                        isDestructiveAction: true,
                                      )
                                    ],
                                  );
                                },
                                context: context);*/
                            final result = await showDialog(
                                context: context,
                                builder: (context) {
                                  return AlertDialog(
                                    title: Text(I18n.of(context).Logout),
                                    actions: <Widget>[
                                      FlatButton(
                                        child: Text("OK"),
                                        onPressed: () {
                                          Navigator.of(context).pop("OK");
                                        },
                                      ),
                                      FlatButton(
                                        child: Text("CANCEL"),
                                        onPressed: () {
                                          Navigator.of(context).pop("CANCEL");
                                        },
                                      )
                                    ],
                                  );
                                });
                            switch (result) {
                              case "OK":
                                {
                                  accountStore.deleteAll();
                                }
                                break;
                              case "CANCEL":
                                {}
                                break;
                            }
                          },
                        );
                      else
                        return ListTile(
                          leading: Icon(Icons.arrow_back),
                          title: Text(I18n.of(context).Login),
                          onTap: () => Navigator.of(context).push(
                              MaterialPageRoute(
                                  builder: (context) => LoginPage())),
                        );
                    })
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
