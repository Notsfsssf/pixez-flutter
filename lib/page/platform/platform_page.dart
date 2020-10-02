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

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_displaymode/flutter_displaymode.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:package_info/package_info.dart';
import 'package:pixez/constants.dart';
import 'package:pixez/document_plugin.dart';
import 'package:pixez/generated/l10n.dart';
import 'package:pixez/main.dart';
import 'package:pixez/page/directory/directory_page.dart';
import 'package:pixez/page/hello/setting/save_format_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class PlatformPage extends StatefulWidget {
  @override
  _PlatformPageState createState() => _PlatformPageState();
}

class _PlatformPageState extends State<PlatformPage> {
  String path = "";
  List<DisplayMode> modes = <DisplayMode>[];
  DisplayMode selected;

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
    } on PlatformException catch (e) {
      print(e);

      /// e.code =>
      /// noAPI - No API support. Only Marshmallow and above.
      /// noActivity - Activity is not available. Probably app is in background
    }
    selected =
        modes.firstWhere((DisplayMode m) => m.selected, orElse: () => null);
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
    String path = await DocumentPlugin.getPath();
    if (mounted) {
      setState(() {
        this.path = path;
      });
    }
  }

  String version = "";
  bool singleFolder = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: ListTile(
          title: Text("Platform Setting"),
          subtitle: Text(
            "For Android",
            style: TextStyle(color: Colors.greenAccent),
          ),
        ),
      ),
      body: Container(
        child: Observer(builder: (_) {
          return ListView(
            children: <Widget>[
              ListTile(
                leading: Icon(Icons.folder),
                title: Text(I18n.of(context).save_path),
                subtitle: Text(path ?? ""),
                onTap: () async {
                  await showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(8.0))),
                          content: SingleChildScrollView(
                            child: ListBody(
                              children: [
                                Text(I18n.of(context).saf_hint),
                                Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 8.0),
                                  child: Text(
                                      I18n.of(context).step + 1.toString()),
                                ),
                                Image.asset(
                                  'assets/images/step1.png',
                                  fit: BoxFit.fitWidth,
                                ),
                                Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 8.0),
                                  child: Text(
                                      I18n.of(context).step + 2.toString()),
                                ),
                                Image.asset(
                                  'assets/images/step2.png',
                                  fit: BoxFit.fitWidth,
                                )
                              ],
                            ),
                          ),
                          title: Text(I18n.of(context).choose_directory),
                          actions: [
                            FlatButton(
                                onPressed: () async {
                                  await userSetting.setIsHelplessWay(true);
                                  final path = await Navigator.of(context).push(
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              DirectoryPage()));
                                  if (path != null) {
                                    final _preferences =
                                        await SharedPreferences.getInstance();
                                    await _preferences.setString(
                                        'store_path', path);
                                  }
                                  Navigator.of(context).pop();
                                },
                                child: Text('helpless')),
                            FlatButton(
                                onPressed: () async {
                                  Constants.isGooglePlay ||
                                          userSetting.disableBypassSni
                                      ? launch(
                                          "https://developer.android.com/training/data-storage/shared/documents-files")
                                      : launch(
                                          "https://developer.android.google.cn/training/data-storage/shared/documents-files");
                                },
                                child: Text(I18n.of(context).what_is_saf)),
                            FlatButton(
                                onPressed: () async {
                                  await userSetting.setIsHelplessWay(false);
                                  await DocumentPlugin.choiceFolder();
                                  Navigator.of(context).pop();
                                },
                                child: Text(I18n.of(context).start))
                          ],
                        );
                      });
                  final path = await DocumentPlugin.getPath();
                  debugPrint(path);
                  if (mounted) {
                    setState(() {
                      this.path = path;
                    });
                  }
                },
              ),
              ListTile(
                leading: Icon(Icons.format_align_left),
                title: Text(I18n.of(context).save_format),
                subtitle: Text(userSetting.format ?? ""),
                onTap: () async {
                  String result =
                      await Navigator.of(context, rootNavigator: true).push(
                          MaterialPageRoute(
                              builder: (context) => SaveFormatPage()));
                  if (result != null) {
                    userSetting.setFormat(result);
                  }
                  // if (result != null) userSetting.setPath(result);
                },
              ),
              Observer(
                builder: (context) {
                  return SwitchListTile(
                    secondary: Icon(Icons.folder_shared),
                    onChanged: (bool value) async {
                      if (value) {
                        Scaffold.of(context).showSnackBar(
                            SnackBar(content: Text("可能会造成保存等待时间过长")));
                      }
                      await userSetting.setSingleFolder(value);
                    },
                    title: Text(I18n.of(context).separate_folder),
                    subtitle: Text(I18n.of(context).separate_folder_message),
                    value: userSetting.singleFolder,
                  );
                },
              ),
              ListTile(
                leading: Icon(Icons.mobile_screen_share),
                onTap: () {
                  showModalBottomSheet(
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
                                            onTap: () async {},
                                          );
                                        return ListTile(
                                          title:
                                              Text(modes[index - 1].toString()),
                                          onTap: () async {
                                            await FlutterDisplayMode.setMode(
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
                subtitle: Text(selected.toString() ?? ''),
              ),
            ],
          );
        }),
      ),
    );
  }
}
