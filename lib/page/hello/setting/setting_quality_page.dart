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
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:pixez/constants.dart';
import 'package:pixez/er/leader.dart';
import 'package:pixez/er/prefer.dart';
import 'package:pixez/i18n.dart';
import 'package:pixez/main.dart';
import 'package:pixez/models/glance_illust_persist.dart';
import 'package:pixez/page/about/languages.dart';
import 'package:pixez/page/hello/setting/copy_text_page.dart';
import 'package:pixez/page/hello/setting/setting_cross_adapter_page.dart';
import 'package:pixez/page/network/network_page.dart';
import 'package:pixez/page/platform/platform_page.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingQualityPage extends StatefulWidget {
  @override
  _SettingQualityPageState createState() => _SettingQualityPageState();
}

class _SettingQualityPageState extends State<SettingQualityPage>
    with TickerProviderStateMixin {
  final _typeList = ["follow_illust", "recom", "rank"];
  int _widgetTypeIndex = -1;
  GlanceIllustPersistProvider glanceIllustPersistProvider =
      GlanceIllustPersistProvider();

  @override
  void initState() {
    _initData();
    super.initState();
  }

  _initData() async {
    final type = await Prefer.getString("widget_illust_type") ?? "recom";
    int index = _typeList.indexOf(type);
    if (index != -1) {
      setState(() {
        _widgetTypeIndex = index;
      });
    } else {
      setState(() {
        _widgetTypeIndex = 0;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(I18n.of(context).quality_setting),
      ),
      body: Observer(builder: (context) {
        return Container(
          child: ListView(children: [
            if (Platform.isAndroid)
              ListTile(
                leading: Icon(Icons.android),
                trailing: const Icon(Icons.arrow_right),
                title: Text(I18n.of(context).platform_special_setting),
                subtitle: Text(
                  "For Android",
                  style: TextStyle(color: Colors.green),
                ),
                onTap: () {
                  Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => PlatformPage()));
                },
              ),
            ListTile(
              leading: const Icon(Icons.network_check),
              title: Text(I18n.of(context).network),
              trailing: const Icon(Icons.arrow_right),
              onTap: () => Leader.push(
                  context,
                  NetworkPage(
                    automaticallyImplyLeading: true,
                  )),
            ),
            ListTile(
              leading: const Icon(Icons.info_outline),
              title: Text(I18n.of(context).share_info_format),
              trailing: const Icon(Icons.arrow_right),
              onTap: () => Leader.push(context, CopyTextPage()),
            ),
            _buildLanguageSelect(),
            Divider(),
            ListTile(
              leading: const Icon(Icons.feed),
              title: Text(I18n.of(context).feed_preview_quality),
              trailing: SettingSelectMenu(
                index: userSetting.feedPreviewQuality,
                items: [
                  I18n.of(context).medium,
                  I18n.of(context).large,
                  I18n.of(context).source
                ],
                onChange: (index) {
                  userSetting.changeFeedPreviewQuality(index);
                },
              ),
            ),
            ListTile(
              leading: const Icon(Icons.photo),
              title: Text(I18n.of(context).illustration_detail_page_quality),
              trailing: SettingSelectMenu(
                index: userSetting.pictureQuality,
                items: [
                  I18n.of(context).medium,
                  I18n.of(context).large,
                  I18n.of(context).source
                ],
                onChange: (index) {
                  userSetting.setPictureQuality(index);
                },
              ),
            ),
            ListTile(
              leading: const Icon(Icons.photo_album),
              title: Text(I18n.of(context).manga_detail_page_quality),
              trailing: SettingSelectMenu(
                index: userSetting.mangaQuality,
                items: [
                  I18n.of(context).medium,
                  I18n.of(context).large,
                  I18n.of(context).source
                ],
                onChange: (index) {
                  userSetting.setMangaQuality(index);
                },
              ),
            ),
            ListTile(
              leading: const Icon(Icons.zoom_out_map),
              title: Text(I18n.of(context).large_preview_zoom_quality),
              trailing: SettingSelectMenu(
                index: userSetting.zoomQuality,
                items: [I18n.of(context).large, I18n.of(context).source],
                onChange: (index) {
                  userSetting.change(index);
                },
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home),
              title: Text(I18n.of(context).welcome_page),
              trailing: SettingSelectMenu(
                index: userSetting.welcomePageNum,
                items: Platform.isAndroid
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
                      ],
                onChange: (index) {
                  userSetting.setWelcomePageNum(index);
                },
              ),
            ),
            ListTile(
              leading: const Icon(Icons.layers_outlined),
              title: Text(I18n.of(context).layout_mode),
              trailing: SettingSelectMenu(
                index: userSetting.padMode,
                items: [
                  "V:H",
                  "V:V",
                  "H:H",
                ],
                onChange: (index) {
                  userSetting.setPadMode(index);
                },
              ),
            ),
            ListTile(
              leading: const Icon(Icons.stay_primary_portrait),
              title: Text(I18n.of(context).crosscount),
              trailing: SettingSelectMenu(
                index: userSetting.crossAdapt ? 3 : userSetting.crossCount - 2,
                items: [
                  '2',
                  '3',
                  '4',
                  "Adapt",
                ],
                onChange: (index) async {
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
                  await userSetting.setCrossCount(index + 2);
                  BotToast.showText(text: I18n.of(context).need_to_restart_app);
                },
              ),
            ),
            ListTile(
              leading: const Icon(Icons.stay_primary_landscape),
              title: Text(I18n.of(context).crosscount),
              trailing: SettingSelectMenu(
                index:
                    userSetting.hCrossAdapt ? 3 : userSetting.hCrossCount - 2,
                items: [
                  '2',
                  '3',
                  '4',
                  "Adapt",
                ],
                onChange: (index) async {
                  if (index == 3) {
                    await userSetting.setHCrossAdapt(true);
                    Leader.push(
                        context,
                        SettingCrossAdpaterPage(
                          h: true,
                        ));
                    return;
                  }
                  userSetting.setHCrossCount(index + 2);
                  BotToast.showText(text: I18n.of(context).need_to_restart_app);
                },
              ),
            ),
            ListTile(
              leading: const Icon(Icons.task),
              title: Text(I18n.of(context).max_download_task_running_count),
              trailing: SettingSelectMenu(
                index: userSetting.maxRunningTask - 1,
                items: [
                  ...List<String>.generate(10, (i) => "${i + 1}").toList()
                ],
                onChange: (index) {
                  userSetting.setMaxRunningTask(index + 1);
                },
              ),
            ),
            if (_widgetTypeIndex != -1)
              ListTile(
                leading: const Icon(Icons.widgets),
                title: Text(I18n.of(context).appwidget_recommend_type),
                trailing: SettingSelectMenu(
                  index: userSetting.zoomQuality,
                  items: [
                    I18n.of(context).recommend,
                    I18n.of(context).rank,
                    I18n.of(context).news,
                  ],
                  onChange: (index) async {
                    try {
                      final type = _typeList[index];
                      await Prefer.setString("widget_illust_type", type);
                      await glanceIllustPersistProvider.open();
                      await glanceIllustPersistProvider.deleteAll();
                    } catch (e) {}
                  },
                ),
              ),
            Divider(),
            SwitchListTile(
                value: userSetting.isBangs,
                title: Text(I18n.of(context).special_shaped_screen),
                onChanged: (value) async {
                  userSetting.setIsBangs(value);
                }),
            SwitchListTile(
                value: userSetting.longPressSaveConfirm,
                title: Text(I18n.of(context).long_press_save_confirm),
                onChanged: (value) async {
                  userSetting.setLongPressSaveConfirm(value);
                }),
            SwitchListTile(
                value: userSetting.hIsNotAllow,
                title: Text('H是不行的！'),
                onChanged: (value) async {
                  if (!value) BotToast.showText(text: 'H是可以的！(ˉ﹃ˉ)');
                  userSetting.setHIsNotAllow(value);
                }),
            SwitchListTile(
                value: userSetting.isReturnAgainToExit,
                title: Text(I18n.of(context).return_again_to_exit),
                onChanged: (value) async {
                  userSetting.setIsReturnAgainToExit(value);
                }),
            SwitchListTile(
                value: userSetting.swipeChangeArtwork,
                title: Text(I18n.of(context).swipe_to_switch_artworks),
                onChanged: (value) async {
                  userSetting.setSwipeChangeArtwork(value);
                }),
            if (Platform.isAndroid || Platform.isIOS)
              SwitchListTile(
                  value: userSetting.nsfwMask,
                  title: Text(Platform.isIOS
                      ? I18n.of(context).recent_screen_mask
                      : I18n.of(context).secure_window),
                  onChanged: (value) async {
                    userSetting.changeNsfwMask(value);
                  }),
            if (!Platform.isIOS)
              SwitchListTile(
                  value: userSetting.useSaunceNaoWebview,
                  title: Text(I18n.of(context).open_saucenao_using_webview),
                  onChanged: (value) async {
                    userSetting.setUseSaunceNaoWebview(value);
                  }),
            SwitchListTile(
                value: userSetting.illustDetailSaveSkipLongPress,
                title: Text(I18n.of(context).illust_detail_save_skip_confirm),
                onChanged: (value) async {
                  userSetting.setIllustDetailSaveSkipLongPress(value);
                }),
            SwitchListTile(
                value: userSetting.feedAIBadge,
                title: Text(I18n.of(context).show_feed_ai_badge),
                onChanged: (value) async {
                  userSetting.setFeedAIBadge(value);
                }),
            Divider(),
            SwitchListTile(
                value: userSetting.followAfterStar,
                title: Text(I18n.of(context).follow_after_star),
                onChanged: (value) async {
                  userSetting.setFollowAfterStar(value);
                }),
            SwitchListTile(
                value: userSetting.defaultPrivateLike,
                title: Text(I18n.of(context).private_like_by_default),
                onChanged: (value) async {
                  userSetting.setDefaultPrivateLike(value);
                }),
            SwitchListTile(
              value: userSetting.saveAfterStar,
              title: Text(
                  I18n.of(context).automatically_download_when_bookmarking),
              onChanged: (value) async {
                userSetting.setSaveAfterStar(value);
              },
            ),
            SwitchListTile(
              value: userSetting.starAfterSave,
              title: Text(
                  I18n.of(context).automatically_bookmark_when_downloading),
              onChanged: (value) async {
                userSetting.setStarAfterSave(value);
              },
            ),
            Divider(),
          ]),
        );
      }),
    );
  }

  Widget _buildLanguageSelect() {
    return Container(
      child: Column(
        children: [
          ListTile(
            leading: Icon(Icons.translate),
            title: Text("Language"),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SettingSelectMenu(
                  index: userSetting.languageNum,
                  items: [
                    ...Languages.map(
                      (e) => e.language,
                    ).toList()
                  ],
                  onChange: (index) async {
                    await userSetting.setLanguageNum(index);
                  },
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(Languages.map(
                    (e) => e.language,
                  ).toList()[userSetting.languageNum]),
                  _buildLanguageTranlators(),
                ]),
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageTranlators() {
    final langsponsors = Languages[userSetting.languageNum].sponsors;
    return Row(
      children: [
        for (final langsponsor in langsponsors)
          InkWell(
            onTap: () {
              try {
                if (Platform.isAndroid && !Constants.isGooglePlay)
                  launchUrl(Uri.dataFromString(langsponsor.uri));
              } catch (e) {}
            },
            child: Row(
              children: <Widget>[
                SizedBox(
                  child: CircleAvatar(
                    backgroundImage: NetworkImage(langsponsor.avatar),
                  ),
                  width: 30,
                  height: 30,
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(langsponsor.name),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class SettingSelectMenu extends StatefulWidget {
  final int index;
  final List<String> items;
  final Function(int) onChange;
  const SettingSelectMenu(
      {super.key,
      required this.index,
      required this.items,
      required this.onChange});

  @override
  State<SettingSelectMenu> createState() => _SettingSelectMenuState();
}

class _SettingSelectMenuState extends State<SettingSelectMenu> {
  int _index = 0;
  late List<String> _items;
  @override
  void initState() {
    _items = widget.items;
    _index = widget.index;
    super.initState();
  }

  @override
  void didUpdateWidget(covariant SettingSelectMenu oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.index != widget.index || oldWidget.items != widget.items) {
      setState(() {
        _index = widget.index;
        _items = widget.items;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
      clipBehavior: Clip.antiAlias,
      elevation: 0.0,
      color: Theme.of(context).colorScheme.secondaryContainer,
      child: InkWell(
          onTap: () {
            final renderBox = context.findRenderObject() as RenderBox;
            var local = renderBox.localToGlobal(Offset.zero);
            var size = MediaQuery.of(context).size;
            showMenu(
                context: context,
                position: RelativeRect.fromLTRB(local.dx - 20, local.dy,
                    local.dx + size.width - 20, size.height + local.dy),
                items: <PopupMenuEntry>[
                  for (int i = 0; i < _items.length; i++)
                    if (!_items.contains(i))
                      PopupMenuItem(
                        value: i,
                        onTap: () {
                          setState(() {
                            _index = i;
                            widget.onChange(i);
                          });
                        },
                        child: Text(_items[i]),
                      )
                ]);
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 4.0),
            child: Container(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      SizedBox(
                        width: 8.0,
                      ),
                      Text(
                        "${_items[_index]}",
                      )
                    ],
                  ),
                  Icon(Icons.arrow_drop_down)
                ],
              ),
              constraints: BoxConstraints(minWidth: 90),
            ),
          )),
    );
  }
}
