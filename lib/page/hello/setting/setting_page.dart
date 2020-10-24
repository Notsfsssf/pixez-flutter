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
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pixez/component/new_version_chip.dart';
import 'package:pixez/component/painter_avatar.dart';
import 'package:pixez/constants.dart';
import 'package:pixez/er/leader.dart';
import 'package:pixez/er/updater.dart';
import 'package:pixez/generated/l10n.dart';
import 'package:pixez/main.dart';
import 'package:pixez/page/about/about_page.dart';
import 'package:pixez/page/account/edit/account_edit_page.dart';
import 'package:pixez/page/account/select/account_select_page.dart';
import 'package:pixez/page/book/tag/book_tag_page.dart';
import 'package:pixez/page/hello/setting/setting_quality_page.dart';
import 'package:pixez/page/history/history_page.dart';
import 'package:pixez/page/login/login_page.dart';
import 'package:pixez/page/shield/shield_page.dart';
import 'package:pixez/page/task/job_page.dart';
import 'package:pixez/page/theme/theme_page.dart';

class SettingPage extends StatefulWidget {
  const SettingPage({Key key}) : super(key: key);

  @override
  _SettingPageState createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: AnimationLimiter(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: AnimationConfiguration.toStaggeredList(
                    childAnimationBuilder: (widget) => SlideAnimation(
                      horizontalOffset: 50.0,
                      child: FadeInAnimation(child: widget),
                    ),
                    children: <Widget>[
                      AppBar(
                        elevation: 0.0,
                        automaticallyImplyLeading: false,
                        backgroundColor: Colors.transparent,
                        actions: [
                          IconButton(
                            icon: Icon(
                              Icons.palette,
                              color:
                                  Theme.of(context).textTheme.bodyText1.color,
                            ),
                            onPressed: () {
                              Navigator.of(context).push(MaterialPageRoute(
                                  builder: (context) => ThemePage()));
                            },
                          ),
                        ],
                      ),
                      Observer(builder: (context) {
                        if (accountStore.now != null)
                          return SingleChildScrollView(
                            child: Column(
                              children: <Widget>[
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: InkWell(
                                    onTap: () {
                                      Navigator.of(context, rootNavigator: true)
                                          .push(MaterialPageRoute(builder: (_) {
                                        return AccountSelectPage();
                                      }));
                                    },
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        PainterAvatar(
                                          url: accountStore.now.userImage,
                                          id: int.parse(
                                              accountStore.now.userId),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 8.0),
                                          child: Column(
                                            mainAxisSize: MainAxisSize.max,
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        vertical: 8.0),
                                                child: Text(
                                                    accountStore.now.name,
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .subtitle1),
                                              ),
                                              Text(
                                                accountStore.now.mailAddress,
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .caption,
                                              )
                                            ],
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                                ListTile(
                                  leading: Icon(Icons.account_box),
                                  title: Text(I18n.of(context).account_message),
                                  onTap: () {
                                    Navigator.of(context).push(
                                        MaterialPageRoute(
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
                            title: Text(I18n.of(context).history_record),
                            onTap: () {
                              Navigator.of(context).push(MaterialPageRoute(
                                  builder: (BuildContext context) {
                                return HistoryPage();
                              }));
                            },
                          ),
                          ListTile(
                            leading: Icon(Icons.settings),
                            title: Text(I18n.of(context).quality_setting),
                            onTap: () {
                              Navigator.of(context).push(MaterialPageRoute(
                                  builder: (BuildContext context) {
                                return SettingQualityPage();
                              }));
                            },
                          ),
                          ListTile(
                            leading: Icon(Icons.bookmark),
                            title: Text(I18n.of(context).favorited_tag),
                            onTap: () =>
                                Leader.pushWithScaffold(context, BookTagPage()),
                          ),
                          ListTile(
                            leading: Icon(Icons.block),
                            title: Text(I18n.of(context).shielding_settings),
                            onTap: () => Leader.push(context, ShieldPage()),
                          ),
                          ListTile(
                            leading: Icon(Icons.description),
                            title: Text(I18n.of(context).task_progress),
                            onTap: () => Leader.push(context, JobPage()),
                          ),
                          ListTile(
                            onTap: () => _showClearCacheDialog(context),
                            title: Text(I18n.of(context).clearn_cache),
                            leading: Icon(Icons.clear),
                          ),
                        ],
                      ),
                      Divider(),
                      Column(
                        children: <Widget>[
                          ListTile(
                            leading: Icon(Icons.message),
                            title: Text(I18n.of(context).about),
                            onTap: () => Leader.push(
                                context, AboutPage(newVersion: hasNewVersion)),
                            trailing: Visibility(
                              child: NewVersionChip(),
                              visible: hasNewVersion,
                            ),
                          ),
                          Observer(builder: (context) {
                            if (accountStore.now != null)
                              return ListTile(
                                leading: Icon(Icons.arrow_back),
                                title: Text(I18n.of(context).logout),
                                onTap: () => _showLogoutDialog(context),
                              );
                            else
                              return ListTile(
                                leading: Icon(Icons.arrow_back),
                                title: Text(I18n.of(context).login),
                                onTap: () => Leader.push(context, LoginPage()),
                              );
                          })
                        ],
                      )
                    ],
                  )),
            ),
          ),
        ),
      ),
    );
  }

  Future _showLogoutDialog(BuildContext context) async {
    final result = await showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(I18n.of(context).logout),
            actions: <Widget>[
              FlatButton(
                child: Text(I18n.of(context).cancel),
                onPressed: () {
                  Navigator.of(context).pop("CANCEL");
                },
              ),
              FlatButton(
                child: Text(I18n.of(context).ok),
                onPressed: () {
                  Navigator.of(context).pop("OK");
                },
              ),
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
  }

  Future _showClearCacheDialog(BuildContext context) async {
    final result = await showDialog(
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(I18n.of(context).clear_all_cache),
            actions: <Widget>[
              FlatButton(
                child: Text(I18n.of(context).cancel),
                onPressed: () {
                  Navigator.of(context).pop("CANCEL");
                },
              ),
              FlatButton(
                child: Text(I18n.of(context).ok),
                onPressed: () {
                  Navigator.of(context).pop("OK");
                },
              ),
            ],
          );
        },
        context: context);
    switch (result) {
      case "OK":
        {
          try {
            Directory tempDir = await getTemporaryDirectory();
            tempDir.deleteSync(recursive: true);
            Directory directory =
                Directory((await getApplicationDocumentsDirectory()).path);
            if (directory.existsSync()) directory.deleteSync(recursive: true);
          } catch (e) {}
        }
        break;
    }
  }
}
