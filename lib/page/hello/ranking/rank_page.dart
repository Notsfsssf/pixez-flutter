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
import 'package:flutter_cupertino_date_picker/flutter_cupertino_date_picker.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:pixez/generated/l10n.dart';
import 'package:pixez/page/hello/ranking/rank_store.dart';
import 'package:pixez/page/hello/ranking/ranking_mode/rank_mode_page.dart';

class RankPage extends StatefulWidget {
  @override
  _RankPageState createState() => _RankPageState();
}

class _RankPageState extends State<RankPage>
    with AutomaticKeepAliveClientMixin {
  RankStore rankStore;
  final modeList = [
    "day",
    "day_male",
    "day_female",
    "week_original",
    "week_rookie",
    "week",
    "month",
    "day_r18",
    "week_r18",
    "week_r18g"
  ];
  var boolList = Map<int, bool>();
  DateTime nowDate;
  @override
  void initState() {
    nowDate = DateTime.now();
    rankStore = RankStore()..init();
    int i = 0;
    modeList.forEach((element) {
      boolList[i] = false;
      i++;
    });
    super.initState();
  }

  String dateTime;
  String toRequestDate(DateTime dateTime) {
    if (dateTime == null) {
      return null;
    }
    debugPrint("${dateTime.year}-${dateTime.month}-${dateTime.day}");
    return "${dateTime.year}-${dateTime.month}-${dateTime.day}";
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Observer(builder: (_) {
      if (rankStore.modeList.isNotEmpty) {
        var list = I18n.of(context).Mode_List.split(' ');
        List<String> titles = [];
        for (var i = 0; i < rankStore.modeList.length; i++) {
          int index = modeList.indexOf(rankStore.modeList[i]);
          titles.add(list[index]);
        }
        return DefaultTabController(
          length: rankStore.modeList.length,
          child: Column(
            children: <Widget>[
              AppBar(
                title: TabBar(
                    isScrollable: true,
                    tabs: titles
                        .map((element) => Tab(
                              text: element,
                            ))
                        .toList()),
                actions: <Widget>[
                  IconButton(
                    icon: Icon(Icons.date_range),
                    onPressed: () {
                      var theme = Theme.of(context);
                      DatePicker.showDatePicker(context,
                          maxDateTime: DateTime.now(),
                          initialDateTime: nowDate,
                          pickerTheme: DateTimePickerTheme(
                              itemTextStyle: theme.textTheme.subtitle2,
                              backgroundColor: theme.dialogBackgroundColor,
                              confirmTextStyle: theme.textTheme.subtitle1,
                              cancelTextStyle: theme.textTheme.subtitle1),
                          onConfirm: (DateTime dateTime, List<int> list) {
                        nowDate = dateTime;
                        setState(() {
                          this.dateTime = toRequestDate(dateTime);
                        });
                      });
                    },
                  ),
                  IconButton(
                    icon: Icon(Icons.undo),
                    onPressed: () {
                      rankStore.reset();
                    },
                  )
                ],
              ),
              Expanded(
                child: TabBarView(
                    children: rankStore.modeList
                        .map((element) => RankModePage(
                              date: dateTime,
                              mode: element,
                            ))
                        .toList()),
              )
            ],
          ),
        );
      } else {
        return Container(
          child: Column(
            children: <Widget>[
              AppBar(
                title: Text(I18n.of(context).Choice_you_like),
                actions: <Widget>[
                  IconButton(
                    icon: Icon(Icons.save),
                    onPressed: () {
                      rankStore.saveChange(boolList);
                    },
                  )
                ],
              ),
              Expanded(
                child: ListView.builder(
                    padding: EdgeInsets.all(0.0),
                    itemCount: boolList.length,
                    itemBuilder: (context, index) {
                      return CheckboxListTile(
                        title:
                            Text(I18n.of(context).Mode_List.split(' ')[index]),
                        onChanged: (bool value) {
                          setState(() {
                            boolList[index] = value;
                          });
                        },
                        value: boolList[index],
                      );
                    }),
              )
            ],
          ),
        );
      }
    });
  }

  @override
  bool get wantKeepAlive => true;
}
