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

import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pixez/component/new_version_chip.dart';
import 'package:pixez/component/painter_avatar.dart';
import 'package:pixez/component/pixiv_image.dart';
import 'package:pixez/constants.dart';
import 'package:pixez/er/leader.dart';
import 'package:pixez/er/lprinter.dart';
import 'package:pixez/er/updater.dart';
import 'package:pixez/component/fluent_ink_well.dart';
import 'package:pixez/i18n.dart';
import 'package:pixez/main.dart';
import 'package:pixez/page/about/about_page.dart';
import 'package:pixez/page/account/edit/account_edit_page.dart';
import 'package:pixez/page/account/select/account_select_page.dart';
import 'package:pixez/page/book/tag/book_tag_page.dart';
import 'package:pixez/page/hello/setting/setting_quality_page.dart';
import 'package:pixez/page/history/history_page.dart';
import 'package:pixez/page/login/login_page.dart';
import 'package:pixez/page/network/network_setting_page.dart';
import 'package:pixez/page/novel/history/novel_history_page.dart';
import 'package:pixez/page/novel/novel_rail.dart';
import 'package:pixez/page/shield/shield_page.dart';
import 'package:pixez/page/task/job_page.dart';
import 'package:pixez/page/theme/theme_page.dart';

class FluentSettingPage extends StatefulWidget {
  const FluentSettingPage({Key? key}) : super(key: key);

  @override
  _FluentSettingPageState createState() => _FluentSettingPageState();
}

