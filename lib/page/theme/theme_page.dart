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

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
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
    return Scaffold(
      appBar: AppBar(
        title: Text(I18n.of(context).pick_a_color),
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.edit),
              onPressed: () async {
                final TextEditingController textEditingController =
                    TextEditingController(
                        text: pickerColor.value
                            .toString()
                            .toLowerCase()
                            .replaceAll('color(0xff', '')
                            .replaceAll(')', ''));

                String result = await showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: Text("16 radix RGB"),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        content: TextField(
                          controller: textEditingController,
                          maxLength: 6,
                          decoration: InputDecoration(
                              prefix: Text("color(0xff"), suffix: Text(")")),
                        ),
                        actions: <Widget>[
                          TextButton(
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
                          TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: Text(I18n.of(context).cancel)),
                        ],
                      );
                    });
                Color color = _stringToColor(result); //迅速throw出来
                setState(() {
                  pickerColor = color;
                });
              }),
          IconButton(
              icon: Icon(Icons.save),
              onPressed: () {
                Navigator.of(context).pop(pickerColor.value.toString());
              })
        ],
      ),
      body: ListView(
        padding: EdgeInsets.symmetric(vertical: 8.0),
        children: <Widget>[
          ColorPicker(
            enableAlpha: false,
            pickerColor: pickerColor,
            onColorChanged: (Color color) {
              setState(() {
                pickerColor = color;
              });
            },
            showLabel: true,
            pickerAreaHeightPercent: 0.8,
          ),
        ],
      ),
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
  final skinList = [
    ThemeData(
      brightness: Brightness.light,
      primaryColor: Colors.cyan[500],
      accentColor: Colors.cyan[400],
      indicatorColor: Colors.cyan[500],
    ),
    ThemeData(
      brightness: Brightness.light,
      primaryColor: Colors.pink[500],
      accentColor: Colors.pink[400],
      indicatorColor: Colors.pink[500],
    ),
    ThemeData(
      brightness: Brightness.light,
      primaryColor: Colors.green[500],
      accentColor: Colors.green[400],
      indicatorColor: Colors.green[600],
    ),
    ThemeData(
      brightness: Brightness.light,
      primaryColor: Colors.brown[500],
      accentColor: Colors.brown[400],
      indicatorColor: Colors.brown[600],
    ),
    ThemeData(
      brightness: Brightness.light,
      primaryColor: Colors.purple[500],
      accentColor: Colors.purple[400],
      indicatorColor: Colors.purple[600],
    ),
    ThemeData(
      brightness: Brightness.light,
      primaryColor: Colors.blue[500],
      accentColor: Colors.blue[400],
      indicatorColor: Colors.blue[500],
    ),
    ThemeData(
      brightness: Brightness.light,
      primaryColor: Color(0xFFFB7299),
      accentColor: Color(0xFFFB7299),
      indicatorColor: Color(0xFFFB7299),
    ),
  ];

  Future<void> _pickColorData(int index, Color pickerColor) async {
    final result = await Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => ColorPickPage(initialColor: pickerColor)));
    if (result != null) {
      var data = <String>[
        userSetting.themeData.colorScheme.secondary.toString(),
        userSetting.themeData.primaryColor.toString(),
      ];
      data[index] = result;
      userSetting.setThemeData(data);
    }
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Observer(builder: (context) {
      return Scaffold(
        appBar: AppBar(
            title: Text(I18n.of(context).skin),
            bottom: TabBar(
                controller: TabController(
                  length: 3,
                  initialIndex: ThemeMode.values.indexOf(userSetting.themeMode),
                  vsync: this,
                ),
                onTap: (i) {
                  userSetting.setThemeMode(i);
                },
                tabs: [
                  Tab(
                    text: I18n.of(context).system,
                  ),
                  Tab(
                    text: I18n.of(context).light,
                  ),
                  Tab(text: I18n.of(context).dark)
                ])),
        body: ListView(
          children: <Widget>[
            Observer(builder: (_) {
              return Card(
                  child: SwitchListTile(
                value: userSetting.isAMOLED,
                onChanged: (v) => userSetting.setIsAMOLED(v),
                title: Text("AMOLED"),
              ));
            }),
            Card(
                child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    Theme.of(context).colorScheme.secondary.toString(),
                    style: TextStyle(color: Theme.of(context).colorScheme.secondary),
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    InkWell(
                      onTap: () {
                        _pickColorData(0, Theme.of(context).colorScheme.secondary);
                      },
                      child: Container(
                        height: 30,
                        color: Theme.of(context).colorScheme.secondary,
                        child: Center(child: Text("accentColor")),
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        _pickColorData(1, Theme.of(context).primaryColor);
                      },
                      child: Container(
                        height: 30,
                        color: Theme.of(context).primaryColor,
                        child: Center(child: Text("primaryColor")),
                      ),
                    ),
                  ],
                ),
              ],
            )),
            GridView.builder(
                shrinkWrap: true,
                itemCount: skinList.length,
                physics: NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2),
                itemBuilder: (context, index) {
                  final skin = skinList[index];
                  return Card(
                      child: InkWell(
                    onTap: () {
                      userSetting.setThemeData(<String>[
                        skin.colorScheme.secondary.toString(),
                        skin.primaryColor.toString(),
                      ]);
                    },
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text(
                            skin.colorScheme.secondary.toString(),
                            style: TextStyle(color: skin.colorScheme.secondary),
                          ),
                        ),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Container(
                              height: 30,
                              color: skin.primaryColor,
                              child: Center(child: Text("primaryColor")),
                            ),
                            Container(
                              height: 30,
                              color: skin.colorScheme.secondary,
                              child: Center(child: Text("accentColor")),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ));
                })
          ],
        ),
      );
    });
  }
}
