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
import 'package:pixez/i18n.dart';
import 'package:pixez/main.dart';
import 'package:pixez/page/about/languages.dart';

class InitPage extends StatefulWidget {
  @override
  _InitPageState createState() => _InitPageState();
}

class _InitPageState extends State<InitPage> {
  final languageList = Languages.map((e) => e.language).toList();
  var currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
      child: Center(
        child: Column(
          children: <Widget>[
            AppBar(
              backgroundColor: Colors.transparent,
              automaticallyImplyLeading: false,
              elevation: 0.0,
              surfaceTintColor: Colors.transparent,
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                I18n.of(context).select_language,
                style: Theme.of(context).textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(32.0),
              child: Center(
                  child: Text("Select Language\n语言选择\n語言選擇\n言語を選択してください")),
            ),
            Observer(builder: (_) {
              return Expanded(
                child: Container(
                  width: MediaQuery.of(context).size.width / 2,
                  child: ListView.builder(
                    itemBuilder: (context, index) {
                      final title = languageList[index];
                      return AnimatedOpacity(
                        duration: Duration(milliseconds: 300),
                        opacity: userSetting.languageNum == index ? 1 : 0.3,
                        child: ListTile(
                          title: Text(title,
                              style: Theme.of(context).textTheme.titleSmall),
                          onTap: () async {
                            await userSetting.setLanguageNum(index);
                            setState(() {});
                          },
                          trailing: Icon(
                            Icons.check,
                            color: userSetting.languageNum == index
                                ? Theme.of(context).textTheme.bodyLarge!.color
                                : Colors.transparent,
                          ),
                        ),
                      );
                    },
                    itemCount: languageList.length,
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    ));
  }
}
