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
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:pixez/component/pixiv_image.dart';
import 'package:pixez/i18n.dart';
import 'package:pixez/main.dart';
import 'package:pixez/page/history/history_store.dart';
import 'package:pixez/page/picture/illust_lighting_page.dart';
import 'package:pixez/page/picture/illust_store.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({Key? key}) : super(key: key);

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  final HistoryStore _store = historyStore..fetch();
  late TextEditingController _textEditingController;

  Widget buildAppBarUI(context) => Container(
        child: Padding(
          child: Text(
            I18n.of(context).history,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30.0),
          ),
          padding: EdgeInsets.only(left: 20.0, top: 30.0, bottom: 30.0),
        ),
      );

  Widget buildBody() => Observer(builder: (context) {
        var reIllust = _store.data.reversed.toList();
        if (reIllust.isNotEmpty) {
          return GridView.builder(
              itemCount: reIllust.length,
              gridDelegate:
                  SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
              itemBuilder: (context, index) {
                return GestureDetector(
                    onTap: () {
                      Navigator.of(context, rootNavigator: true).push(
                          MaterialPageRoute(builder: (BuildContext context) {
                        return IllustLightingPage(
                            id: reIllust[index].illustId,
                            store: IllustStore(reIllust[index].illustId, null));
                      }));
                    },
                    onLongPress: () async {
                      final result = await showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              title: Text("${I18n.of(context).delete}?"),
                              actions: <Widget>[
                                TextButton(
                                  child: Text(I18n.of(context).cancel),
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                ),
                                TextButton(
                                  child: Text(I18n.of(context).ok),
                                  onPressed: () {
                                    Navigator.of(context).pop("OK");
                                  },
                                ),
                              ],
                            );
                          });
                      if (result == "OK") {
                        _store.delete(reIllust[index].illustId);
                      }
                    },
                    child: Card(
                        margin: EdgeInsets.all(8),
                        child: PixivImage(reIllust[index].pictureUrl)));
              });
        }
        return Center(
          child: Container(),
        );
      });

  @override
  void initState() {
    _textEditingController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _textEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
            controller: _textEditingController,
            onChanged: (word) {
              if (word.trim().isNotEmpty) {
                _store.search(word.trim());
              } else {
                _store.fetch();
              }
            },
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: I18n.of(context).search_word_hint,
            )),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.close),
            onPressed: () {
              _textEditingController.clear();
            },
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.delete),
        onPressed: () {
          _cleanAll(context);
        },
      ),
      body: buildBody(),
    );
  }

  Future<void> _cleanAll(BuildContext context) async {
    final result = await showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text("${I18n.of(context).delete} ${I18n.of(context).all}?"),
            actions: <Widget>[
              TextButton(
                child: Text(I18n.of(context).cancel),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              TextButton(
                child: Text(I18n.of(context).ok),
                onPressed: () {
                  Navigator.of(context).pop("OK");
                },
              ),
            ],
          );
        });
    if (result == "OK") {
      _store.deleteAll();
    }
  }
}
