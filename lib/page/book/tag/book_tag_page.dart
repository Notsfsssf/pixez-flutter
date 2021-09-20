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

import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:md2_tab_indicator/md2_tab_indicator.dart';
import 'package:pixez/i18n.dart';
import 'package:pixez/main.dart';
import 'package:pixez/page/search/result_illust_list.dart';

class BookTagPage extends StatefulWidget {
  @override
  _BookTagPageState createState() => _BookTagPageState();
}

class _BookTagPageState extends State<BookTagPage>
    with TickerProviderStateMixin {
  bool edit = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (edit)
      return Container(
        child: Column(
          children: [
            AppBar(
              elevation: 0.0,
              backgroundColor: Colors.transparent,
              title: Text(I18n.of(context).choice_you_like),
              actions: [
                IconButton(
                    icon: Icon(Icons.save),
                    onPressed: () {
                      setState(() {
                        edit = false;
                      });
                    })
              ],
            ),
            Expanded(child: _buildTagChip())
          ],
        ),
      );
    return Observer(builder: (_) {
      TabController _tabController =
          TabController(length: bookTagStore.bookTagList.length, vsync: this);
      return Scaffold(
        appBar: AppBar(
          elevation: 0.0,
          title: TabBar(
            isScrollable: true,
            controller: _tabController,
            indicatorSize: TabBarIndicatorSize.label,
            indicator: MD2Indicator(
                indicatorHeight: 3,
                indicatorColor: Theme.of(context).primaryColor,
                indicatorSize: MD2IndicatorSize.normal),
            tabs: [
              for (var i in bookTagStore.bookTagList)
                Tab(
                  text: i,
                )
            ],
          ),
          actions: [
            IconButton(
                icon: Icon(
                  Icons.undo,
                ),
                onPressed: () {
                  setState(() {
                    edit = true;
                  });
                }),
          ],
        ),
        body: TabBarView(controller: _tabController, children: [
          for (var j in bookTagStore.bookTagList)
            ResultIllustList(
              word: j,
            )
        ]),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Icon(Icons.close),
        ),
        endDrawer: Drawer(
          child: ListView(
            children: [
              for (var j in bookTagStore.bookTagList)
                ListTile(
                  title: Text(j),
                  onTap: () {
                    _tabController
                        .animateTo(bookTagStore.bookTagList.indexOf(j));
                  },
                )
            ],
          ),
        ),
      );
    });
  }

  Widget _buildTagChip() {
    return SingleChildScrollView(
      child: Column(
        children: [
          Wrap(
            spacing: 2.0,
            children: [
              for (var i in bookTagStore.bookTagList)
                FilterChip(
                    label: Text(i),
                    selected: true,
                    onSelected: (v) {
                      showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              title: Text(I18n.of(context).delete + "$i?"),
                              actions: [
                                TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                    child: Text(I18n.of(context).cancel)),
                                TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                      bookTagStore.unBookTag(i);
                                    },
                                    child: Text(I18n.of(context).ok)),
                              ],
                            );
                          });
                    })
            ],
          ),
        ],
      ),
    );
  }
}
