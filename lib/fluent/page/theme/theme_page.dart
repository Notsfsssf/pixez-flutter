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

import 'package:fluent_ui/fluent_ui.dart' hide ColorPicker;
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:pixez/component/picker/colorpicker.dart';
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
      title: PageHeader(
        title: Text(I18n.of(context).pick_a_color),
        commandBar: CommandBar(
          primaryItems: [
            CommandBarButton(
                icon: Icon(FluentIcons.edit),
                onPressed: () async {
                  final TextEditingController textEditingController =
                      TextEditingController(
                          text: pickerColor.colorValue
                              .toString()
                              .toLowerCase()
                              .replaceAll('color(0xff', '')
                              .replaceAll(')', ''));

                  String? result = await showDialog<String>(
                      context: context,
                      builder: (context) {
                        return ContentDialog(
                          title: Text("16 radix RGB"),
                          content: TextBox(
                              controller: textEditingController,
                              maxLength: 6,
                              prefix: Text("color(0xff"),
                              suffix: Text(")")),
                          actions: <Widget>[
                            Button(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: Text(I18n.of(context).cancel)),
                            FilledButton(
                                onPressed: () {
                                  final result = textEditingController.text
                                      .trim()
                                      .toLowerCase();
                                  if (result.length != 6) {
                                    return;
                                  }
                                  Navigator.of(context)
                                      .pop("color(0xff${result})");
                                },
                                child: Text(I18n.of(context).ok)),
                          ],
                        );
                      });
                  if (result == null) return;
                  Color color = _stringToColor(result); //迅速throw出来
                  setState(() {
                    pickerColor = color;
                  });
                }),
          ],
        ),
      ),
      content: Container(
        width: 800,
        child: ColorPicker(
          enableAlpha: false,
          pickerColor: pickerColor,
          onColorChanged: (Color color) {
            setState(() {
              pickerColor = color;
            });
          },
          pickerAreaHeightPercent: 0.8,
        ),
      ),
      actions: [
        FilledButton(
          child: Text(I18n.of(context).save),
          onPressed: () {
            Navigator.of(context).pop(pickerColor);
          },
        ),
      ],
    );
  }

  Color _stringToColor(String colorString) {
    String valueString =
        colorString.split('(0x')[1].split(')')[0]; // kind of hacky..
    int value = int.parse(valueString, radix: 16);
    Color otherColor = new Color(value);
    return otherColor;
  }
}

class ThemePage extends StatefulWidget {
  @override
  _ThemePageState createState() => _ThemePageState();
}

class _ThemePageState extends State<ThemePage> with TickerProviderStateMixin {
  List<AccentColor> colorList = [
    Color(0xFF26C6DA).toAccentColor(),
    Color(0xFFEC407A).toAccentColor(),
    Color(0xFF66BB6A).toAccentColor(),
    Color(0xFF8D6E63).toAccentColor(),
    Color(0xFFAB47BC).toAccentColor(),
    Color(0xFF42A5F5).toAccentColor(),
    Color(0xFFFB7299).toAccentColor(),
  ];

  Future<void> _pickColorData(int index, Color pickerColor) async {
    // TODO: 不支持 Color Picker
    // Color? result = await showDialog(
    //   context: context,
    //   builder: (context) => ColorPickPage(initialColor: pickerColor),
    //   useRootNavigator: false,
    // );
    // if (result != null) {
    //   var data = <String>[
    //     userSetting.themeData.primaryColor.toString(),
    //     userSetting.themeData.primaryColor.toString(),
    //   ];
    //   data[index] = "(0x${result.value.toRadixString(16)})";
    //   userSetting.setThemeData(data);
    // }
    // todo 修改无效
    userSetting.setThemeData(pickerColor);
  }

  @override
  void initState() {
    super.initState();
    // colorList = Colors.accentColors;
  }

  Widget buildThemeCard(AccentColor color) {
    return Card(
      padding: EdgeInsets.zero,
      child: IconButton(
        onPressed: () => _pickColorData(0, color.normal),
        icon: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(color.toString(), style: TextStyle(color: color)),
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                ColoredBox(
                  color: color,
                  child: SizedBox(
                    height: 30,
                    child: Center(child: Text("accentColor")),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Observer(builder: (context) {
      return ContentDialog(
        title: Row(children: [
          Text(I18n.of(context).skin),
          Spacer(),
          ComboBox<int>(
            items: [
              ComboBoxItem(child: Text(I18n.of(context).system), value: 0),
              ComboBoxItem(child: Text(I18n.of(context).light), value: 1),
              ComboBoxItem(child: Text(I18n.of(context).dark), value: 2),
            ],
            value: ThemeMode.values.indexOf(userSetting.themeMode),
            onChanged: (i) => i == null ? null : userSetting.setThemeMode(i),
          ),
          SizedBox(width: 8),
          Observer(
            builder: (_) => ToggleSwitch(
              checked: userSetting.isAMOLED,
              onChanged: (v) => userSetting.setIsAMOLED(v),
              content: Text(
                "AMOLED",
                style: TextStyle(
                  color: FluentTheme.of(context).accentColor,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ]),
        constraints: BoxConstraints(maxHeight: 500, maxWidth: 800),
        content: SingleChildScrollView(
          child: GridView(
            shrinkWrap: true,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 3,
              crossAxisSpacing: 8.0,
              mainAxisSpacing: 8.0,
            ),
            padding: EdgeInsets.all(8),
            children: colorList.map(buildThemeCard).toList(),
          ),
        ),
        actions: [
          FilledButton(
            child: Text(I18n.of(context).ok),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      );
    });
  }
}
