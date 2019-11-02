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

import 'dart:async';
import 'dart:io';

import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:pixez/app_widget_plugin.dart';
import 'package:pixez/constants.dart';
import 'package:pixez/er/leader.dart';
import 'package:pixez/er/prefer.dart';
import 'package:pixez/er/updater.dart';
import 'package:pixez/i18n.dart';
import 'package:pixez/main.dart';
import 'package:pixez/page/about/languages.dart';
import 'package:pixez/page/hello/setting/copy_text_page.dart';
import 'package:pixez/page/hello/setting/setting_cross_adapter_page.dart';
import 'package:pixez/page/network/network_page.dart';
import 'package:pixez/page/platform/platform_page.dart';
import 'package:pixez/store/welcome_page_type.dart';
import 'package:pixez/utils/haptic_util.dart';
import 'package:url_launcher/url_launcher_string.dart';

class SettingQualityPage extends StatefulWidget {
  @override
  _SettingQualityPageState createState() => _SettingQualityPageState();
}

class _SettingQualityPageState extends State<SettingQualityPage>
    with TickerProviderStateMixin {
  final _typeList = ["recom", "rank", "follow_illust"];
  int _widgetTypeIndex = -1;

  @override
  void initState() {
    _initData();
    super.initState();
  }

  _initData() async {
    final type = await Prefer.getString("widget_illust_type") ?? "recom";
    int index = _typeList.indexOf(type);
    final normalizedType = index == -1 ? "recom" : type;
    if (index != -1) {
      setState(() {
        _widgetTypeIndex = index;
      });
    } else {
      setState(() {
        _widgetTypeIndex = 0;
      });
    }
    await _saveWidgetIllustType(normalizedType);
  }

  Future<void> _saveWidgetIllustType(String type) async {
    await Prefer.setString("widget_illust_type", type);
    try {
      await AppWidgetPlugin.setRecommendType(type);
    } catch (e) {}
  }

  String _welcomePageLabel(BuildContext context, WelcomePageType type) {
    switch (type) {
      case WelcomePageType.home:
        return I18n.of(context).home;
      case WelcomePageType.rank:
        return I18n.of(context).rank;
      case WelcomePageType.quickView:
        return I18n.of(context).quick_view;
      case WelcomePageType.search:
        return I18n.of(context).search;
      case WelcomePageType.setting:
        return I18n.of(context).setting;
      case WelcomePageType.news:
        return I18n.of(context).news;
      case WelcomePageType.bookmark:
        return I18n.of(context).bookmark;
      case WelcomePageType.followed:
        return I18n.of(context).followed;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(I18n.of(context).quality_setting)),
      body: Observer(
        builder: (context) {
          return Container(
            child: ListView(
              children: [
                if (Platform.isAndroid)
                  ListTile(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28.0)),
                    leading: Icon(Icons.android),
                    trailing: const Icon(Icons.arrow_right),
                    title: Text(I18n.of(context).platform_special_setting),
                    subtitle: Text(
                      "For Android",
                      style: TextStyle(color: Colors.green),
                    ),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (context) => PlatformPage()),
                      );
                    },
                  ),
                ListTile(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28.0)),
                  leading: const Icon(Icons.network_check),
                  title: Text(I18n.of(context).network),
                  trailing: const Icon(Icons.arrow_right),
                  onTap: () => Leader.push(
                    context,
                    NetworkPage(automaticallyImplyLeading: true),
                  ),
                ),
                ListTile(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28.0)),
                  leading: const Icon(Icons.info_outline),
                  title: Text(I18n.of(context).share_info_format),
                  trailing: const Icon(Icons.arrow_right),
                  onTap: () => Leader.push(context, CopyTextPage()),
                ),
                _buildLanguageSelect(),
                Divider(),
                ListTile(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28.0)),
                  leading: const Icon(Icons.feed),
                  title: Text(I18n.of(context).feed_preview_quality),
                  trailing: SettingSelectMenu(
                    index: userSetting.feedPreviewQuality,
                    items: [
                      I18n.of(context).medium,
                      I18n.of(context).large,
                      I18n.of(context).source,
                    ],
                    onChange: (index) {
                      userSetting.changeFeedPreviewQuality(index);
                    },
                  ),
                ),
                ListTile(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28.0)),
                  leading: const Icon(Icons.photo),
                  title: Text(
                    I18n.of(context).illustration_detail_page_quality,
                  ),
                  trailing: SettingSelectMenu(
                    index: userSetting.pictureQuality,
                    items: [
                      I18n.of(context).medium,
                      I18n.of(context).large,
                      I18n.of(context).source,
                    ],
                    onChange: (index) {
                      userSetting.setPictureQuality(index);
                    },
                  ),
                ),
                ListTile(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28.0)),
                  leading: const Icon(Icons.photo_album),
                  title: Text(I18n.of(context).manga_detail_page_quality),
                  trailing: SettingSelectMenu(
                    index: userSetting.mangaQuality,
                    items: [
                      I18n.of(context).medium,
                      I18n.of(context).large,
                      I18n.of(context).source,
                    ],
                    onChange: (index) {
                      userSetting.setMangaQuality(index);
                    },
                  ),
                ),
                ListTile(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28.0)),
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
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28.0)),
                  leading: const Icon(Icons.home),
                  title: Text(I18n.of(context).welcome_page),
                  trailing: SettingSelectMenu(
                    index: userSetting.materialWelcomePageIndex,
                    items: userSetting.materialWelcomePages
                        .map((type) => _welcomePageLabel(context, type))
                        .toList(),
                    onChange: (index) {
                      userSetting.setMaterialWelcomePageIndex(index);
                    },
                  ),
                ),
                ListTile(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28.0)),
                  leading: const Icon(Icons.layers_outlined),
                  title: Text(I18n.of(context).layout_mode),
                  trailing: SettingSelectMenu(
                    index: userSetting.padMode,
                    items: ["V:H", "V:V", "H:H"],
                    onChange: (index) {
                      userSetting.setPadMode(index);
                    },
                  ),
                ),
                ListTile(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28.0)),
                  leading: const Icon(Icons.stay_primary_portrait),
                  title: Text(I18n.of(context).crosscount),
                  trailing: SettingSelectMenu(
                    index: userSetting.crossAdapt
                        ? 3
                        : userSetting.crossCount - 2,
                    items: ['2', '3', '4', "Adapt"],
                    onChange: (index) async {
                      if (index == 3) {
                        await userSetting.setCrossAdapt(true);
                        Leader.push(context, SettingCrossAdpaterPage(h: false));
                        return;
                      }
                      await userSetting.setCrossAdapt(false);
                      await userSetting.setCrossCount(index + 2);
                      BotToast.showText(
                        text: I18n.of(context).need_to_restart_app,
                      );
                    },
                  ),
                ),
                ListTile(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28.0)),
                  leading: const Icon(Icons.stay_primary_landscape),
                  title: Text(I18n.of(context).crosscount),
                  trailing: SettingSelectMenu(
                    index: userSetting.hCrossAdapt
                        ? 3
                        : userSetting.hCrossCount - 2,
                    items: ['2', '3', '4', "Adapt"],
                    onChange: (index) async {
                      if (index == 3) {
                        await userSetting.setHCrossAdapt(true);
                        Leader.push(context, SettingCrossAdpaterPage(h: true));
                        return;
                      }
                      userSetting.setHCrossCount(index + 2);
                      BotToast.showText(
                        text: I18n.of(context).need_to_restart_app,
                      );
                    },
                  ),
                ),
                ListTile(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28.0)),
                  leading: const Icon(Icons.task),
                  title: Text(I18n.of(context).max_download_task_running_count),
                  trailing: SettingSelectMenu(
                    index: userSetting.maxRunningTask - 1,
                    items: [
                      ...List<String>.generate(10, (i) => "${i + 1}").toList(),
                    ],
                    onChange: (index) {
                      userSetting.setMaxRunningTask(index + 1);
                    },
                  ),
                ),
                if (_widgetTypeIndex != -1)
                  ListTile(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28.0)),
                    leading: const Icon(Icons.widgets),
                    title: Text(I18n.of(context).appwidget_recommend_type),
                    trailing: SettingSelectMenu(
                      index: _widgetTypeIndex,
                      items: [
                        I18n.of(context).recommend,
                        I18n.of(context).rank,
                        I18n.of(context).news,
                      ],
                      onChange: (index) async {
                        final type = _typeList[index];
                        setState(() {
                          _widgetTypeIndex = index;
                        });
                        await _saveWidgetIllustType(type);
                      },
                    ),
                  ),
                Divider(),
                ListTile(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28.0)),
                  title: Text(I18n.of(context).special_shaped_screen),
                  trailing: Switch(
                    value: userSetting.isBangs,
                    onChanged: (value) => userSetting.setIsBangs(value),
                  ),
                  onTap: () => userSetting.setIsBangs(!userSetting.isBangs),
                ),
                ListTile(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28.0)),
                  title: Text(I18n.of(context).long_press_save_confirm),
                  trailing: Switch(
                    value: userSetting.longPressSaveConfirm,
                    onChanged: (value) => userSetting.setLongPressSaveConfirm(value),
                  ),
                  onTap: () => userSetting.setLongPressSaveConfirm(!userSetting.longPressSaveConfirm),
                ),
                ListTile(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28.0)),
                  title: Text('H是不行的！'),
                  trailing: Switch(
                    value: userSetting.hIsNotAllow,
                    onChanged: (value) {
                      if (!value) BotToast.showText(text: 'H是可以的！(ˉ﹃ˉ)');
                      userSetting.setHIsNotAllow(value);
                    },
                  ),
                  onTap: () {
                    if (userSetting.hIsNotAllow) BotToast.showText(text: 'H是可以的！(ˉ﹃ˉ)');
                    userSetting.setHIsNotAllow(!userSetting.hIsNotAllow);
                  },
                ),
                ListTile(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28.0)),
                  title: Text(I18n.of(context).return_again_to_exit),
                  trailing: Switch(
                    value: userSetting.isReturnAgainToExit,
                    onChanged: (value) => userSetting.setIsReturnAgainToExit(value),
                  ),
                  onTap: () => userSetting.setIsReturnAgainToExit(!userSetting.isReturnAgainToExit),
                ),
                ListTile(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28.0)),
                  title: Text(I18n.of(context).swipe_to_switch_artworks),
                  trailing: Switch(
                    value: userSetting.swipeChangeArtwork,
                    onChanged: (value) => userSetting.setSwipeChangeArtwork(value),
                  ),
                  onTap: () => userSetting.setSwipeChangeArtwork(!userSetting.swipeChangeArtwork),
                ),
                if (Platform.isAndroid || Platform.isIOS)
                  ListTile(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28.0)),
                    title: Text(I18n.of(context).haptic_feedback),
                    trailing: Switch(
                      value: userSetting.hapticFeedback,
                      onChanged: (value) {
                        userSetting.setHapticFeedback(value);
                        if (value) HapticUtil.medium();
                      },
                    ),
                    onTap: () {
                      userSetting.setHapticFeedback(!userSetting.hapticFeedback);
                      if (!userSetting.hapticFeedback) HapticUtil.medium();
                    },
                  ),
                if (Platform.isAndroid || Platform.isIOS)
                  ListTile(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28.0)),
                    title: Text(
                      Platform.isIOS
                          ? I18n.of(context).recent_screen_mask
                          : I18n.of(context).secure_window,
                    ),
                    trailing: Switch(
                      value: userSetting.nsfwMask,
                      onChanged: (value) => userSetting.changeNsfwMask(value),
                    ),
                    onTap: () => userSetting.changeNsfwMask(!userSetting.nsfwMask),
                  ),
                if (!Platform.isIOS)
                  ListTile(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28.0)),
                    title: Text(I18n.of(context).open_saucenao_using_webview),
                    trailing: Switch(
                      value: userSetting.useSaunceNaoWebview,
                      onChanged: (value) => userSetting.setUseSaunceNaoWebview(value),
                    ),
                    onTap: () => userSetting.setUseSaunceNaoWebview(!userSetting.useSaunceNaoWebview),
                  ),
                ListTile(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28.0)),
                  title: Text(I18n.of(context).illust_detail_save_skip_confirm),
                  trailing: Switch(
                    value: userSetting.illustDetailSaveSkipLongPress,
                    onChanged: (value) => userSetting.setIllustDetailSaveSkipLongPress(value),
                  ),
                  onTap: () => userSetting.setIllustDetailSaveSkipLongPress(!userSetting.illustDetailSaveSkipLongPress),
                ),
                ListTile(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28.0)),
                  title: Text(I18n.of(context).show_feed_ai_badge),
                  trailing: Switch(
                    value: userSetting.feedAIBadge,
                    onChanged: (value) => userSetting.setFeedAIBadge(value),
                  ),
                  onTap: () => userSetting.setFeedAIBadge(!userSetting.feedAIBadge),
                ),
                if (!Constants.isGooglePlay && !Platform.isIOS)
                  ListTile(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28.0)),
                    title: Text(I18n.of(context).ignore_current_version_update),
                    trailing: Switch(
                      value: Updater.result == Result.yes &&
                          Updater.latestVersion != null &&
                          userSetting.ignoreUpdateVersion == Updater.latestVersion,
                      onChanged: (value) async {
                        if (value) {
                          if (Updater.latestVersion == null) {
                            await Updater.check();
                          }
                          if (Updater.result == Result.yes &&
                              Updater.latestVersion != null) {
                            await userSetting.setIgnoreUpdateVersion(
                              Updater.latestVersion,
                            );
                          }
                        } else {
                          await userSetting.setIgnoreUpdateVersion(null);
                        }
                      },
                    ),
                    onTap: () async {
                      final value = !(Updater.result == Result.yes &&
                          Updater.latestVersion != null &&
                          userSetting.ignoreUpdateVersion == Updater.latestVersion);
                      if (value) {
                        if (Updater.latestVersion == null) {
                          await Updater.check();
                        }
                        if (Updater.result == Result.yes &&
                            Updater.latestVersion != null) {
                          await userSetting.setIgnoreUpdateVersion(
                            Updater.latestVersion,
                          );
                        }
                      } else {
                        await userSetting.setIgnoreUpdateVersion(null);
                      }
                    },
                  ),
                Divider(),
                ListTile(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28.0)),
                  title: Text(I18n.of(context).follow_after_star),
                  trailing: Switch(
                    value: userSetting.followAfterStar,
                    onChanged: (value) => userSetting.setFollowAfterStar(value),
                  ),
                  onTap: () => userSetting.setFollowAfterStar(!userSetting.followAfterStar),
                ),
                ListTile(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28.0)),
                  title: Text(I18n.of(context).private_like_by_default),
                  trailing: Switch(
                    value: userSetting.defaultPrivateLike,
                    onChanged: (value) => userSetting.setDefaultPrivateLike(value),
                  ),
                  onTap: () => userSetting.setDefaultPrivateLike(!userSetting.defaultPrivateLike),
                ),
                ListTile(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28.0)),
                  title: Text(
                    I18n.of(context).automatically_download_when_bookmarking,
                  ),
                  trailing: Switch(
                    value: userSetting.saveAfterStar,
                    onChanged: (value) => userSetting.setSaveAfterStar(value),
                  ),
                  onTap: () => userSetting.setSaveAfterStar(!userSetting.saveAfterStar),
                ),
                ListTile(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28.0)),
                  title: Text(
                    I18n.of(context).automatically_bookmark_when_downloading,
                  ),
                  trailing: Switch(
                    value: userSetting.starAfterSave,
                    onChanged: (value) => userSetting.setStarAfterSave(value),
                  ),
                  onTap: () => userSetting.setStarAfterSave(!userSetting.starAfterSave),
                ),
                ListTile(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28.0)),
                  title: Text(
                    I18n.of(context).automatically_tag_when_bookmarking,
                  ),
                  trailing: Switch(
                    value: userSetting.autoTagWhenStar,
                    onChanged: (value) => userSetting.setAutoTagWhenStar(value),
                  ),
                  onTap: () => userSetting.setAutoTagWhenStar(!userSetting.autoTagWhenStar),
                ),
                Divider(),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildLanguageSelect() {
    return Container(
      child: Column(
        children: [
          ListTile(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28.0)),
            leading: Icon(Icons.translate),
            title: Text("Language"),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SettingSelectMenu(
                  index: userSetting.languageNum,
                  items: [...Languages.map((e) => e.language).toList()],
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
                Text(
                  Languages.map(
                    (e) => e.language,
                  ).toList()[userSetting.languageNum],
                ),
                _buildLanguageTranlators(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageTranlators() {
    final langsponsors = Languages[userSetting.languageNum].sponsors ?? [];
    if (langsponsors.isEmpty) {
      return const SizedBox.shrink();
    }
    return Row(
      children: [
        for (final langsponsor in langsponsors)
          InkWell(
            borderRadius: BorderRadius.circular(28.0),
            onTap: () {
              try {
                if (Platform.isAndroid && !Constants.isGooglePlay) {
                  if (langsponsor.uri.isNotEmpty) {
                    launchUrlString(langsponsor.uri);
                  }
                }
              } catch (e) {}
            },
            child: Row(
              children: <Widget>[
                SizedBox(
                  width: 30,
                  height: 30,
                  child: CircleAvatar(
                    backgroundImage: (langsponsor.avatar.isNotEmpty)
                        ? NetworkImage(langsponsor.avatar)
                        : null,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(langsponsor.name ?? ''),
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
  final FutureOr<void> Function(int) onChange;
  const SettingSelectMenu({
    super.key,
    required this.index,
    required this.items,
    required this.onChange,
  });

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
        onTap: () async {
          final renderBox = context.findRenderObject() as RenderBox;
          var local = renderBox.localToGlobal(Offset.zero);
          var size = MediaQuery.of(context).size;
          final selected = await showMenu<int>(
            context: context,
            position: RelativeRect.fromLTRB(
              local.dx - 20,
              local.dy,
              local.dx + size.width - 20,
              size.height + local.dy,
            ),
            items: <PopupMenuEntry<int>>[
              for (int i = 0; i < _items.length; i++)
                if (i != _index)
                  PopupMenuItem(value: i, child: Text(_items[i])),
            ],
          );
          if (selected == null || selected == _index) {
            return;
          }
          setState(() {
            _index = selected;
          });
          await widget.onChange(selected);
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 4.0),
          child: Container(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [SizedBox(width: 8.0), Text("${_items[_index]}")],
                ),
                Icon(Icons.arrow_drop_down),
              ],
            ),
            constraints: BoxConstraints(minWidth: 90),
          ),
        ),
      ),
    );
  }
}