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
import 'package:pixez/generated/l10n.dart';
import 'package:pixez/main.dart';
import 'package:pixez/page/directory/directory_page.dart';
import 'package:pixez/page/hello/setting/save_format_page.dart';

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
    userSetting.getPath();
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
  }

  String version = "";
  bool singleFolder = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: ListTile(
          title: Text(I18n.of(context).Platform_settings),
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
                title: Text(I18n.of(context).Save_path),
                subtitle: Text(userSetting.path ?? ""),
                onTap: () async {
                  String result =
                      await Navigator.of(context, rootNavigator: true).push(
                          MaterialPageRoute(
                              builder: (context) => DirectoryPage()));
                  if (result != null) userSetting.setPath(result);
                },
              ),
              ListTile(
                leading: Icon(Icons.format_align_left),
                title: Text(I18n.of(context).Save_format),
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
                builder: (_) {
                  return SwitchListTile(
                    secondary: Icon(Icons.folder_shared),
                    onChanged: (bool value) async {
                      await userSetting.setSingleFolder(value);
                    },
                    title: Text(I18n.of(context).Separate_Folder),
                    subtitle: Text(I18n.of(context).Separate_Folder_Message),
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
                                                .Display_Mode_Message),
                                            subtitle: Text(I18n.of(context)
                                                .Display_Mode_Warning),
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
                title: Text(I18n.of(context).Display_Mode),
                subtitle: Text(selected.toString() ?? ''),
              ),
              ListTile(
                leading: Icon(Icons.info),
                title: Text(I18n.of(context).Version),
                subtitle: Text(I18n.of(context).Version_number),
                onTap: () async {},
              )
            ],
          );
        }),
      ),
    );
  }
}
