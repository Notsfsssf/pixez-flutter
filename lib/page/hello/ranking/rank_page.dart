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

import 'dart:async';
import 'dart:io';

import 'package:material_ui/material_ui.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:pixez/component/painter_avatar.dart';
import 'package:pixez/i18n.dart';
import 'package:pixez/main.dart';
import 'package:pixez/page/hello/ranking/rank_store.dart';
import 'package:pixez/page/hello/ranking/ranking_mode/rank_mode_page.dart';
import 'package:pixez/utils/haptic_util.dart';

class RankPage extends StatefulWidget {
  RankPage({Key? key});

  @override
  _RankPageState createState() => _RankPageState();
}

class _RankPageState extends State<RankPage>
    with AutomaticKeepAliveClientMixin {
  late RankStore rankStore;

  final List<String> modeList = [
    "day",
    "day_male",
    "day_female",
    "week_original",
    "week_rookie",
    "week",
    "month",
    "day_ai",
    "day_r18_ai",
    "day_r18",
    "week_r18",
    "week_r18g",
  ];

  late DateTime nowDate;
  late StreamSubscription<String> subscription;
  String? dateTime;

  @override
  void dispose() {
    subscription.cancel();
    super.dispose();
  }

  @override
  void initState() {
    nowDate = DateTime.now();
    rankStore = RankStore();

    super.initState();
    subscription = topStore.topStream.listen((event) {
      if (event == "200") {
        topStore.setTop((201 + index).toString());
      }
    });
  }

  String? toRequestDate(DateTime dateTime) {
    return "${dateTime.year}-${dateTime.month}-${dateTime.day}";
  }

  DateTime nowDateTime = DateTime.now();
  int index = 0;
  int tapCount = 0;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Observer(
      builder: (_) {
        List<String> activeTabs = rankStore.filterState.entries
            .where((entry) => entry.value == true)
            .map((entry) => entry.key)
            .toList();

        return DefaultTabController(
          length: activeTabs.length,
          child: Scaffold(
            appBar: AppBar(
              title: Text(I18n.of(context).rank),
              bottom: TabBar(
                onTap: (i) {
                  HapticUtil.selectionClick();
                  setState(() {
                    this.index = i;
                  });
                },
                tabAlignment: TabAlignment.start,
                indicatorSize: TabBarIndicatorSize.label,
                isScrollable: true,
                tabs: <Widget>[
                  for (var i in activeTabs)
                    Tab(
                      text: I18n.of(
                        context,
                      ).mode_list.split(' ')[modeList.indexOf(i)],
                    ),
                ],
              ),
              actions: <Widget>[
                if (Platform.isAndroid)
                  IconButton(
                    icon: Icon(Icons.fullscreen),
                    onPressed: () {
                      fullScreenStore.toggle();
                    },
                  ),
                Visibility(
                  visible: index < activeTabs.length,
                  child: IconButton(
                    icon: Icon(Icons.date_range),
                    onPressed: () async {
                      await _showTimePicker(context);
                    },
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.filter_alt),
                  onPressed: () {
                    showModalBottomSheet<void>(
                      context: context,
                      showDragHandle: true,
                      builder: (context) {
                        return Container(
                          width: double.infinity,
                          child: Observer(
                            builder: (_) => Padding(
                              padding: EdgeInsetsGeometry.fromLTRB(
                                16,
                                0,
                                16,
                                32,
                              ),
                              child: Wrap(
                                spacing: 4,
                                children: [
                                  for (var e in modeList)
                                    FilterChip(
                                      label: Text(
                                        I18n.of(context).mode_list.split(
                                          ' ',
                                        )[modeList.indexOf(e)],
                                      ),
                                      selected:
                                          rankStore.filterState[e] ?? false,
                                      onSelected: (v) {
                                        rankStore.filterState[e] = v;
                                      },
                                    ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  child: Container(
                    height: 26,
                    width: 26,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 1.0),
                    ),
                    child: PainterAvatar(
                      url: accountStore.now!.userImage,
                      id: int.parse(accountStore.now!.userId),
                    ),
                  ),
                ),
              ],
            ),
            body: TabBarView(
              children: [
                for (var element in activeTabs)
                  RankModePage(
                    date: dateTime,
                    mode: element,
                    index: activeTabs.indexOf(element),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future _showTimePicker(BuildContext context) async {
    var nowdate = DateTime.now();
    var date = await showDatePicker(
      context: context,
      initialDate: nowDateTime,
      locale: userSetting.locale,
      firstDate: DateTime(2007, 8),
      //pixiv于2007年9月10日由上谷隆宏等人首次推出第一个测试版...
      lastDate: nowdate,
    );
    if (date != null && mounted) {
      nowDateTime = date;
      setState(() {
        this.dateTime = toRequestDate(date);
      });
    }
  }

  @override
  bool get wantKeepAlive => true;
}
