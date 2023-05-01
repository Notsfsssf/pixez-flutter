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

import 'package:device_info_plus/device_info_plus.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/services.dart';
import 'package:flutter_displaymode/flutter_displaymode.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:pixez/document_plugin.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:pixez/er/leader.dart';
import 'package:pixez/i18n.dart';
import 'package:pixez/main.dart';
import 'package:pixez/open_setting_plugin.dart';
import 'package:pixez/page/fluent/directory/save_mode_choice_page.dart';
import 'package:pixez/page/fluent/hello/setting/save_format_page.dart';

class PlatformPage extends StatefulWidget {
  @override
  _PlatformPageState createState() => _PlatformPageState();
}

class _PlatformPageState extends State<PlatformPage> {
  String path = "";
  List<DisplayMode> modes = <DisplayMode>[];
  DisplayMode? selected;

  @override
  void initState() {
    super.initState();
    initVoid();
  }

  Future<void> fetchModes() async {
    try {
      var modeList = await FlutterDisplayMode.supported;
      setState(() {
        modes = modeList;
      });

      /// On OnePlus 7 Pro:
      /// #1 1080x2340 @ 60Hz
      /// #2 1080x2340 @ 90Hz
      /// #3 1440x3120 @ 90Hz
      /// #4 1440x3120 @ 60Hz

      /// On OnePlus 8 Pro:
      /// #1 1080x2376 @ 60Hz
      /// #2 1440x3168 @ 120Hz
      /// #3 1440x3168 @ 60Hz
      /// #4 1080x2376 @ 120Hz
      selected = await FlutterDisplayMode.preferred;
    } on PlatformException catch (e) {
      print(e);

      /// e.code =>
      /// noAPI - No API support. Only Marshmallow and above.
      /// noActivity - Activity is not available. Probably app is in background
    }
    // if (mounted) {
    //   setState(() {});
    // }
  }

  initVoid() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    setState(() {
      version = packageInfo.version;
    });
    fetchModes();
    String path = (await DocumentPlugin.getPath())!;
    if (mounted) {
      setState(() {
        this.path = path;
      });
    }
    var androidInfo = await DeviceInfoPlugin().androidInfo;
    setState(() {
      _androidInfo = androidInfo;
    });
  }

  AndroidDeviceInfo? _androidInfo = null;

  String version = "";
  bool singleFolder = false;

  @override
  Widget build(BuildContext context) {
    return ScaffoldPage(
      header: PageHeader(
        title: ListTile(
          title: Text("Platform Setting"),
          subtitle: Text(
            "For Android",
            style: TextStyle(color: Colors.accentColors.first),
          ),
        ),
      ),
      content: Container(
        child: Observer(builder: (_) {
          return ListView(
            children: <Widget>[
              ListTile(
                leading: Icon(FluentIcons.folder),
                title: Text(
                    '${I18n.of(context).save_path}(${userSetting.saveMode != 0 ? (userSetting.saveMode == 2 ? I18n.of(context).old_way : 'SAF') : "Media"})'),
                subtitle: Text(path),
                onPressed: () async {
                  await showPathDialog(context);
                  final path = await DocumentPlugin.getPath();
                  if (mounted) {
                    setState(() {
                      this.path = path!;
                    });
                  }
                },
              ),
              ListTile(
                leading: Icon(FluentIcons.format_painter),
                title: Text(I18n.of(context).save_format),
                subtitle: Text(userSetting.format ?? ""),
                onPressed: () async {
                  final result = await Leader.push(context, SaveFormatPage());
                  if (result is String) {
                    userSetting.setFormat(result);
                  }
                  // if (result != null) userSetting.setPath(result);
                },
              ),
              Observer(
                builder: (context) {
                  return ToggleSwitch(
                    // TODO
                    // secondary: Icon(FluentIcons.share),
                    onChanged: (bool value) async {
                      if (value) {
                        showSnackbar(
                            context, Snackbar(content: Text("可能会造成保存等待时间过长")));
                      }
                      await userSetting.setSingleFolder(value);
                    },
                    content: Text(I18n.of(context).separate_folder +
                        I18n.of(context).separate_folder_message),
                    checked: userSetting.singleFolder,
                  );
                },
              ),
              Observer(
                builder: (context) {
                  return ToggleSwitch(
                    // TODO
                    // secondary: Icon(FluentIcons.folder_open),
                    onChanged: (bool value) async {
                      await userSetting.setOverSanityLevelFolder(value);
                    },
                    content: Text("Sanity Single Folder"),
                    checked: userSetting.overSanityLevelFolder,
                  );
                },
              ),
              ListTile(
                leading: Icon(FluentIcons.screen),
                onPressed: () {
                  showBottomSheet(
                      context: context,
                      shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.vertical(top: Radius.circular(8.0))),
                      builder: (_) {
                        return SafeArea(
                          child: Container(
                              child: modes.isNotEmpty
                                  ? ListView.builder(
                                      shrinkWrap: true,
                                      itemCount: modes.length + 1,
                                      itemBuilder: (context, index) {
                                        if (index == 0)
                                          return ListTile(
                                            title: Text(I18n.of(context)
                                                .display_mode_message),
                                            subtitle: Text(I18n.of(context)
                                                .display_mode_warning),
                                            onPressed: () async {},
                                          );
                                        return ListTile(
                                          title:
                                              Text(modes[index - 1].toString()),
                                          onPressed: () async {
                                            await FlutterDisplayMode
                                                .setPreferredMode(
                                                    modes[index - 1]);
                                            userSetting
                                                .setDisplayMode(index - 1);
                                            setState(() {
                                              selected = modes[index - 1];
                                            });
                                            Navigator.of(context).pop();
                                          },
                                        );
                                      })
                                  : Container()),
                        );
                      });
                },
                title: Text(I18n.of(context).display_mode),
                subtitle: Text('${selected ?? ''}'),
              ),
              if ((_androidInfo?.version.sdkInt ?? 0) > 30) ...[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    "More for Android 12",
                    style: TextStyle(color: Colors.green),
                  ),
                ),
                ListTile(
                  leading: Icon(FluentIcons.add_link),
                  title: Text(I18n.of(context).open_by_default),
                  subtitle: Text(I18n.of(context).open_by_default_subtitle),
                  onPressed: () {
                    OpenSettingPlugin.open();
                  },
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 100.0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child:
                        Image.asset("assets/images/open_by_default_hint.png"),
                  ),
                ),
                Container(
                  height: 20,
                )
              ]
            ],
          );
        }),
      ),
    );
  }
}
