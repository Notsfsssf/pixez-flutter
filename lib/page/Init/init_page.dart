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
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:pixez/main.dart';
import 'package:pixez/page/hello/android_hello_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class InitPage extends StatefulWidget {
  @override
  _InitPageState createState() => _InitPageState();
}

class _InitPageState extends State<InitPage> with TickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        floatingActionButton: FloatingActionButton(
          child: Icon(Icons.arrow_forward),
          onPressed: () async {
            var prefs = await SharedPreferences.getInstance();
            await prefs.setInt('language_num', userSetting.languageNum);
            Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => AndroidHelloPage()));
          },
        ),
        body: Container(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(I18n.of(context).Language),
                ),
                Observer(builder: (_) {
                  return TabBar(
                    labelColor: Theme.of(context).textTheme.headline6.color,
                    indicatorSize: TabBarIndicatorSize.label,
                    tabs: [
                      Tab(
                        text: Text(I18n.of(context).Language_en),
                      ),
                      Tab(
                        text: Text(I18n.of(context).Language_zh-CN),
                      ),
                      Tab(
                        text: Text(I18n.of(context).Language_zh-TW),
                      )
                    ],
                    onTap: (index) async {
                      await userSetting.setLanguageNum(index);
                      setState(() {});
                    },
                    controller: TabController(
                        length: 3,
                        vsync: this,
                        initialIndex: userSetting.languageNum),
                  );
                })
              ],
            ),
          ),
        ));
  }
}
