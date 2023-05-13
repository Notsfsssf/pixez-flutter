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
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:pixez/i18n.dart';
import 'package:pixez/main.dart';
import 'package:pixez/page/hello/ranking/rank_store.dart';
import 'package:pixez/page/fluent/hello/ranking/ranking_mode/rank_mode_page.dart';

/* TODO
 * 这个页面需要重新设计，不可以简单的照搬原来的设计。
 * see https://learn.microsoft.com/zh-cn/windows/apps/design/basics/navigation-basics
 * 我认为现在的设计不能满足一致性。
 */

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
    return ScaffoldPage(
      content: Observer(builder: (_) {
        if (rankStore.inChoice) {
          return _buildChoicePage(context, rankListMean);
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
          return TabView(
            closeButtonVisibility: CloseButtonVisibilityMode.never,
            currentIndex: index,
            onChanged: (value) => index = value,
            tabs: [
              for (int i = 0; i < titles.length; i++)
                Tab(
                  text: Text(titles[i]),
                  body: RankModePage(
                    date: dateTime,
                    mode: rankStore.modeList[i],
                    index: i,
                  ),
                ),
            ],
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
                  icon: Icon(FluentIcons.undo),
                  onPressed: () {
                    rankStore.reset();
                  },
                )
              ],
              overflowBehavior: CommandBarOverflowBehavior.noWrap,
            ),
            footer: index >= rankStore.modeList.length
                ? Container()
                : DatePicker(
                    selected: nowDateTime,
                    onChanged: (date) {
                      if (mounted) {
                        nowDateTime = date;
                        setState(() {
                          this.dateTime = toRequestDate(date);
                        });
                      }
                    },
                    startYear: 2007,
                  ),
          );
        } else {
          return _buildChoicePage(context, rankListMean);
        }
      }),
    );
  }

  Widget _buildChoicePage(BuildContext context, List<String> rankListMean) {
    return ScaffoldPage(
      header: PageHeader(
        title: Text(I18n.of(context).choice_you_like),
        commandBar: CommandBar(
          mainAxisAlignment: MainAxisAlignment.end,
          primaryItems: [
            CommandBarButton(
              icon: Icon(FluentIcons.save),
              onPressed: () async {
                await rankStore.saveChange(boolList);
                rankStore.inChoice = false;
              },
            )
          ],
        ),
      ),
      content: Padding(
        padding: EdgeInsets.all(8.0),
        child: Wrap(
          spacing: 4,
          children: [
            for (var e in rankListMean)
              Container(
                margin: EdgeInsets.all(8),
                child: Checkbox(
                  content: Text(e),
                  checked: _rankFilters.contains(e),
                  onChanged: (v) {
                    boolList[rankListMean.indexOf(e)] = v ?? false;
                    if (v ?? false) {
                      setState(() {
                        _rankFilters.add(e);
                      });
                    } else {
                      setState(() {
                        _rankFilters.remove(e);
                      });
                    }
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  List<String> _rankFilters = [];

  @override
  bool get wantKeepAlive => true;
}
