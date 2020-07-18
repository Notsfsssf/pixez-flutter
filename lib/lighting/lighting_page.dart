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
import 'package:flutter/widgets.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:flutter_easyrefresh/material_header.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:pixez/component/illust_card.dart';
import 'package:pixez/lighting/lighting_store.dart';
import 'package:pixez/main.dart';
import 'package:pixez/models/illust.dart';

class LightingList extends StatefulWidget {
  final EasyRefreshController controller;
  final FutureGet source;
  final Widget header;
  final ScrollController scrollController;
  final bool isNested;
  const LightingList(
      {Key key,
      @required this.source,
      this.controller,
      this.header,
      this.scrollController,
      this.isNested})
      : super(key: key);

  @override
  _LightingListState createState() => _LightingListState();
}

class _LightingListState extends State<LightingList> {
  LightingStore _store;
  EasyRefreshController _easyRefreshController;
  ScrollController _scrollController;
  bool isNested=false;
  @override
  void didUpdateWidget(LightingList oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.source != widget.source) {
      _store.source = widget.source;
      _store.fetch();
      if (!isNested) _scrollController.jumpTo(0.0);
      // _easyRefreshController.callRefresh();
    }
  }

  @override
  void initState() {
    isNested = widget.isNested ?? false;
    _easyRefreshController = widget.controller ?? EasyRefreshController();
    _store = LightingStore(widget.source, _easyRefreshController);
    _scrollController = widget.scrollController ?? ScrollController();
    // _scrollController.addListener(() {
    //   bool temp;
    //   if (_scrollController.offset > 400) {
    //     temp = true;
    //   } else {
    //     temp = false;
    //   }
    //   if (temp != backToTopEnable) {
    //     setState(() {
    //       setState(() {
    //         this.backToTopEnable = temp;
    //       });
    //     });
    //   }
    // });
    super.initState();
    _store.fetch();
  }

  @override
  void dispose() {
    _easyRefreshController?.dispose();
    _scrollController?.dispose();
    super.dispose();
  }

  bool backToTopEnable = false;
  @override
  Widget build(BuildContext context) {
    return Observer(builder: (_) {
      return Container(
        child: Stack(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(top: widget.header == null ? 0 : 36.0),
              child: _buildWithHeader(context),
            ),
            Align(
              alignment: Alignment.topCenter,
              child: Container(
                    height: 36,
                    child: widget.header,
                  ) ??
                  Visibility(
                    child: Container(),
                    visible: false,
                  ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Visibility(
                visible: backToTopEnable,
                child: IconButton(
                    padding: EdgeInsets.all(0.0),
                    icon: Icon(Icons.expand_less),
                    onPressed: () {
                      _scrollController.jumpTo(0.0);
                    }),
              ),
            )
          ],
        ),
      );
    });
  }

  bool needToBan(Illusts illust) {
    for (var i in muteStore.banillusts) {
      if (i.illustId == illust.id.toString()) return true;
    }
    for (var j in muteStore.banUserIds) {
      if (j.userId == illust.user.id.toString()) return true;
    }
    for (var t in muteStore.banTags) {
      for (var f in illust.tags) {
        if (f.name == t.name) return true;
      }
    }
    return false;
  }

  Widget _buildWithHeader(BuildContext context) {
    return EasyRefresh(
      header: MaterialHeader(),
      controller: _easyRefreshController,
      enableControlFinishLoad: true,
      enableControlFinishRefresh: true,
      onRefresh: () {
        return _store.fetch();
      },
      onLoad: () {
        return _store.fetchNext();
      },
      child: _store.errorMessage != null
          ? Container(
              child: Column(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Container(
                    height: 90,
                  ),
                  Text(':(', style: Theme.of(context).textTheme.headline4),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text('${_store.errorMessage}'),
                  )
                ],
              ),
            )
          : _buildNoHeader(context),
    );
  }

  Widget _buildBody() {
    return isNested
        ? StaggeredGridView.countBuilder(
            padding: EdgeInsets.all(0.0),
            itemBuilder: (context, index) {
              return IllustCard(
                store: _store.iStores[index],
                iStores: _store.iStores,
              );
            },
            staggeredTileBuilder: (int index) {
              if (needToBan(_store.iStores[index].illusts))
                return StaggeredTile.extent(1, 0.0);
              double screanWidth = MediaQuery.of(context).size.width;
              double itemWidth = (screanWidth / 2.0) - 32.0;
              double radio = _store.iStores[index].illusts.height.toDouble() /
                  _store.iStores[index].illusts.width.toDouble();
              double mainAxisExtent;
              if (radio > 3)
                mainAxisExtent = itemWidth;
              else
                mainAxisExtent = itemWidth * radio;
              return StaggeredTile.extent(1, mainAxisExtent + 80.0);
            },
            itemCount: _store.iStores.length,
            crossAxisCount: 2,
          )
        : StaggeredGridView.countBuilder(
            padding: EdgeInsets.all(0.0),
            controller: _scrollController,
            itemBuilder: (context, index) {
              return IllustCard(
                store: _store.iStores[index],
                iStores: _store.iStores,
              );
            },
            staggeredTileBuilder: (int index) {
              if (needToBan(_store.iStores[index].illusts))
                return StaggeredTile.extent(1, 0.0);
              double screanWidth = MediaQuery.of(context).size.width;
              double itemWidth = (screanWidth / 2.0) - 32.0;
              double radio = _store.iStores[index].illusts.height.toDouble() /
                  _store.iStores[index].illusts.width.toDouble();
              double mainAxisExtent;
              if (radio > 3)
                mainAxisExtent = itemWidth;
              else
                mainAxisExtent = itemWidth * radio;
              return StaggeredTile.extent(1, mainAxisExtent + 80.0);
            },
            itemCount: _store.iStores.length,
            crossAxisCount: 2,
          );
  }

  Widget _buildNoHeader(BuildContext context) {
    return _store.iStores.isNotEmpty ? _buildBody() : Container();
  }
}
