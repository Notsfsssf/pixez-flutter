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

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:pixez/component/picker/colorpicker.dart';
import 'package:pixez/component/picker/utils.dart';
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

  final skinList = [
    ThemeData(
      brightness: Brightness.light,
      primaryColor: Colors.cyan[500],
      indicatorColor: Colors.cyan[500],
    ),
    ThemeData(
      brightness: Brightness.light,
      primaryColor: Colors.pink[500],
      indicatorColor: Colors.pink[500],
    ),
    ThemeData(
      brightness: Brightness.light,
      primaryColor: Colors.green[500],
      indicatorColor: Colors.green[600],
    ),
    ThemeData(
      brightness: Brightness.light,
      primaryColor: Colors.brown[500],
      indicatorColor: Colors.brown[600],
    ),
    ThemeData(
      brightness: Brightness.light,
      primaryColor: Colors.purple[500],
      indicatorColor: Colors.purple[600],
    ),
    ThemeData(
      brightness: Brightness.light,
      primaryColor: Colors.blue[500],
      indicatorColor: Colors.blue[500],
    ),
    ThemeData(
      brightness: Brightness.light,
      primaryColor: Color(0xFFFB7299),
      indicatorColor: Color(0xFFFB7299),
    ),
  ];

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
                        text: pickerColor.toHexString(
                            includeHashSign: true,
                            enableAlpha: false,
                            toUpperCase: false));

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
                Navigator.of(context).pop(pickerColor);
              })
        ],
      ),
      body: LayoutBuilder(builder: (context, snapshot) {
        final rowCount = max(3, (snapshot.maxWidth / 200).floor());
        return CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
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
            ),
            SliverGrid.count(
              crossAxisCount: rowCount,
              children: [
                for (final i in skinList)
                  InkWell(
                    onTap: () {
                      setState(() {
                        pickerColor = i.primaryColor;
                      });
                    },
                    child: Container(
                      margin: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: i.primaryColor,
                      ),
                    ),
                  )
              ],
            )
          ],
        );
      }),
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
        body: Observer(builder: (_) {
          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Card(
                    child: SwitchListTile(
                  value: userSetting.isAMOLED,
                  onChanged: (v) => userSetting.setIsAMOLED(v),
                  title: Text("AMOLED"),
                )),
              ),
              SliverToBoxAdapter(
                child: Card(
                    child: SwitchListTile(
                  value: userSetting.useDynamicColor,
                  onChanged: (v) async {
                    await userSetting.setUseDynamicColor(v);
                    topStore.setTop("main");
                  },
                  title: Text(I18n.of(context).dynamic_color),
                )),
              ),
              if (!userSetting.useDynamicColor)
                SliverToBoxAdapter(
                  child: Card(
                    child: ListTile(
                      leading: SizedBox(
                        width: 30,
                        height: 30,
                        child: Container(
                          decoration: BoxDecoration(
                              color: userSetting.seedColor,
                              borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                      title: Text(I18n.of(context).seed_color),
                      onTap: () {
                        _pickColor();
                      },
                    ),
                  ),
                )
            ],
          );
        }),
      );
    });
  }

  _pickColor() async {
    Color? result = await Navigator.of(context).push(MaterialPageRoute(
        builder: (context) =>
            ColorPickPage(initialColor: userSetting.seedColor)));
    if (result != null) {
      await userSetting.setThemeData(result);
      topStore.setTop("main");
    }
  }
}
