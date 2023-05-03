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
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:pixez/er/leader.dart';
import 'package:pixez/i18n.dart';
import 'package:pixez/main.dart';
import 'package:pixez/page/fluent/hello/setting/copy_text_page.dart';
import 'package:pixez/page/fluent/hello/setting/setting_cross_adapter_page.dart';
import 'package:pixez/page/fluent/network/network_page.dart';
import 'package:pixez/page/fluent/platform/platform_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/link.dart';

class SettingQualityPage extends StatefulWidget {
  @override
  _SettingQualityPageState createState() => _SettingQualityPageState();
}

class _SettingQualityPageState extends State<SettingQualityPage>
    with TickerProviderStateMixin {
  late List<LangSponsor> _languageTranlator;

  final _typeList = ["rank", "follow_illust", "recom"];
  SharedPreferences? _pref;
  int _widgetTypeIndex = -1;

  @override
  void initState() {
    _languageTranlator = _langsponsors[userSetting.languageNum];
    _initData();
    super.initState();
  }

  _initData() async {
    _pref = await SharedPreferences.getInstance();
    final type = await _pref?.getString("widget_illust_type") ?? "recom";
    int index = _typeList.indexOf(type);
    if (index == -1) {
      setState(() {
        _widgetTypeIndex = index;
      });
    }
  }

  final _langsponsors = [
    [
      LangSponsor(
        name: 'Xian',
        avatar: 'https://avatars.githubusercontent.com/u/34748039',
        uri: 'https://github.com/itzXian',
      ),
      LangSponsor(
        name: 'Takase',
        avatar: 'https://avatars.githubusercontent.com/u/20792268',
        uri: 'https://github.com/takase1121',
      ),
    ],
    [
      LangSponsor(
        name: 'Skimige',
        avatar: 'https://avatars.githubusercontent.com/u/9017470',
        uri: 'https://github.com/Skimige',
      ),
    ],
    [
      LangSponsor(
        name: 'Tragic Life',
        avatar: 'https://avatars.githubusercontent.com/u/16817202',
        uri: 'https://github.com/TragicLifeHu',
      ),
    ],
    [
      LangSponsor(
        name: 'karin722',
        avatar: 'https://avatars.githubusercontent.com/u/54385201',
        uri: 'https://github.com/karin722',
      ),
      LangSponsor(
        name: 'arrow2nd',
        avatar: 'https://avatars.githubusercontent.com/u/44780846',
        uri: 'https://github.com/arrow2nd',
      ),
    ],
    [
      LangSponsor(
        name: 'San Kang',
        avatar: 'https://avatars.githubusercontent.com/u/40086827',
        uri: 'https://github.com/RivMt',
      ),
    ],
    [
      LangSponsor(
        name: 'Vlad Afonin',
        avatar: 'https://avatars.githubusercontent.com/u/20505643',
        uri: 'https://github.com/mytecor',
      ),
    ],
    [
      LangSponsor(
        name: 'SugarBlank',
        avatar: 'https://avatars.githubusercontent.com/u/64178604',
        uri: 'https://github.com/SugarBlank',
      ),
    ],
    [
      LangSponsor(
        name: 'KYOYA',
        avatar: 'https://avatars.githubusercontent.com/u/63583961',
        uri: 'https://github.com/kyoyacchi',
      ),
    ],
  ];

  @override
  Widget build(BuildContext context) {
    return ScaffoldPage.scrollable(
      header: PageHeader(
        title: Text(I18n.of(context).quality_setting),
      ),
      children: [
        ListTile(
          title: Text(I18n.of(context).platform_special_setting),
          trailing: Icon(FluentIcons.chevron_right_small),
          subtitle: Text(
            "For Desktop",
            style: TextStyle(color: Colors.blue),
          ),
          onPressed: () {
            Leader.push(
              context,
              PlatformPage(),
              icon: Icon(FluentIcons.settings),
              title: Text(I18n.of(context).platform_special_setting),
            );
          },
        ),
        ListTile(
          title: Text(I18n.of(context).network),
          trailing: Icon(FluentIcons.chevron_right_small),
          onPressed: () {
            Leader.push(
              context,
              NetworkPage(
                automaticallyImplyLeading: true,
              ),
              icon: Icon(FluentIcons.chevron_right_small),
              title: Text(I18n.of(context).network),
            );
          },
        ),
        ListTile(
          title: Text(I18n.of(context).large_preview_zoom_quality),
          trailing: Observer(builder: (_) {
            return ComboBox<int>(
              value: userSetting.zoomQuality,
              items: [
                ComboBoxItem(
                  child: Text(I18n.of(context).large),
                  value: 0,
                ),
                ComboBoxItem(
                  child: Text(I18n.of(context).source),
                  value: 1,
                ),
              ],
              onChanged: (selected) {
                userSetting.change(selected!);
              },
            );
          }),
        ),
        ListTile(
          title: Text(I18n.of(context).illustration_detail_page_quality),
          trailing: Observer(builder: (_) {
            return ComboBox<int>(
              value: userSetting.pictureQuality,
              items: [
                ComboBoxItem(
                  child: Text(I18n.of(context).medium),
                  value: 0,
                ),
                ComboBoxItem(
                  child: Text(I18n.of(context).large),
                  value: 1,
                ),
              ],
              onChanged: (selected) {
                userSetting.setPictureQuality(selected!);
              },
            );
          }),
        ),
        ListTile(
          title: Text(I18n.of(context).manga_detail_page_quality),
          trailing: Observer(builder: (_) {
            return ComboBox<int>(
              value: userSetting.mangaQuality,
              items: [
                ComboBoxItem(
                  child: Text(I18n.of(context).medium),
                  value: 0,
                ),
                ComboBoxItem(
                  child: Text(I18n.of(context).large),
                  value: 1,
                ),
                ComboBoxItem(
                  child: Text(I18n.of(context).source),
                  value: 2,
                ),
              ],
              onChanged: (selected) {
                userSetting.setMangaQuality(selected!);
              },
            );
          }),
        ),
        ListTile(
          title: Text("Language"),
          trailing: Row(
            children: [
              ..._languageTranlator.map(
                (i) => Link(
                  uri: Uri.parse(i.uri),
                  builder: (context, open) => IconButton(
                    onPressed: open,
                    icon: Row(children: [
                      CircleAvatar(backgroundImage: NetworkImage(i.avatar)),
                      Padding(
                        padding: EdgeInsets.only(left: 8),
                        child: Text(i.name),
                      ),
                    ]),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(left: 8, right: 8),
                child: Icon(FluentIcons.translate),
              ),
              Observer(builder: (_) {
                const list = [
                  "en-US",
                  "zh-CN",
                  "zh-TW",
                  "ja",
                  "ko",
                  "ru",
                  "es",
                  "tr",
                ];
                return ComboBox<int>(
                  value: userSetting.languageNum,
                  items: list
                      .asMap()
                      .entries
                      .map((i) => ComboBoxItem(
                            child: Text(i.value),
                            value: i.key,
                          ))
                      .toList(),
                  onChanged: (index) async {
                    await userSetting.setLanguageNum(index!);
                    setState(() {
                      _languageTranlator = _langsponsors[index];
                    });
                  },
                );
              })
            ],
          ),
        ),
        ListTile(
          title: Text(I18n.of(context).welcome_page),
          trailing: Observer(builder: (_) {
            final tablist = Platform.isAndroid
                ? [
                    I18n.of(context).home,
                    I18n.of(context).rank,
                    I18n.of(context).quick_view,
                    I18n.of(context).search,
                    I18n.of(context).setting,
                  ]
                : [
                    I18n.of(context).home,
                    I18n.of(context).quick_view,
                    I18n.of(context).search,
                    I18n.of(context).setting,
                  ];
            return ComboBox<int>(
              value: userSetting.welcomePageNum,
              items: tablist
                  .asMap()
                  .entries
                  .map((i) => ComboBoxItem(
                        child: Text(i.value),
                        value: i.key,
                      ))
                  .toList(),
              onChanged: (index) async {
                await userSetting.setWelcomePageNum(index!);
              },
            );
          }),
        ),
        ListTile(
          title: Text(I18n.of(context).layout_mode),
          trailing: Observer(builder: (_) {
            const tablist = [
              "V:H",
              "V:V",
              "H:H",
            ];
            return ComboBox<int>(
              value: userSetting.padMode,
              items: tablist
                  .asMap()
                  .entries
                  .map((i) => ComboBoxItem(
                        child: Text(i.value),
                        value: i.key,
                      ))
                  .toList(),
              onChanged: (index) async {
                await userSetting.setPadMode(index!);
              },
            );
          }),
        ),
        ListTile(title: Text(I18n.of(context).crosscount)),
        ListTile(
          leading: Icon(FluentIcons.column),
          trailing: Observer(builder: (_) {
            const tablist = [
              ' 2 ',
              ' 3 ',
              ' 4 ',
              "Adapt",
            ];
            return ComboBox<int>(
              value: userSetting.crossAdapt ? 3 : userSetting.crossCount - 2,
              items: tablist
                  .asMap()
                  .entries
                  .map((i) => ComboBoxItem(
                        child: Text(i.value),
                        value: i.key,
                      ))
                  .toList(),
              onChanged: (index) async {
                if (index == 3) {
                  await userSetting.setCrossAdapt(true);
                  Leader.push(
                      context,
                      SettingCrossAdpaterPage(
                        h: false,
                      ));
                  return;
                }
                await userSetting.setCrossAdapt(false);
                await userSetting.setCrossCount(index! + 2);
                BotToast.showText(text: I18n.of(context).need_to_restart_app);
              },
            );
          }),
        ),
        ListTile(
          leading: Icon(FluentIcons.dock_left),
          trailing: Observer(builder: (_) {
            const tablist = [
              ' 2 ',
              ' 3 ',
              ' 4 ',
              "Adapt",
            ];
            return ComboBox<int>(
              value: userSetting.hCrossAdapt ? 3 : userSetting.hCrossCount - 2,
              items: tablist
                  .asMap()
                  .entries
                  .map((i) => ComboBoxItem(
                        child: Text(i.value),
                        value: i.key,
                      ))
                  .toList(),
              onChanged: (index) async {
                if (index == 3) {
                  await userSetting.setHCrossAdapt(true);
                  Leader.push(
                      context,
                      SettingCrossAdpaterPage(
                        h: true,
                      ));
                  return;
                }
                userSetting.setHCrossCount(index! + 2);
                BotToast.showText(text: I18n.of(context).need_to_restart_app);
              },
            );
          }),
        ),
        Observer(builder: (_) {
          final targetValue =
              userSetting.maxRunningTask < 1 ? 1 : userSetting.maxRunningTask;
          return ListTile(
            title: Text(
                "${I18n.of(context).max_download_task_running_count} $targetValue"),
            subtitle: Slider(
                value: targetValue.toDouble(),
                label: '${targetValue}',
                min: 1,
                max: 10,
                divisions: 10,
                onChanged: (v) {
                  int value = v.toInt();
                  userSetting.setMaxRunningTask(value);
                }),
          );
        }),
        // Padding(
        //   padding: const EdgeInsets.all(8.0),
        //   child: Card(
        //     child: Observer(builder: (_) {
        //       return ListTile(
        //           title: Text(I18n.of(context).special_shaped_screen),
        //           subtitle: Text('--v--'),
        //           trailing: ToggleSwitch(
        //               checked: userSetting.isBangs,
        //               onChanged: (value) async {
        //                 userSetting.setIsBangs(value);
        //               }));
        //     }),
        //   ),
        // ),
        Observer(builder: (_) {
          return ListTile(
              title: Text('H是不行的！'),
              trailing: ToggleSwitch(
                  checked: userSetting.hIsNotAllow,
                  onChanged: (value) async {
                    if (!value) BotToast.showText(text: 'H是可以的！(ˉ﹃ˉ)');
                    userSetting.setHIsNotAllow(value);
                  }));
        }),
        // Padding(
        //   padding: const EdgeInsets.all(8.0),
        //   child: Card(
        //     child: Observer(builder: (_) {
        //       return ListTile(
        //           title: Text(I18n.of(context).return_again_to_exit),
        //           trailing: ToggleSwitch(
        //               checked: userSetting.isReturnAgainToExit,
        //               onChanged: (value) async {
        //                 userSetting.setIsReturnAgainToExit(value);
        //               }));
        //     }),
        //   ),
        // ),
        Observer(builder: (_) {
          return ListTile(
              title: Text(I18n.of(context).follow_after_star),
              trailing: ToggleSwitch(
                  checked: userSetting.followAfterStar,
                  onChanged: (value) async {
                    userSetting.setFollowAfterStar(value);
                  }));
        }),
        Observer(
          builder: (context) {
            return ListTile(
              onPressed: () {
                Leader.push(
                  context,
                  CopyTextPage(),
                  title: Text(I18n.of(context).share_info_format),
                  icon: Icon(FluentIcons.forward),
                );
              },
              title: Text(I18n.of(context).share_info_format),
              trailing: Icon(FluentIcons.forward),
            );
          },
        ),
        if (_widgetTypeIndex != -1)
          Padding(
            padding: EdgeInsets.all(8.0),
            child: Card(
                child: Column(
              children: <Widget>[
                Padding(
                  child: Text("App widget type"),
                  padding: EdgeInsets.all(16),
                ),
                Observer(builder: (_) {
                  var tablist = [
                    I18n.of(context).rank,
                    I18n.of(context).news,
                    I18n.of(context).recommend,
                  ];
                  return ComboBox<int>(
                    value: _widgetTypeIndex,
                    items: tablist
                        .asMap()
                        .entries
                        .map((i) => ComboBoxItem(
                              child: Text(i.value),
                              value: i.key,
                            ))
                        .toList(),
                    onChanged: (index) async {
                      final type = _typeList[index!];
                      await _pref?.setString("widget_illust_type", type);
                    },
                  );
                })
              ],
            )),
          ),
      ],
    );
  }
}

class LangSponsor {
  final String name;
  final String avatar;
  final String uri;
  LangSponsor({
    required this.name,
    required this.avatar,
    required this.uri,
  });
}
