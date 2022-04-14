/*
 * Copyright (C) 2020. by perol_notsf, All rights reserved
 *
 * This program is free software: you can redistribute it and/or modify it under
 * the terms of the GNU General Public License as published by the Free Software
 * Foundation, either version 3 of the License, or (at your option) any later version.
 *
 *  This program is distributed in the hope that it will be useful, but WITHOUT ANY
 *  WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
 *  FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License along with
 *  this program. If not, see <http://www.gnu.org/licenses/>.
 */


import 'package:flutter/widgets.dart';
import 'package:pixez/constants.dart';
import 'package:pixez/page/hello/recom/recom_user_store.dart';
import 'package:pixez/page/hello/recom/user_page/fluent_state.dart';
import 'package:pixez/page/hello/recom/user_page/material_state.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class RecomUserPage extends StatefulWidget {
  final RecomUserStore? recomUserStore;

  const RecomUserPage({Key? key, this.recomUserStore}) : super(key: key);

  @override
  RecomUserPageStateBase createState() {
    if (Constants.isFluentUI)
      return FluentRecomUserPageState();
    else
      return MaterialRecomUserPageState();
  }
}

abstract class RecomUserPageStateBase extends State<RecomUserPage> {
  late RefreshController refreshController;
  late RecomUserStore recomUserStore;

  @override
  void initState() {
    refreshController =
        RefreshController(initialRefresh: widget.recomUserStore == null);
    recomUserStore =
        widget.recomUserStore ?? RecomUserStore(controller: refreshController);
    if (widget.recomUserStore != null) {
      recomUserStore.controller = refreshController;
    }
    super.initState();
  }

  @override
  void dispose() {
    recomUserStore.controller = null;
    refreshController.dispose();
    super.dispose();
  }
}
