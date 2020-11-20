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

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:pixez/component/painer_card.dart';
import 'package:pixez/generated/l10n.dart';
import 'package:pixez/page/hello/recom/recom_user_store.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class RecomUserPage extends StatefulWidget {
  final RecomUserStore recomUserStore;

  const RecomUserPage({Key key, this.recomUserStore}) : super(key: key);
  @override
  _RecomUserPageState createState() => _RecomUserPageState();
}

class _RecomUserPageState extends State<RecomUserPage> {
  RefreshController _refreshController;
  RecomUserStore _recomUserStore;
  @override
  void initState() {
    _refreshController =
        RefreshController(initialRefresh: widget.recomUserStore == null);
    _recomUserStore =
        widget.recomUserStore ?? RecomUserStore(controller: _refreshController);
    if (widget.recomUserStore != null) {
      _recomUserStore.controller = _refreshController;
    }
    super.initState();
  }

  @override
  void dispose() {
    _recomUserStore?.controller = null;
    _refreshController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Observer(builder: (context) {
      return Scaffold(
        appBar: AppBar(
          title: Text(I18n.of(context).recommend_for_you),
        ),
        body: SmartRefresher(
          header: Platform.isAndroid
              ? MaterialClassicHeader(
                  color: Theme.of(context).accentColor,
                )
              : ClassicHeader(),
          controller: _refreshController,
          enablePullDown: true,
          enablePullUp: true,
          onRefresh: () => _recomUserStore.fetch(),
          onLoading: () => _recomUserStore.next(),
          footer: CustomFooter(
            builder: (BuildContext context, LoadStatus mode) {
              Widget body;
              if (mode == LoadStatus.idle) {
                body = Text(I18n.of(context).pull_up_to_load_more);
              } else if (mode == LoadStatus.loading) {
                body = CircularProgressIndicator();
              } else if (mode == LoadStatus.failed) {
                body = Text(I18n.of(context).loading_failed_retry_message);
              } else if (mode == LoadStatus.canLoading) {
                body = Text(I18n.of(context).let_go_and_load_more);
              } else {
                body = Text(I18n.of(context).no_more_data);
              }
              return Container(
                height: 55.0,
                child: Center(child: body),
              );
            },
          ),
          child: _recomUserStore.users.isNotEmpty
              ? ListView.builder(
                  itemCount: _recomUserStore.users.length,
                  itemBuilder: (context, index) {
                    final data = _recomUserStore.users[index];
                    return PainterCard(
                      user: data,
                    );
                  })
              : Container(),
        ),
      );
    });
  }
}
