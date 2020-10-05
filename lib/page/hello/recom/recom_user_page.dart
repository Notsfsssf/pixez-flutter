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
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
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
    _recomUserStore = RecomUserStore(controller: _refreshController);
    if (widget.recomUserStore != null) {
      _recomUserStore.users = widget.recomUserStore.users;
    }
    super.initState();
  }

  @override
  void dispose() {
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
          child: _recomUserStore.users.isNotEmpty
              ? AnimationLimiter(
                  child: ListView.builder(
                      itemCount: _recomUserStore.users.length,
                      itemBuilder: (context, index) {
                        final data = _recomUserStore.users[index];
                        return AnimationConfiguration.staggeredList(
                          position: index,
                          child: SlideAnimation(
                            child: PainterCard(
                              user: data,
                            ),
                          ),
                        );
                      }),
                )
              : Container(),
        ),
      );
    });
  }
}
