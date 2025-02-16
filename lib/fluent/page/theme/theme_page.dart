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

import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:pixez/i18n.dart';
import 'package:pixez/main.dart';

class ColorPickPage extends StatefulWidget {
  final Color initialColor;

  ColorPickPage({required this.initialColor});

  @override
  _ColorPickPageState createState() => _ColorPickPageState();
}

class _ColorPickPageState extends State<ColorPickPage> {
  late Color pickerColor;

  @override
  void initState() {
    pickerColor = widget.initialColor;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ContentDialog(
      title: Text(I18n.of(context).pick_a_color),
      content: ColorPicker(
        isAlphaEnabled: false,
        isMoreButtonVisible: false,
        isAlphaSliderVisible: false,
        isAlphaTextInputVisible: false,
        isHexInputVisible: true,
        color: pickerColor,
        onChanged: (color) {
          setState(() {
            pickerColor = color;
          });
        },
      ),
      actions: [
        Button(
          child: Text(I18n.of(context).cancel),
          onPressed: () => Navigator.of(context).pop(),
        ),
        FilledButton(
          child: Text(I18n.of(context).ok),
          onPressed: () => Navigator.of(context).pop(pickerColor),
        ),
      ],
    );
  }
}

class ThemePage extends StatefulWidget {
  @override
  _ThemePageState createState() => _ThemePageState();
}

class _ThemePageState extends State<ThemePage> with TickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Observer(
      builder: (context) => ContentDialog(
        title: Text(I18n.of(context).skin),
        constraints: BoxConstraints(
          maxHeight: userSetting.useDynamicColor ? 350 : 400,
          maxWidth: 400,
        ),
        content: Column(
          children: [
            ListTile(
              title: Text(I18n.of(context).theme),
              trailing: ComboBox<int>(
                items: [
                  ComboBoxItem(child: Text(I18n.of(context).system), value: 0),
                  ComboBoxItem(child: Text(I18n.of(context).light), value: 1),
                  ComboBoxItem(child: Text(I18n.of(context).dark), value: 2),
                ],
                value: ThemeMode.values.indexOf(userSetting.themeMode),
                onChanged: (i) {
                  if (i == null) return;
                  userSetting.setThemeMode(i);
                },
              ),
            ),
            ListTile(
              title: Text(
                "AMOLED",
                style: TextStyle(
                  color: FluentTheme.of(context).accentColor,
                  fontSize: 16,
                ),
              ),
              trailing: ToggleSwitch(
                checked: userSetting.isAMOLED,
                onChanged: (v) => userSetting.setIsAMOLED(v),
              ),
            ),
            ListTile(
              title: Text(
                "Pixiv UWP Style",
                style: TextStyle(
                  color: FluentTheme.of(context).accentColor,
                  fontSize: 16,
                ),
              ),
              trailing: ToggleSwitch(
                checked: userSetting.isTopMode,
                onChanged: (v) => userSetting.setIsTopMode(v),
              ),
            ),
            ListTile(
              // title: Text(I18n.of(context).dynamic_color),
              title: Text(I18n.of(context).system),
              trailing: ToggleSwitch(
                checked: userSetting.useDynamicColor,
                onChanged: (v) => userSetting.setUseDynamicColor(v),
              ),
            ),
            if (!userSetting.useDynamicColor)
              ListTile(
                title: Text(I18n.of(context).seed_color),
                trailing: SizedBox(
                  width: 30,
                  height: 30,
                  child: Container(
                    decoration: BoxDecoration(
                      color: userSetting.seedColor,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                onPressed: _pickColor,
              ),
          ],
        ),
        actions: [
          FilledButton(
            child: Text(I18n.of(context).ok),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  _pickColor() async {
    Color? result = await showDialog(
      context: context,
      builder: (context) => ColorPickPage(
        initialColor: userSetting.seedColor,
      ),
    );
    if (result != null) {
      await userSetting.setThemeData(result);
      topStore.setTop("main");
    }
  }
}
