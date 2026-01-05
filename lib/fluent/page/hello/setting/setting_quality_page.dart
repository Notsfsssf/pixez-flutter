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
import 'package:flutter/material.dart' show Icons;
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:pixez/fluent/component/pixez_button.dart';
import 'package:pixez/er/leader.dart';
import 'package:pixez/i18n.dart';
import 'package:pixez/main.dart';
import 'package:pixez/page/about/languages.dart';
import 'package:pixez/fluent/page/hello/setting/copy_text_page.dart';
import 'package:pixez/fluent/page/hello/setting/setting_cross_adapter_page.dart';
import 'package:pixez/fluent/page/network/network_page.dart';
import 'package:pixez/fluent/page/platform/platform_page.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingQualityPage extends StatefulWidget {
  @override
  _SettingQualityPageState createState() => _SettingQualityPageState();
}

class _SettingQualityPageState extends State<SettingQualityPage>
    with TickerProviderStateMixin {
  late Widget _languageTranlator;

  @override
  void initState() {
    _buildLanguageTranlators();
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    return Observer(
      builder: (context) => ScaffoldPage.scrollable(
        header: PageHeader(title: Text(I18n.of(context).quality_setting)),
        children: [
          if (Platform.isWindows)
            ListTile(
              leading: const Icon(Icons.window),
              title: Text(I18n.of(context).platform_special_setting),
              subtitle: Text(
                "For Windows",
                style: TextStyle(color: Colors.blue),
              ),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => PlatformPage(),
                  useRootNavigator: false,
                );
              },
            ),
          ListTile(
            leading: const Icon(FluentIcons.wifi),
            title: Text(I18n.of(context).network),
            trailing: Icon(FluentIcons.chevron_right),
            onPressed: () {
              Leader.push(
                context,
                NetworkPage(automaticallyImplyLeading: true),
                icon: Icon(FluentIcons.wifi),
                title: Text(I18n.of(context).network),
              );
            },
          ),
          ListTile(
            leading: const Icon(FluentIcons.info),
            title: Text(I18n.of(context).share_info_format),
            trailing: const Icon(FluentIcons.chevron_right),
            onPressed: () => Leader.push(
              context,
              CopyTextPage(),
              icon: Icon(FluentIcons.info),
              title: Text(I18n.of(context).share_info_format),
            ),
          ),
          ListTile(
            leading: const Icon(FluentIcons.translate),
            title: Text("Language"),
            trailing: Observer(
              builder: (context) => Row(
                children: [
                  _languageTranlator,
                  ComboBox<int>(
                    value: userSetting.languageNum,
                    items: Languages.map((e) => e.language)
                        .toList()
                        .asMap()
                        .entries
                        .map(
                          (i) =>
                              ComboBoxItem(child: Text(i.value), value: i.key),
                        )
                        .toList(),
                    onChanged: (index) async {
                      await userSetting.setLanguageNum(index!);
                      setState(() {
                        _buildLanguageTranlators();
                      });
                    },
                  ),
                ],
              ),
            ),
          ),
          Divider(),
          ListTile(
            leading: const Icon(FluentIcons.list),
            title: Text(I18n.of(context).feed_preview_quality),
            trailing: ComboBox(
              value: userSetting.feedPreviewQuality,
              items: [
                ComboBoxItem(child: Text(I18n.of(context).medium), value: 0),
                ComboBoxItem(child: Text(I18n.of(context).large), value: 1),
                ComboBoxItem(child: Text(I18n.of(context).source), value: 2),
              ],
              onChanged: (index) {
                userSetting.changeFeedPreviewQuality(index ?? 0);
              },
            ),
          ),
          ListTile(
            leading: const Icon(FluentIcons.photo),
            title: Text(I18n.of(context).illustration_detail_page_quality),
            trailing: Observer(
              builder: (_) {
                return ComboBox<int>(
                  value: userSetting.pictureQuality,
                  items: [
                    ComboBoxItem(
                      child: Text(I18n.of(context).medium),
                      value: 0,
                    ),
                    ComboBoxItem(child: Text(I18n.of(context).large), value: 1),
                  ],
                  onChanged: (selected) {
                    userSetting.setPictureQuality(selected ?? 0);
                  },
                );
              },
            ),
          ),
          ListTile(
            leading: const Icon(FluentIcons.photo_collection),
            title: Text(I18n.of(context).manga_detail_page_quality),
            trailing: Observer(
              builder: (_) {
                return ComboBox<int>(
                  value: userSetting.mangaQuality,
                  items: [
                    ComboBoxItem(
                      child: Text(I18n.of(context).medium),
                      value: 0,
                    ),
                    ComboBoxItem(child: Text(I18n.of(context).large), value: 1),
                    ComboBoxItem(
                      child: Text(I18n.of(context).source),
                      value: 2,
                    ),
                  ],
                  onChanged: (selected) {
                    userSetting.setMangaQuality(selected!);
                  },
                );
              },
            ),
          ),
          ListTile(
            leading: const Icon(Icons.zoom_out_map),
            title: Text(I18n.of(context).large_preview_zoom_quality),
            trailing: Observer(
              builder: (_) {
                return ComboBox<int>(
                  value: userSetting.zoomQuality,
                  items: [
                    ComboBoxItem(child: Text(I18n.of(context).large), value: 0),
                    ComboBoxItem(
                      child: Text(I18n.of(context).source),
                      value: 1,
                    ),
                  ],
                  onChanged: (selected) {
                    userSetting.change(selected ?? 0);
                  },
                );
              },
            ),
          ),
          ListTile(
            leading: const Icon(FluentIcons.home),
            title: Text(I18n.of(context).welcome_page),
            trailing: Observer(
              builder: (_) {
                final tablist = {
                  0: I18n.of(context).home,
                  1: I18n.of(context).rank,
                  3: I18n.of(context).news,
                  4: I18n.of(context).bookmark,
                  5: I18n.of(context).followed,
                  6: I18n.of(context).setting,
                };
                return ComboBox<int>(
                  value: userSetting.welcomePageNum,
                  items: tablist.entries
                      .map(
                        (i) => ComboBoxItem(child: Text(i.value), value: i.key),
                      )
                      .toList(),
                  onChanged: (index) async {
                    await userSetting.setWelcomePageNum(index!);
                  },
                );
              },
            ),
          ),
          ListTile(
            leading: const Icon(FluentIcons.map_layers),
            title: Text(I18n.of(context).layout_mode),
            trailing: Observer(
              builder: (_) {
                const tablist = ["V:H", "V:V", "H:H"];
                return ComboBox<int>(
                  value: userSetting.padMode,
                  items: tablist
                      .asMap()
                      .entries
                      .map(
                        (i) => ComboBoxItem(child: Text(i.value), value: i.key),
                      )
                      .toList(),
                  onChanged: (index) async {
                    await userSetting.setPadMode(index!);
                  },
                );
              },
            ),
          ),
          Expander(
            initiallyExpanded: true,
            header: Text(I18n.of(context).crosscount),
            content: Column(
              children: [
                ListTile(
                  leading: Icon(FluentIcons.column),
                  trailing: Observer(
                    builder: (_) {
                      const tablist = [' 2 ', ' 3 ', ' 4 ', "Adapt"];
                      return ComboBox<int>(
                        value: userSetting.crossAdapt
                            ? 3
                            : userSetting.crossCount - 2,
                        items: tablist
                            .asMap()
                            .entries
                            .map(
                              (i) => ComboBoxItem(
                                child: Text(i.value),
                                value: i.key,
                              ),
                            )
                            .toList(),
                        onChanged: (index) async {
                          if (index == 3) {
                            await userSetting.setCrossAdapt(true);
                            Leader.push(
                              context,
                              SettingCrossAdpaterPage(h: false),
                            );
                            return;
                          }
                          await userSetting.setCrossAdapt(false);
                          await userSetting.setCrossCount(index! + 2);
                          BotToast.showText(
                            text: I18n.of(context).need_to_restart_app,
                          );
                        },
                      );
                    },
                  ),
                ),
                ListTile(
                  leading: Icon(FluentIcons.dock_left),
                  trailing: Observer(
                    builder: (_) {
                      const tablist = [' 2 ', ' 3 ', ' 4 ', "Adapt"];
                      return ComboBox<int>(
                        value: userSetting.hCrossAdapt
                            ? 3
                            : userSetting.hCrossCount - 2,
                        items: tablist
                            .asMap()
                            .entries
                            .map(
                              (i) => ComboBoxItem(
                                child: Text(i.value),
                                value: i.key,
                              ),
                            )
                            .toList(),
                        onChanged: (index) async {
                          if (index == 3) {
                            await userSetting.setHCrossAdapt(true);
                            Leader.push(
                              context,
                              SettingCrossAdpaterPage(h: true),
                            );
                            return;
                          }
                          userSetting.setHCrossCount(index! + 2);
                          BotToast.showText(
                            text: I18n.of(context).need_to_restart_app,
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          Observer(
            builder: (_) {
              final targetValue = userSetting.maxRunningTask < 1
                  ? 1
                  : userSetting.maxRunningTask;
              return ListTile(
                leading: const Icon(FluentIcons.download),
                title: Text(
                  "${I18n.of(context).max_download_task_running_count} $targetValue",
                ),
                subtitle: Slider(
                  value: targetValue.toDouble(),
                  label: '${targetValue}',
                  min: 1,
                  max: 10,
                  divisions: 10,
                  onChanged: (v) {
                    int value = v.toInt();
                    userSetting.setMaxRunningTask(value);
                  },
                ),
              );
            },
          ),
          Divider(),
          ListTile(
            title: Text('H是不行的！'),
            trailing: ToggleSwitch(
              checked: userSetting.hIsNotAllow,
              onChanged: (value) async {
                if (!value) BotToast.showText(text: 'H是可以的！(ˉ﹃ˉ)');
                userSetting.setHIsNotAllow(value);
              },
            ),
          ),
          if (!Platform.isIOS)
            ListTile(
              title: Text(I18n.of(context).open_saucenao_using_webview),
              trailing: ToggleSwitch(
                checked: userSetting.useSaunceNaoWebview,
                onChanged: (value) async {
                  userSetting.setUseSaunceNaoWebview(value);
                },
              ),
            ),
          ListTile(
            title: Text(I18n.of(context).illust_detail_save_skip_confirm),
            trailing: ToggleSwitch(
              checked: userSetting.illustDetailSaveSkipLongPress,
              onChanged: (value) async {
                userSetting.setIllustDetailSaveSkipLongPress(value);
              },
            ),
          ),
          ListTile(
            title: Text(I18n.of(context).show_feed_ai_badge),
            trailing: ToggleSwitch(
              checked: userSetting.feedAIBadge,
              onChanged: (value) async {
                userSetting.setFeedAIBadge(value);
              },
            ),
          ),
          Divider(),
          ListTile(
            title: Text(I18n.of(context).follow_after_star),
            trailing: ToggleSwitch(
              checked: userSetting.followAfterStar,
              onChanged: (value) async {
                userSetting.setFollowAfterStar(value);
              },
            ),
          ),
          ListTile(
            title: Text(I18n.of(context).private_like_by_default),
            trailing: ToggleSwitch(
              checked: userSetting.defaultPrivateLike,
              onChanged: (value) async {
                userSetting.setDefaultPrivateLike(value);
              },
            ),
          ),
          ListTile(
            title: Text(
              I18n.of(context).automatically_download_when_bookmarking,
            ),
            trailing: ToggleSwitch(
              checked: userSetting.saveAfterStar,
              onChanged: (value) async {
                userSetting.setSaveAfterStar(value);
              },
            ),
          ),
          ListTile(
            title: Text(
              I18n.of(context).automatically_bookmark_when_downloading,
            ),
            trailing: ToggleSwitch(
              checked: userSetting.starAfterSave,
              onChanged: (value) async {
                userSetting.setStarAfterSave(value);
              },
            ),
          ),
        ],
      ),
    );
  }

  void _buildLanguageTranlators() {
    final langsponsors = Languages[userSetting.languageNum].sponsors;
    _languageTranlator = Row(
      children: [
        for (final langsponsor in langsponsors)
          PixEzButton(
            onPressed: () {
              try {
                launchUrl(Uri.parse(langsponsor.uri));
              } catch (e) {}
            },
            child: Row(
              children: <Widget>[
                CircleAvatar(backgroundImage: NetworkImage(langsponsor.avatar)),
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
