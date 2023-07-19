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

import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/material.dart' as material;
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:pixez/i18n.dart';
import 'package:pixez/main.dart';
import 'package:pixez/page/hello/ranking/rank_store.dart';
import 'package:pixez/page/fluent/hello/ranking/ranking_mode/rank_mode_page.dart';

class RankPage extends StatefulWidget {
  late ValueNotifier<bool> isFullscreen;
  late Function? toggleFullscreen;
  RankPage({
    Key? key,
    ValueNotifier<bool>? isFullscreen,
    this.toggleFullscreen,
  }) : super(key: key) {
    this.isFullscreen =
        isFullscreen == null ? ValueNotifier(false) : isFullscreen;
  }

  @override
  _RankPageState createState() => _RankPageState();
}

class _RankPageState extends State<RankPage>
    with AutomaticKeepAliveClientMixin {
  late RankStore rankStore;
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
  late DateTime nowDate;
  late StreamSubscription<String> subscription;
  String? dateTime;

  GlobalKey appBarKey = GlobalKey();
  ValueNotifier<double?> appBarHeightNotifier = ValueNotifier(null);

  @override
  void dispose() {
    subscription.cancel();
    super.dispose();
  }

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
    subscription = topStore.topStream.listen((event) {
      if (event == "200") {
        topStore.setTop((201 + index).toString());
      }
    });

    Future.delayed(
      Duration.zero,
      () {
        if (rankStore.inChoice || rankStore.modeList.isEmpty) {
          final rankListMean = I18n.of(context).mode_list.split(' ');
          _choicePage(context, rankListMean);
        }
      },
    );
  }

  String? toRequestDate(DateTime dateTime) {
    if (dateTime == null) {
      return null;
    }
    return "${dateTime.year}-${dateTime.month}-${dateTime.day}";
  }

  DateTime nowDateTime = DateTime.now();
  int index = 0;
  int tapCount = 0;

  // 获取AppBar的高度，方便实现动画
  Future<double> initAppBarHeight() async {
    Size? appBarSize =
        appBarKey.currentContext?.findRenderObject()?.paintBounds.size;
    if (appBarSize != null) {
      return appBarSize.height;
    } else {
      return 0;
    }
  }

  // 切换全屏状态
  void toggleFullscreen() async {
    if (appBarHeightNotifier.value == null) {
      appBarHeightNotifier.value = await initAppBarHeight();
      // 这里比较hack，因为需要等待appbarHeight从null到固定double类型的重绘
      // 等待50ms使组件重渲染完毕。
      Timer(const Duration(milliseconds: 50), () {
        toggleFullscreen();
      });
      return;
    }
    widget.toggleFullscreen!();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final rankListMean = I18n.of(context).mode_list.split(' ');
    return Observer(builder: (_) {
      if (rankStore.inChoice) {
        return Container(
          child: Center(
            child: FilledButton(
              child: Text(I18n.of(context).choice_you_like),
              onPressed: () => _choicePage(context, rankListMean),
            ),
          ),
        );
      }
      if (rankStore.modeList.isNotEmpty) {
        var list = I18n.of(context).mode_list.split(' ');
        List<String> titles = [];
        for (var i = 0; i < rankStore.modeList.length; i++) {
          int index = modeList.indexOf(rankStore.modeList[i]);
          if (index < 0) {
            debugPrint(rankStore.modeList[i] + ' is -1');
            continue;
          }
          titles.add(list[index]);
        }
        return NavigationView(
          pane: NavigationPane(
              header: CommandBar(
                primaryItems: [
                  if (widget.toggleFullscreen != null)
                    CommandBarButton(
                      icon: Icon(FluentIcons.full_screen),
                      onPressed: () {
                        toggleFullscreen();
                      },
                    ),
                  CommandBarButton(
                    icon: Icon(FluentIcons.reset),
                    onPressed: () {
                      rankStore.reset();
                      _choicePage(context, rankListMean);
                    },
                  )
                ],
                overflowBehavior: CommandBarOverflowBehavior.noWrap,
              ),
              selected: index,
              onChanged: (value) => setState(() => index = value),
              displayMode: PaneDisplayMode.top,
              items: [
                for (int i = 0; i < titles.length; i++)
                  PaneItem(
                    icon: Icon(FluentIcons.context_menu),
                    title: Text(titles[i]),
                    body: RankModePage(
                      date: dateTime,
                      mode: rankStore.modeList[i],
                      index: i,
                    ),
                  ),
              ],
              footerItems: [
                PaneItemAction(
                  icon: Icon(FluentIcons.date_time),
                  onTap: () => _showTimePicker(context),
                )
              ]),
        );
      } else {
        return Container(
          child: Center(
            child: FilledButton(
              child: Text(I18n.of(context).choice_you_like),
              onPressed: () => _choicePage(context, rankListMean),
            ),
          ),
        );
      }
    });
  }

  void _choicePage(BuildContext context, List<String> rankListMean) {
    showDialog(
      context: context,
      builder: (context) => ContentDialog(
        title: Text(I18n.of(context).choice_you_like),
        content: StatefulBuilder(
          builder: (context, setState) => ListView.builder(
            itemCount: rankListMean.length,
            itemBuilder: (context, index) {
              final value = rankListMean[index];
              return Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2.0),
                child: Checkbox(
                  content: Text(value),
                  checked: _rankFilters.contains(value),
                  onChanged: (v) {
                    boolList[rankListMean.indexOf(value)] = v ?? false;
                    if (v ?? false) {
                      setState(() {
                        _rankFilters.add(value);
                      });
                    } else {
                      setState(() {
                        _rankFilters.remove(value);
                      });
                    }
                  },
                ),
              );
            },
          ),
        ),
        actions: [
          FilledButton(
            child: Text(I18n.of(context).ok),
            onPressed: () async {
              await rankStore.saveChange(boolList);
              rankStore.inChoice = false;
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }

  Future _showTimePicker(BuildContext context) async {
    // TODO: fluent_ui的日期选择器好像有点问题
    var nowdate = DateTime.now();
    var date = await material.showDatePicker(
        context: context,
        initialDate: nowDateTime,
        locale: userSetting.locale,
        firstDate: DateTime(2007, 8),
        //pixiv于2007年9月10日由上谷隆宏等人首次推出第一个测试版...
        lastDate: nowdate);
    if (date != null && mounted) {
      nowDateTime = date;
      setState(() {
        this.dateTime = toRequestDate(date);
      });
    }

    // DateTime? current = null;
    // showDialog(
    //   context: context,
    //   builder: (context) => ContentDialog(
    //     title: Text('Choice a Date'),
    //     content: Container(
    //       child: DatePicker(
    //         selected: current,
    //         startDate: DateTime(2007, 8),
    //       ),
    //       width: 300,
    //     ),
    //     actions: [
    //       Button(
    //         child: Text(I18n.of(context).cancel),
    //         onPressed: () => Navigator.of(context).pop(),
    //       ),
    //       FilledButton(
    //         child: Text(I18n.of(context).ok),
    //         onPressed: () {
    //           if (mounted && current != null) {
    //             nowDateTime = current;
    //             setState(() {
    //               this.dateTime = toRequestDate(current);
    //             });
    //           }
    //           Navigator.of(context).pop();
    //         },
    //       ),
    //     ],
    //   ),
    // );
  }

  List<String> _rankFilters = [];

  @override
  bool get wantKeepAlive => true;
}
