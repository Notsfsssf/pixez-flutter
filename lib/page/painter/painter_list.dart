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

import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:pixez/component/painer_card.dart';
import 'package:pixez/i18n.dart';
import 'package:pixez/lighting/lighting_store.dart';
import 'package:pixez/page/painter/painter_list_store.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class PainterList extends StatefulWidget {
  final FutureGet futureGet;
  final bool isNovel;
  final Widget? header;

  const PainterList(
      {Key? key,
      required this.futureGet,
      this.isNovel = false,
      this.header})
      : super(key: key);

  @override
  _PainterListState createState() => _PainterListState();
}

class _PainterListState extends State<PainterList> {
  late RefreshController _easyRefreshController;
  late PainterListStore _painterListStore;
  late ScrollController _scrollController;

  @override
  void initState() {
    _scrollController = ScrollController();
    _easyRefreshController = RefreshController();
    _painterListStore =
        PainterListStore(_easyRefreshController, widget.futureGet);
    super.initState();
    _painterListStore.fetch();
  }

  @override
  void didUpdateWidget(PainterList oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.futureGet != widget.futureGet) {
      _painterListStore.source = widget.futureGet;
      _easyRefreshController.footerMode?.value = LoadStatus.idle;
      _painterListStore.fetch();
      if (_painterListStore.users.isNotEmpty) _scrollController.jumpTo(0.0);
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _easyRefreshController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Observer(builder: (_) {
      return SmartRefresher(
        enablePullDown: true,
        enablePullUp: true,
        header: (Platform.isAndroid)
            ? MaterialClassicHeader(
                color: Theme.of(context).accentColor,
              )
            : ClassicHeader(),
        footer: CustomFooter(
          builder: (BuildContext context, LoadStatus? mode) {
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
        controller: _easyRefreshController,
        onLoading: () => _painterListStore.next(),
        onRefresh: () => _painterListStore.fetch(),
        child: _painterListStore.users.isNotEmpty
            ? ListView.builder(
                controller: _scrollController,
                itemBuilder: (context, index) {
                  if (index == 0 && widget.header != null) {
                    return widget.header!;
                  }

                  if (widget.header != null) return _itemBuilder(index - 1);
                  return _itemBuilder(index);
                },
                itemCount: widget.header == null
                    ? _painterListStore.users.length
                    : _painterListStore.users.length + 1,
              )
            : Container(),
      );
    });
  }

  Widget _itemBuilder(int index) {
    final user = _painterListStore.users[index];
    if (widget.isNovel)
      return PainterCard(
        user: user,
        isNovel: widget.isNovel,
      );
    return PainterCard(
      user: user,
    );
  }
}
