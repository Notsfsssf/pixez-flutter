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
import 'package:pixez/component/sort_group.dart';
import 'package:pixez/constants.dart';
import 'package:pixez/i18n.dart';
import 'package:pixez/lighting/lighting_page.dart';
import 'package:pixez/lighting/lighting_store.dart';
import 'package:pixez/main.dart';
import 'package:pixez/network/api_client.dart';
import 'package:pixez/page/hello/new/illust/fluent_new_illust_state.dart';
import 'package:pixez/page/hello/new/illust/material_new_illust_state.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class NewIllustPage extends StatefulWidget {
  final String restrict;

  const NewIllustPage({Key? key, this.restrict = "all"}) : super(key: key);

  @override
  NewIllustPageStateBase createState() {
    if (Constants.isFluentUI)
      return FluentNewIllustPageState();
    else
      return MaterialNewIllustPageState();
  }
}

abstract class NewIllustPageStateBase extends State<NewIllustPage> {
  late ApiForceSource futureGet;
  late RefreshController refreshController;
  late StreamSubscription<String> subscription;

  @override
  void initState() {
    refreshController = RefreshController();
    futureGet = ApiForceSource(
        futureGet: (e) =>
            apiClient.getFollowIllusts(widget.restrict, force: e));
    super.initState();
    subscription = topStore.topStream.listen((event) {
      if (event == "301") {
        refreshController.position?.jumpTo(0);
      }
    });
  }

  @override
  void dispose() {
    subscription.cancel();
    refreshController.dispose();
    super.dispose();
  }
}
