/*
 * Copyright (C) 2020. by perol_notsf, All rights reserved
 *
 * This program is free software: you can redistribute it and/or modify it under
 * the terms of the GNU General Public License as published by the Free Software
 * Foundation, either version 3 of the License, or (at your option) any later version.
 *
 *  This program is distributed in the hope that it will be useful, but WITHOUT ANY
 *  WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
 *  FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License along with
 *  this program. If not, see <http://www.gnu.org/licenses/>.
 */

import 'package:bot_toast/bot_toast.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:pixez/constants.dart';
import 'package:pixez/document_plugin.dart';
import 'package:pixez/er/leader.dart';
import 'package:pixez/i18n.dart';
import 'package:pixez/main.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import 'directory_page.dart';

showPathDialog(BuildContext context, {bool isFirst = false}) async {
  return Leader.push(
    context,
    SaveModeChoicePage(
      isFirst: isFirst,
    ),
    icon: Icon(FluentIcons.settings),
    title: Text(I18n.of(context).save_format),
  );
}

class SaveModeChoicePage extends StatefulWidget {
  final bool isFirst;

  SaveModeChoicePage({Key? key, required this.isFirst}) : super(key: key);

  @override
  _SaveModeChoicePageState createState() => _SaveModeChoicePageState();
}

class _SaveModeChoicePageState extends State<SaveModeChoicePage>
    with SingleTickerProviderStateMixin {
  int groupValue = 0;
  late AnimationController _animationController;

  @override
  void initState() {
    _animationController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 500));
    _animationController.addListener(() {
      setState(() {});
    });
    super.initState();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldPage(
      content: Builder(builder: (context) {
        return SafeArea(
          child: Card(
            margin: EdgeInsets.all(0.0),
            child: Column(
              children: [
                ListTile(
                    leading: Icon(FluentIcons.next, color: Colors.white),
                    onPressed: () async => _onPress(context),
                    title: Text(
                      I18n.of(context).start,
                      style: TextStyle(color: Colors.white),
                    )),
                ComboBox<int>(
                    value: groupValue,
                    items: [
                      ComboBoxItem(
                        child: Text(
                          'Media',
                          style: FluentTheme.of(context)
                              .typography
                              .body!
                              .copyWith(fontSize: 16.0),
                        ),
                        value: 0,
                      ),
                      ComboBoxItem(
                        child: Text(
                          'SAF',
                          style: FluentTheme.of(context)
                              .typography
                              .body!
                              .copyWith(fontSize: 16.0),
                        ),
                        value: 1,
                      ),
                      ComboBoxItem(
                        child: Text(
                          I18n.of(context).old_way,
                          style: FluentTheme.of(context)
                              .typography
                              .body!
                              .copyWith(fontSize: 16.0),
                        ),
                        value: 2,
                      ),
                    ],
                    onChanged: (v) {
                      setState(() {
                        this.groupValue = v as int;
                      });
                      if (groupValue == 0 || groupValue == 1) {
                        _animationController.reverse();
                      }
                      if (groupValue == 2) {
                        _animationController.forward();
                      }
                    }),
                IconButton(
                    icon: Icon(FluentIcons.book_answers),
                    onPressed: () async {
                      await launchUrl(Uri.parse(Constants.isGooglePlay ||
                              userSetting.disableBypassSni
                          ? "https://developer.android.com/training/data-storage/shared/documents-files"
                          : "https://developer.android.google.cn/training/data-storage/shared/documents-files"));
                      Navigator.of(context).pop();
                    }),
                IconButton(
                    icon: Icon(FluentIcons.chrome_close),
                    onPressed: () {
                      Navigator.of(context).pop();
                    }),
                if (groupValue == 0)
                  Expanded(
                      child: ListView(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          children: [
                            Text("MediaStore"),
                            Text(I18n.of(context).media_hint)
                          ],
                        ),
                      )
                    ],
                  )),
                if (groupValue == 1)
                  Expanded(
                    child: Stack(
                      children: [
                        ListView(
                          padding: EdgeInsets.all(16.0),
                          children: [
                            Text(I18n.of(context).saf_hint),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 8.0),
                              child: Text(I18n.of(context).step + 1.toString()),
                            ),
                            Image.asset(
                              'assets/images/step1.png',
                              fit: BoxFit.fitWidth,
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 8.0),
                              child: Text(I18n.of(context).step + 2.toString()),
                            ),
                            Image.asset(
                              'assets/images/step2.png',
                              fit: BoxFit.fitWidth,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                if (groupValue == 2)
                  Expanded(
                      child: ListView(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          children: [
                            Text(I18n.of(context).old_way_message),
                            Text(I18n.of(context).legacy_mode_warning)
                          ],
                        ),
                      )
                    ],
                  ))
              ],
            ),
          ),
        );
      }),
    );
  }

  Future _onPress(BuildContext context) async {
    if (groupValue == 0) {
      await userSetting.setSaveMode(0);
      Navigator.of(context).pop();
    } else if (groupValue == 1) {
      await _saffun(context);
      Navigator.of(context).pop();
    } else if (groupValue == 2) {
      DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      print('Running on ${androidInfo.version.sdkInt}');
      if ((androidInfo.version.sdkInt) > 29) {
        BotToast.showText(text: I18n.of(context).legacy_mode_warning);
      }
      await _helplessfun(context, isFirst: widget.isFirst);
      Navigator.of(context).pop();
    }
    if (groupValue == 0 || groupValue == 1) {
      _animationController.reverse();
    }
    if (groupValue == 2) {
      _animationController.forward();
    }
  }
}

Future _saffun(BuildContext context) async {
  await userSetting.setSaveMode(1);
  await DocumentPlugin.choiceFolder();
}

Future _helplessfun(BuildContext context, {bool isFirst = false}) async {
  assert(false);
  await userSetting.setSaveMode(2);
  String? initPath =
      isFirst ? "/storage/emulated/0/Pictures/pixez" : null; //过时api只能硬编码
  final path = await Leader.push(context, DirectoryPage(initPath: initPath));
  if (path != null) {
    final _preferences = await SharedPreferences.getInstance();
    await _preferences.setString('store_path', path);
  }
}
