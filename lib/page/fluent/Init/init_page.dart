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

import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:pixez/i18n.dart';
import 'package:pixez/main.dart';

class InitPage extends StatefulWidget {
  @override
  _InitPageState createState() => _InitPageState();
}

class _InitPageState extends State<InitPage> {
  final languageList = [
    'en-US',
    'zh-CN',
    'zh-TW',
    'ja',
    'ko',
    'ru',
    'es',
    'tr'
  ];
  var currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return ScaffoldPage(
      content: Container(
        child: Center(
          child: Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  I18n.of(context).select_language,
                  style: FluentTheme.of(context).typography.title,
                  textAlign: TextAlign.center,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(32.0),
                child: Center(
                  child: Text("Select Language\n语言选择\n語言選擇\n言語を選択してください"),
                ),
              ),
              ComboBox<int>(
                value: userSetting.languageNum,
                onChanged: (i) async {
                  await userSetting.setLanguageNum(i ?? 0);
                  setState(() {});
                },
                items: [
                  for (int i = 0; i < languageList.length; i++)
                    ComboBoxItem(
                      child: Text(languageList[i]),
                      value: i,
                    )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
