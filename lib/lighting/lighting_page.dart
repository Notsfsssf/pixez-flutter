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
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:pixez/component/illust_card.dart';
import 'package:pixez/generated/l10n.dart';
import 'package:pixez/lighting/lighting_store.dart';
import 'package:pixez/main.dart';
import 'package:pixez/models/illust.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class LightingList extends StatefulWidget {
  final FutureGet source;
  final Widget header;
  final ScrollController scrollController;
  final bool isNested;
  const LightingList(
      {Key key,
      @required this.source,
      this.header,
      this.scrollController,
      this.isNested})
      : super(key: key);

  @override
  _LightingListState createState() => _LightingListState();
}

class _LightingListState extends State<LightingList> {
  LightingStore _store;
  ScrollController _scrollController;
  bool isNested = false;

  @override
  void didUpdateWidget(LightingList oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.source != widget.source) {
      _store.source = widget.source;
      _refreshController.footerMode?.value = LoadStatus.idle;
      _store.fetch();
      if (!isNested && _store.iStores.isNotEmpty) _scrollController.jumpTo(0.0);
    }
  }

  @override
  void initState() {
    isNested = widget.isNested ?? false;
    _store = LightingStore(widget.source, _refreshController);
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
              child: _buildNewRefresh(context),
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

  RefreshController _refreshController = RefreshController();
  Widget _buildNewRefresh(context) {
    return SmartRefresher(
      enablePullDown: true,
      enablePullUp: true,
      footer: CustomFooter(
        builder: (BuildContext context, LoadStatus mode) {
          Widget body;
          if (mode == LoadStatus.idle) {
            body = Text(I18n.of(context).Pull_Up_To_Load_More);
          } else if (mode == LoadStatus.loading) {
            body = CircularProgressIndicator();
          } else if (mode == LoadStatus.failed) {
            body = Text(I18n.of(context).Loading_Failed_Retry_Message);
          } else if (mode == LoadStatus.canLoading) {
            body = Text(I18n.of(context).Let_Go_And_Load_More);
          } else {
            body = Text(I18n.of(context).No_More_Data);
          }
          return Container(
            height: 55.0,
            child: Center(child: body),
          );
        },
      ),
      controller: _refreshController,
      onRefresh: () {
        _store.fetch();
      },
      onLoading: () {
        _store.fetchNext();
      },
      child: _buildWithHeader(context),
    );
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
    return _store.errorMessage != null
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
        : _store.iStores.isNotEmpty ? _buildBody() : Container();
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
              double itemWidth = (screanWidth /userSetting.crossCount.toDouble()) - 32.0;
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
            crossAxisCount: userSetting.crossCount,
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
              double itemWidth = (screanWidth /userSetting.crossCount.toDouble()) - 32.0;
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
            crossAxisCount: userSetting.crossCount,
          );
  }
}
