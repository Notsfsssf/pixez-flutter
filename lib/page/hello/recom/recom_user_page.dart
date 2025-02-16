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

import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:pixez/component/painer_card.dart';
import 'package:pixez/i18n.dart';
import 'package:pixez/page/hello/recom/recom_user_store.dart';
import 'package:waterfall_flow/waterfall_flow.dart';

class RecomUserPage extends StatefulWidget {
  final RecomUserStore? recomUserStore;

  const RecomUserPage({Key? key, this.recomUserStore}) : super(key: key);

  @override
  _RecomUserPageState createState() => _RecomUserPageState();
}

class _RecomUserPageState extends State<RecomUserPage> {
  late EasyRefreshController _refreshController;
  late RecomUserStore _recomUserStore;

  @override
  void initState() {
    _refreshController = EasyRefreshController(
        controlFinishLoad: true, controlFinishRefresh: true);
    _recomUserStore =
        widget.recomUserStore ?? RecomUserStore(_refreshController);
    if (widget.recomUserStore != null) {
      _recomUserStore.controller = _refreshController;
    }
    super.initState();
  }

  @override
  void dispose() {
    _recomUserStore.controller = null;
    _refreshController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Observer(builder: (context) {
      return Scaffold(
        appBar: AppBar(
          title: Text(I18n.of(context).recommend_for_you),
        ),
        body: EasyRefresh(
          controller: _refreshController,
          onRefresh: () => _recomUserStore.fetch(),
          onLoad: () => _recomUserStore.next(),
          refreshOnStart: widget.recomUserStore == null,
          child: _buildList(),
        ),
      );
    });
  }

  Widget _buildList() {
    return WaterfallFlow.builder(
      gridDelegate: SliverWaterfallFlowDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 600,
      ),
      itemCount: _recomUserStore.users.length,
      itemBuilder: (context, index) {
        final data = _recomUserStore.users[index];
        return PainterCard(
          user: data,
        );
      },
    );
  }
}
