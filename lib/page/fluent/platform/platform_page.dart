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


import 'package:device_info_plus/device_info_plus.dart';
import 'package:fluent_ui/fluent_ui.dart';
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

  @override
  void initState() {
    super.initState();
    initVoid();
  }

  initVoid() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    setState(() {
      version = packageInfo.version;
    });
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
        title: Row(children: [
          Text("Platform Setting"),
          Text(
            "For Desktop",
            style: TextStyle(
              color: Colors.blue,
              fontSize: FluentTheme.of(context).typography.subtitle?.fontSize,
            ),
          )
        ]),
      ),
      content: Observer(builder: (_) {
        return ListView(
          children: <Widget>[
            ListTile(
              leading: Icon(FluentIcons.folder),
              title: Text(I18n.of(context).save_path),
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
                  child: Image.asset("assets/images/open_by_default_hint.png"),
                ),
              ),
              Container(
                height: 20,
              )
            ]
          ],
        );
      }),
    );
  }
}
