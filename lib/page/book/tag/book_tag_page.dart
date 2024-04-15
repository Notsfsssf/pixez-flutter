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

  late TabController _tabController;

  @override
  void initState() {
    _tabController =
        TabController(length: bookTagStore.bookTagList.length, vsync: this);
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (edit)
      return Observer(builder: (context) {
        return Container(
          child: Column(
            children: [
              AppBar(
                elevation: 0.0,
                backgroundColor: Colors.transparent,
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
      });
    return Observer(builder: (_) {
      if (_tabController.length != bookTagStore.bookTagList.length) {
        var index = (_tabController.index >= bookTagStore.bookTagList.length)
            ? bookTagStore.bookTagList.length - 1
            : _tabController.index;
        index = (index < 0) ? 0 : index;
        _tabController = TabController(
            initialIndex: index,
            length: bookTagStore.bookTagList.length,
            vsync: this);
      }
      return Scaffold(
        appBar: AppBar(
          elevation: 0.0,
          title: TabBar(
            isScrollable: true,
            controller: _tabController,
            indicatorSize: TabBarIndicatorSize.label,
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
    final _items = bookTagStore.bookTagList;
    return ReorderableListView(
      children: <Widget>[
        for (int index = 0; index < _items.length; index += 1)
          Dismissible(
            key: Key(_items[index]),
            onDismissed: (direction) {
              setState(() {
                _items.removeAt(index);
              });
            },
            confirmDismiss: (direction) async {
              await _deleteConfirm(_items[index]);
              return null;
            },
            background: Container(
              color: Colors.red,
              child: Icon(Icons.delete),
            ),
            child: ListTile(
              key: Key('$index'),
              title: Text('${_items[index]}'),
            ),
          ),
      ],
      onReorder: (int oldIndex, int newIndex) {
        setState(() {
          if (oldIndex < newIndex) {
            newIndex -= 1;
          }
          final item = _items.removeAt(oldIndex);
          _items.insert(newIndex, item);
          bookTagStore.adjustBookTag(_items);
        });
      },
    );
  }

  Future _deleteConfirm(String i) async {
    await showDialog(
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
  }
}
