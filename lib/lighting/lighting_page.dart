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

import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:mobx/mobx.dart';
import 'package:pixez/component/illust_card.dart';
import 'package:pixez/constants.dart';
import 'package:pixez/exts.dart';
import 'package:pixez/i18n.dart';
import 'package:pixez/lighting/lighting_store.dart';
import 'package:pixez/lighting/state/fluent_state.dart';
import 'package:pixez/lighting/state/material_state.dart';
import 'package:pixez/main.dart';
import 'package:pixez/models/illust.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:waterfall_flow/waterfall_flow.dart';

class LightingList extends StatefulWidget {
  final LightSource source;
  final Widget? header;
  final bool? isNested;
  final RefreshController? refreshController;
  final String? portal;

  const LightingList(
      {Key? key,
      required this.source,
      this.header,
      this.isNested,
      this.refreshController,
      this.portal})
      : super(key: key);

  @override
  LightingListStateBase createState() {
    if (Constants.isFluentUI)
      return FluentLightingListState();
    else
      return MaterialLightingListState();
  }
}

abstract class LightingListStateBase extends State<LightingList> {
  late LightingStore store;
  late bool isNested;
  ReactionDisposer? disposer;
  bool backToTopVisible = false;
  late RefreshController refreshController;

  @override
  void didUpdateWidget(LightingList oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.source != widget.source) {
      store.source = widget.source;
      _fetch();
    }
  }

  _fetch() async {
    await store.fetch(force: true);
    if (!isNested && store.errorMessage == null && !store.iStores.isEmpty)
      refreshController.position?.jumpTo(0.0);
  }

  @override
  void initState() {
    isNested = widget.isNested ?? false;
    refreshController = widget.refreshController ?? RefreshController();
    store = LightingStore(
      widget.source,
      refreshController,
    );
    super.initState();
    store.fetch();
  }

  @override
  void dispose() {
    store.dispose();
    super.dispose();
  }

  bool needToBan(Illusts illust) {
    for (var i in muteStore.banillusts) {
      if (i.illustId == illust.id.toString()) return true;
    }
    for (var j in muteStore.banUserIds) {
      if (j.userId == illust.user.id.toString()) return true;
    }
    for (var t in muteStore.banTags) {
      for (var f in illust.tags) {
        if (f.name == t.name) return true;
      }
    }
    return false;
  }

  SliverChildBuilderDelegate buildSliverChildBuilderDelegate(
      BuildContext context) {
    store.iStores.removeWhere((element) => element.illusts!.hateByUser());
    return SliverChildBuilderDelegate((BuildContext context, int index) {
      return IllustCard(
        store: store.iStores[index],
        iStores: store.iStores,
      );
    }, childCount: store.iStores.length);
  }

  SliverWaterfallFlowDelegateWithFixedCrossAxisCount buildGridDelegate() {
    return SliverWaterfallFlowDelegateWithFixedCrossAxisCount(
      crossAxisCount:
          (MediaQuery.of(context).orientation == Orientation.portrait)
              ? userSetting.crossCount
              : userSetting.hCrossCount,
      collectGarbage: (List<int> garbages) {
        // garbages.forEach((index) {
        //   final provider = (
        //     _store.iStores[index].illusts!.imageUrls.medium,
        //   );
        //   provider.evict();
        // });
      },
    );
  }

  Widget buildItem(int index) {
    return IllustCard(
      store: store.iStores[index],
      iStores: store.iStores,
    );
  }
}
