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
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:pixez/component/fluent/painer_card.dart';
import 'package:pixez/component/fluent/pixez_default_header.dart';
import 'package:pixez/lighting/lighting_store.dart';
import 'package:pixez/page/painter/painter_list_store.dart';

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

    // Load More Detecter
    _scrollController.addListener(() {
      if (_scrollController.position.pixels + 300 >
          _scrollController.position.maxScrollExtent) {
        _easyRefreshController.callLoad();
      }
    });
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
      return EasyRefresh(
        controller: _easyRefreshController,
        header: PixezDefault.header(context),
        onLoad: () => _painterListStore.next(),
        onRefresh: () => _painterListStore.fetch(),
        child: _painterListStore.users.isNotEmpty
            ? LayoutBuilder(
                builder: (context, constraints) {
                  final width = constraints.maxWidth;
                  return CustomScrollView(
                    controller: _scrollController,
                    slivers: [
                      if (widget.header != null)
                        SliverToBoxAdapter(
                          child: widget.header,
                        ),
                      SliverGrid.builder(
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: (width / 300).floor(),
                          childAspectRatio: 1.60,
                        ),
                        itemBuilder: (context, index) {
                          return _itemBuilder(index);
                        },
                        itemCount: _painterListStore.users.length,
                      ),
                    ],
                  );
                },
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
