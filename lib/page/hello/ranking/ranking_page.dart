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
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_cupertino_date_picker/flutter_cupertino_date_picker.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:pixez/generated/l10n.dart';
import 'package:pixez/main.dart';
import 'package:pixez/page/hello/ranking/bloc.dart';
import 'package:pixez/page/hello/ranking/ranking_mode/rank_mode_page.dart';
import 'package:pixez/page/preview/preview_page.dart';

class RankingPage extends StatefulWidget {
  @override
  _RankingPageState createState() => _RankingPageState();
}

class _RankingPageState extends State<RankingPage>
    with AutomaticKeepAliveClientMixin, SingleTickerProviderStateMixin {
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
  var boolList = Map<String, bool>();

  @override
  void initState() {
    modeList.forEach((f) {
      boolList[f] = false;
    });
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  String toRequestDate(DateTime dateTime) {
    if (dateTime == null) {
      return null;
    }
    debugPrint("${dateTime.year}-${dateTime.month}-${dateTime.day}");
    return "${dateTime.year}-${dateTime.month}-${dateTime.day}";
  }

  String dateTime;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: <BlocProvider>[
        BlocProvider<RankingBloc>(
          create: (context) => RankingBloc()..add(DateChangeEvent(null)),
        ),
      ],
      child: BlocBuilder<RankingBloc, RankingState>(builder: (context, state) {
        if (state is DateState) {
          return DefaultTabController(
            child: Column(
              children: <Widget>[
                AppBar(
                  title: TabBar(
                    isScrollable: true,
                    indicatorSize: TabBarIndicatorSize.label,
                    tabs: state.modeList
                        .map((f) => Tab(
                              text: I18n.of(context)
                                  .Mode_List
                                  .split(' ')[modeList.indexOf(f)],
                            ))
                        .toList(),
                  ),
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
                        BlocProvider.of<RankingBloc>(context).add(ResetEvent());
                      },
                    )
                  ],
                ),
                Expanded(
                  child: TabBarView(
                      children: state.modeList.map((f) {
                    return Observer(builder: (context) {
                      if (accountStore.now != null)
                        return RankModePage(
                          mode: f,
                          date: dateTime,
                        );
                      return LoginInFirst();
                    });
                  }).toList()),
                ),
              ],
            ),
            length: state.modeList.length,
          );
        }
        if (state is ModifyModeListState) {
          return Scaffold(
            appBar: AppBar(
              title: Text(I18n.of(context).Choice_you_like),
              actions: <Widget>[
                IconButton(
                  icon: Icon(Icons.save),
                  onPressed: () {
                    BlocProvider.of<RankingBloc>(context)
                        .add(SaveChangeEvent(boolList));
                  },
                )
              ],
            ),
            body: ListView.builder(
              itemCount: I18n.of(context).Mode_List.split(' ').length,
              itemBuilder: (BuildContext context, int index) {
                return CheckboxListTile(
                  title: Text(I18n.of(context).Mode_List.split(' ')[index]),
                  onChanged: (bool value) {
                    setState(() {
                      boolList[modeList[index]] = value;
                    });
                  },
                  value: boolList[modeList[index]],
                );
              },
            ),
          );
        }
        return Scaffold(
          appBar: AppBar(),
          body: Center(
            child: CircularProgressIndicator(),
          ),
        );
      }),
    );
  }

  DateTime nowDate = DateTime.now();
  AppBar buildAppBar(BuildContext context, List<String> modeList1) {
    List<Widget> tabs = [];
    modeList1.forEach((f) {
      tabs.add(Tab(
        text: I18n.of(context).Mode_List.split(' ')[modeList.indexOf(f)],
      ));
    });
    return AppBar(
      title: TabBar(
        isScrollable: true,
        indicatorSize: TabBarIndicatorSize.label,
        tabs: tabs,
      ),
      actions: <Widget>[
        IconButton(
          icon: Icon(Icons.date_range),
          onPressed: () {
            var theme = Theme.of(context);
            DatePicker.showDatePicker(context,
                initialDateTime: nowDate,
                maxDateTime: DateTime.now(),
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
            BlocProvider.of<RankingBloc>(context).add(ResetEvent());
          },
        )
      ],
    );
  }

  @override
  bool get wantKeepAlive => true;
}
