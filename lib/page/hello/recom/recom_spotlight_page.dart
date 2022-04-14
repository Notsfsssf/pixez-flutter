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
import 'package:pixez/constants.dart';
import 'package:pixez/lighting/lighting_store.dart';
import 'package:pixez/main.dart';
import 'package:pixez/network/api_client.dart';
import 'package:pixez/page/hello/recom/fluent_recom_spotlight_state.dart';
import 'package:pixez/page/hello/recom/material_recom_spotlight_state.dart';
import 'package:pixez/page/hello/recom/recom_user_store.dart';
import 'package:pixez/page/hello/recom/spotlight_store.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class RecomSpolightPage extends StatefulWidget {
  final LightingStore? lightingStore;

  RecomSpolightPage({Key? key, this.lightingStore}) : super(key: key);

  @override
  RecomSpolightPageStateBase createState() {
    if (Constants.isFluentUI)
      return FluentRecomSpolightPageState();
    else
      return MaterialRecomSpolightPageState();
  }
}

abstract class RecomSpolightPageStateBase extends State<RecomSpolightPage>
    with AutomaticKeepAliveClientMixin {
  late SpotlightStore spotlightStore;
  late LightingStore lightingStore;
  late RecomUserStore recomUserStore;
  late StreamSubscription<String> subscription;
  late RefreshController easyRefreshController;

  @override
  void dispose() {
    subscription.cancel();
    super.dispose();
  }

  @override
  void initState() {
    easyRefreshController = RefreshController(initialRefresh: true);
    recomUserStore = RecomUserStore();
    spotlightStore = SpotlightStore(null);
    lightingStore = widget.lightingStore ??
        LightingStore(
            ApiForceSource(futureGet: (e) => apiClient.getRecommend()),
            easyRefreshController);
    if (widget.lightingStore != null) {
      lightingStore.controller = easyRefreshController;
    }
    super.initState();
    subscription = topStore.topStream.listen((event) {
      if (event == "100") {
        easyRefreshController.position?.jumpTo(0);
      }
    });
  }

  Future<void> fetchT() async {
    await spotlightStore.fetch();
    await lightingStore.fetch();
    await recomUserStore.fetch();
  }

  @override
  bool get wantKeepAlive => true;
}
