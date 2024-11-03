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

import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:pixez/component/painer_card.dart';
import 'package:pixez/component/pixez_default_header.dart';
import 'package:pixez/lighting/lighting_store.dart';
import 'package:pixez/page/painter/painter_list_store.dart';
import 'package:waterfall_flow/waterfall_flow.dart';

class PainterList extends StatefulWidget {
  final FutureGet futureGet;
  final bool isNovel;
  final Widget? header;

  const PainterList(
      {Key? key, required this.futureGet, this.isNovel = false, this.header})
      : super(key: key);

  @override
  _PainterListState createState() => _PainterListState();
}

class _PainterListState extends State<PainterList> {
  late EasyRefreshController _easyRefreshController;
  late PainterListStore _painterListStore;
  late ScrollController _scrollController;

  @override
  void initState() {
    _scrollController = ScrollController();
    _easyRefreshController = EasyRefreshController(
        controlFinishLoad: true, controlFinishRefresh: true);
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
      _easyRefreshController.resetFooter();
      _painterListStore.fetch();
      if (_painterListStore.users.isNotEmpty && _scrollController.hasClients)
        _scrollController.jumpTo(0.0);
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
      return EasyRefresh(
        controller: _easyRefreshController,
        header: PixezDefault.header(context),
        onLoad: () => _painterListStore.next(),
        onRefresh: () => _painterListStore.fetch(),
        child: _painterListStore.users.isNotEmpty
            ? CustomScrollView(
                controller: _scrollController,
                slivers: [
                  if (widget.header != null)
                    SliverToBoxAdapter(
                      child: widget.header!,
                    ),
                  _buildList(),
                ],
              )
            : Container(),
      );
    });
  }

  Widget _buildList() {
    return SliverWaterfallFlow(
      delegate: SliverChildBuilderDelegate((context, index) {
        final data = _painterListStore.users[index];
        return PainterCard(
          user: data,
          isNovel: widget.isNovel,
        );
      }, childCount: _painterListStore.users.length),
      gridDelegate: SliverWaterfallFlowDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 600),
    );
  }
}
