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

import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:pixez/generated/l10n.dart';
import 'package:pixez/main.dart';

class ThemePage extends StatefulWidget {
  @override
  _ThemePageState createState() => _ThemePageState();
}

class _ThemePageState extends State<ThemePage> {
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

  Color _stringToColor(String colorString) {
    String valueString = colorString.split('(0x')[1].split(')')[0];
    int value = int.parse(valueString, radix: 16);
    Color otherColor = new Color(value);
    return otherColor;
  }

  Future<Void> _pickColorData(int index, Color pickerColor) async {
// raise the [showDialog] widget
    final result = await showDialog(
      context: context,
      child: StatefulBuilder(builder: (context, setC) {
        return AlertDialog(
          title: const Text('Pick a color!'),
          content: SingleChildScrollView(
            padding: EdgeInsets.all(0.0),
            child: ColorPicker(
              pickerColor: pickerColor,
              onColorChanged: (Color color) {
                setC(() {
                  pickerColor = color;
                });
              },
              showLabel: true,
              pickerAreaHeightPercent: 0.8,
            ),
          ),
          actions: <Widget>[
            FlatButton(
              child: const Text('Got it'),
              onPressed: () {
                Navigator.of(context).pop(pickerColor.toString());
              },
            ),
          ],
        );
      }),
    );
    if (result != null) {
      var data = <String>[
        userSetting.themeData.accentColor.toString(),
        userSetting.themeData.primaryColor.toString(),
        userSetting.themeData.indicatorColor.toString()
      ];
      data[index] = result;
      userSetting.setThemeData(data);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Observer(builder: (context) {
      return Scaffold(
        appBar: AppBar(
          title: Text(I18n.of(context).skin),
        ),
        body: ListView(
          children: <Widget>[
            Card(
                child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    Theme.of(context).accentColor.toString(),
                    style: TextStyle(color: Theme.of(context).accentColor),
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    InkWell(
                      onTap: () {
                        _pickColorData(0, Theme.of(context).accentColor);
                      },
                      child: Container(
                        height: 30,
                        color: Theme.of(context).accentColor,
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
                    InkWell(
                      onTap: () {
                        _pickColorData(2, Theme.of(context).indicatorColor);
                      },
                      child: Container(
                        height: 30,
                        color: Theme.of(context).indicatorColor,
                        child: Center(child: Text("indicatorColor")),
                      ),
                    )
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
                        skin.accentColor.toString(),
                        skin.primaryColor.toString(),
                        skin.indicatorColor.toString()
                      ]);
                    },
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text(
                            skin.accentColor.toString(),
                            style: TextStyle(color: skin.accentColor),
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
                              color: skin.accentColor,
                              child: Center(child: Text("accentColor")),
                            ),
                            Container(
                              height: 30,
                              color: skin.indicatorColor,
                              child: Center(child: Text("indicatorColor")),
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