class _FluentSettingPageState extends State<FluentSettingPage> {
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
    return ScaffoldPage(
      header: PageHeader(
        title: Text(I18n.of(context).setting),
        commandBar: CommandBar(
          overflowBehavior: CommandBarOverflowBehavior.noWrap,
          primaryItems: [
            if (kDebugMode)
              CommandBarButton(
                icon: Icon(FluentIcons.code),
                onPressed: () {
                  _showSavedLogDialog(context);
                },
              ),
            CommandBarButton(
              icon: Icon(
                FluentIcons.color,
                color: FluentTheme.of(context).accentColor,
              ),
              onPressed: () {
                Leader.fluentNav(
                  context,
                  Icon(FluentIcons.color),
                  Text("主题设置"),
                  ThemePage(),
                );
              },
            ),
          ],
        ),
      ),
      content: SafeArea(
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
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: InkWell(
                              onTap: () {
                                Leader.fluentNav(
                                  context,
                                  Icon(FluentIcons.account_browser),
                                  Text("账户选择"),
                                  AccountSelectPage(),
                                );
                              },
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  PainterAvatar(
                                    url: accountStore.now!.userImage,
                                    id: int.parse(accountStore.now!.userId),
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
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 8.0),
                                            child: Text(
                                              accountStore.now!.name,
                                              style: FluentTheme.of(context)
                                                  .tooltipTheme
                                                  .textStyle,
                                            )),
                                        Text(
                                          accountStore.now!.mailAddress,
                                          style: FluentTheme.of(context)
                                              .tooltipTheme
                                              .textStyle,
                                        )
                                      ],
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ),
                          TappableListTile(
                            leading: Icon(FluentIcons.account_management),
                            title: Text(I18n.of(context).account_message),
                            onTap: () {
                              Leader.fluentNav(
                                context,
                                Icon(FluentIcons.account_management),
                                Text(I18n.of(context).account_message),
                                AccountEditPage(),
                              );
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
                    TappableListTile(
                      leading: Icon(FluentIcons.history),
                      title: Text(I18n.of(context).history_record),
                      onTap: () {
                        Leader.fluentNav(
                          context,
                          Icon(FluentIcons.history),
                          Text(I18n.of(context).history_record),
                          Constants.type == 0 ? HistoryPage() : NovelHistory(),
                        );
                      },
                    ),
                    TappableListTile(
                      leading: Icon(FluentIcons.settings),
                      title: Text(I18n.of(context).quality_setting),
                      onTap: () {
                        Leader.fluentNav(
                            context,
                            Icon(FluentIcons.settings),
                            Text(I18n.of(context).quality_setting),
                            SettingQualityPage());
                      },
                    ),
                    TappableListTile(
                      leading: Icon(FluentIcons.bookmarks),
                      title: Text(I18n.of(context).favorited_tag),
                      onTap: () => Leader.fluentNav(
                          context,
                          Icon(FluentIcons.bookmarks),
                          Text(I18n.of(context).favorited_tag),
                          BookTagPage()),
                    ),
                    TappableListTile(
                      leading: Icon(FluentIcons.blocked),
                      title: Text(I18n.of(context).shielding_settings),
                      onTap: () => Leader.fluentNav(
                          context,
                          Icon(FluentIcons.blocked),
                          Text(I18n.of(context).shielding_settings),
                          ShieldPage()),
                    ),
                    TappableListTile(
                      leading: Icon(FluentIcons.save),
                      title: Text(I18n.of(context).task_progress),
                      onTap: () => Leader.fluentNav(
                          context,
                          Icon(FluentIcons.save),
                          Text(I18n.of(context).task_progress),
                          JobPage()),
                    ),
                    TappableListTile(
                      onTap: () => _showClearCacheDialog(context),
                      title: Text(I18n.of(context).clearn_cache),
                      leading: Icon(FluentIcons.clear),
                    ),
                  ],
                ),
                Divider(),
                Column(
                  children: <Widget>[
                    TappableListTile(
                      leading: Icon(FluentIcons.book_answers),
                      title: Text('Novel'),
                      onTap: () => Navigator.of(context, rootNavigator: true)
                          .pushReplacement(FluentPageRoute(
                              builder: (context) => NovelRail())),
                    ),
                    if (kDebugMode)
                      TappableListTile(
                        leading: Icon(FluentIcons.network_device_scanning),
                        title: Text("网络诊断"),
                        onTap: () {
                          Leader.fluentNav(
                              context,
                              Icon(FluentIcons.network_device_scanning),
                              Text("网络诊断"),
                              NetworkSettingPage());
                        },
                      ),
                    TappableListTile(
                      leading: Icon(FluentIcons.message),
                      title: Text(I18n.of(context).about),
                      onTap: () => Leader.fluentNav(
                          context,
                          Icon(FluentIcons.message),
                          Text(I18n.of(context).about),
                          AboutPage(newVersion: hasNewVersion)),
                      trailing: Visibility(
                        child: NewVersionChip(),
                        visible: hasNewVersion,
                      ),
                    ),
                    Observer(builder: (context) {
                      if (accountStore.now != null)
                        return TappableListTile(
                          leading: Icon(FluentIcons.back),
                          title: Text(I18n.of(context).logout),
                          onTap: () => _showLogoutDialog(context),
                        );
                      else
                        return TappableListTile(
                          leading: Icon(FluentIcons.sign_out),
                          title: Text(I18n.of(context).login),
                          onTap: () => Leader.fluentNav(
                              context,
                              Icon(FluentIcons.sign_out),
                              Text(I18n.of(context).login),
                              LoginPage()),
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

  Future _showSavedLogDialog(BuildContext context) async {
    var savedLogFile = await LPrinter.savedLogFile();
    var content = savedLogFile.readAsStringSync();
    final result = await showDialog(
        context: context,
        builder: (context) {
          return ContentDialog(
            title: Text("Log"),
            content: Container(
              child: Text(content),
              height: 400,
            ),
            actions: <Widget>[
              TextButton(
                child: Text(I18n.of(context).cancel),
                onPressed: () {
                  Navigator.of(context).pop("CANCEL");
                },
              ),
              TextButton(
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
        {}
        break;
      case "CANCEL":
        {}
        break;
    }
  }

  _showMessage(BuildContext context) async {
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

  Future _showLogoutDialog(BuildContext context) async {
    final result = await showDialog(
        context: context,
        builder: (context) {
          return ContentDialog(
            title: Text(I18n.of(context).logout),
            actions: <Widget>[
              TextButton(
                child: Text(I18n.of(context).cancel),
                onPressed: () {
                  Navigator.of(context).pop("CANCEL");
                },
              ),
              TextButton(
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

  // _showCacheBottomSheet(BuildContext context) async {
  //   final result = await showModalBottomSheet(
  //       context: context,
  //       shape: const RoundedRectangleBorder(
  //           borderRadius: BorderRadius.only(
  //               topLeft: Radius.circular(16.0),
  //               topRight: Radius.circular(16.0))),
  //       builder: (context) {
  //         return SafeArea(
  //             child: Column(
  //           mainAxisSize: MainAxisSize.min,
  //           children: [
  //             ListTile(
  //               title: Text(I18n.of(context).clear_all_cache),
  //             ),
  //             Slider(
  //               value: 1,
  //               onChanged: (v) {},
  //             ),
  //             TappableListTile(
  //               title: Text(I18n.of(context).ok),
  //               onTap: () {
  //                 Navigator.of(context).pop("OK");
  //               },
  //             ),
  //             TappableListTile(
  //               title: Text(I18n.of(context).cancel),
  //               onTap: () {
  //                 Navigator.of(context).pop();
  //               },
  //             ),
  //           ],
  //         ));
  //       });
  // }

  Future _showClearCacheDialog(BuildContext context) async {
    final result = await showDialog(
        builder: (BuildContext context) {
          return ContentDialog(
            title: Text(I18n.of(context).clear_all_cache),
            actions: <Widget>[
              TextButton(
                child: Text(I18n.of(context).cancel),
                onPressed: () {
                  Navigator.of(context).pop("CANCEL");
                },
              ),
              TextButton(
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
          } catch (e) {}
        }
        break;
    }
  }
}
