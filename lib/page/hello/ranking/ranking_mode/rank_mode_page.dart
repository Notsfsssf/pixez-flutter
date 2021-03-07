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

import 'package:flutter/material.dart';
import 'package:pixez/lighting/lighting_page.dart';
import 'package:pixez/main.dart';
import 'package:pixez/network/api_client.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class RankModePage extends StatefulWidget {
  final String? mode;
  final String? date;
  final int? index;

  const RankModePage({Key? key, this.mode, this.date, this.index})
      : super(key: key);

  @override
  _RankModePageState createState() => _RankModePageState();
}

class _RankModePageState extends State<RankModePage> {
  late RefreshController _refreshController;
  late StreamSubscription<String> subscription;

  @override
  void dispose() {
    _refreshController?.dispose();
    subscription?.cancel();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _refreshController = RefreshController();
    subscription = topStore.topStream.listen((event) {
      if (event == (201 + widget.index!).toString()) {
        _refreshController?.position?.jumpTo(0);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return LightingList(
      refreshController: _refreshController,
      source: () => apiClient.getIllustRanking(
        widget.mode!,
        widget.date,
      ),
    );
  }
}
