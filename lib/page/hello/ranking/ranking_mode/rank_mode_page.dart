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
import 'package:mobx/mobx.dart';
import 'package:pixez/er/lprinter.dart';
import 'package:pixez/lighting/lighting_page.dart';
import 'package:pixez/main.dart';
import 'package:pixez/network/api_client.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class RankModePage extends StatefulWidget {
  final String mode, date;
  final int index;

  const RankModePage({Key key, this.mode, this.date, this.index})
      : super(key: key);

  @override
  _RankModePageState createState() => _RankModePageState();
}

class _RankModePageState extends State<RankModePage> {
  ReactionDisposer disposer;
  RefreshController _refreshController;

  @override
  void dispose() {
    disposer();
    _refreshController?.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _refreshController = RefreshController();
    disposer =
        when((_) => topStore.topName == (201 + widget.index).toString(), () {
      LPrinter.d(widget.index);
      _refreshController.position.jumpTo(0);
    });
  }

  @override
  Widget build(BuildContext context) {
    return LightingList(
      refreshController: _refreshController,
      source: () =>
          apiClient.getIllustRanking(
            widget.mode,
            widget.date,
          ),
    );
  }
}
