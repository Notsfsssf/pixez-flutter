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

import 'package:flutter/widgets.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:pixez/component/md2_tab_indicator.dart';
import 'package:pixez/constants.dart';
import 'package:pixez/i18n.dart';
import 'package:pixez/main.dart';
import 'package:pixez/page/hello/ranking/fluent_state.dart';
import 'package:pixez/page/hello/ranking/material_state.dart';
import 'package:pixez/page/hello/ranking/rank_store.dart';
import 'package:pixez/page/hello/ranking/ranking_mode/rank_mode_page.dart';

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
  RankPageStateBase createState() {
    if (Constants.isFluentUI)
      return FluentRankPageState();
    else
      return MaterialRankPageState();
  }
}

abstract class RankPageStateBase extends State<RankPage>
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

  List<String> rankFilters = [];

  @override
  bool get wantKeepAlive => true;

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
}
