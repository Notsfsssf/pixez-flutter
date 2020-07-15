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
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:flutter_easyrefresh/material_header.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:pixez/component/painer_card.dart';
import 'package:pixez/lighting/lighting_store.dart';
import 'package:pixez/page/painter/painter_list_store.dart';

class PainterList extends StatefulWidget {
  final FutureGet futureGet;

  const PainterList({Key key, this.futureGet}) : super(key: key);
  @override
  _PainterListState createState() => _PainterListState();
}

class _PainterListState extends State<PainterList> {
  EasyRefreshController _easyRefreshController;
  PainterListStore _painterListStore;
  @override
  void initState() {
    _easyRefreshController = EasyRefreshController();
    _painterListStore =
        PainterListStore(_easyRefreshController, widget.futureGet);
    super.initState();
  }

  @override
  void didUpdateWidget(PainterList oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.futureGet != widget.futureGet) {
      _painterListStore.source = widget.futureGet;
      _painterListStore.fetch();
    }
  }

  @override
  void dispose() {
    _easyRefreshController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Observer(builder: (_) {
      return EasyRefresh(
        enableControlFinishLoad: true,
        enableControlFinishRefresh: true,
        controller: _easyRefreshController,
        header: MaterialHeader(),
        firstRefresh: true,
        child: _painterListStore.users.isNotEmpty
            ? ListView.builder(
                itemBuilder: (context, index) {
                  return PainterCard(
                    user: _painterListStore.users[index],
                  );
                },
                itemCount: _painterListStore.users.length,
              )
            : Container(),
      );
    });
  }
}
