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

import 'package:flutter/material.dart';
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
  ];

  Color _stringToColor(String colorString) {
    String valueString = colorString.split('(0x')[1].split(')')[0];
    int value = int.parse(valueString, radix: 16);
    Color otherColor = new Color(value);
    return otherColor;
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
                    Container(
                      height: 30,
                      color: Theme.of(context).primaryColor,
                      child: Center(child: Text("primaryColor")),
                    ),
                    Container(
                      height: 30,
                      color: Theme.of(context).accentColor,
                      child: Center(child: Text("accentColor")),
                    ),
                    Container(
                      height: 30,
                      color: Theme.of(context).indicatorColor,
                      child: Center(child: Text("indicatorColor")),
                    ),
                  ],
                ),
              ],
            )),
            GridView.builder(
                shrinkWrap: true,
                itemCount: skinList.length,
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
