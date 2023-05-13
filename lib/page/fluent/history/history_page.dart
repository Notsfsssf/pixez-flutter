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

import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:pixez/component/fluent/pixiv_image.dart';
import 'package:pixez/er/leader.dart';
import 'package:pixez/i18n.dart';
import 'package:pixez/main.dart';
import 'package:pixez/page/history/history_store.dart';
import 'package:pixez/page/fluent/picture/illust_lighting_page.dart';
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
                      Leader.push(
                          context,
                          IllustLightingPage(
                              id: reIllust[index].illustId,
                              store:
                                  IllustStore(reIllust[index].illustId, null)));
                    },
                    onLongPress: () async {
                      final result = await showDialog(
                          context: context,
                          builder: (context) {
                            return ContentDialog(
                              title: Text("${I18n.of(context).delete}?"),
                              actions: <Widget>[
                                HyperlinkButton(
                                  child: Text(I18n.of(context).cancel),
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                ),
                                HyperlinkButton(
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
    return ScaffoldPage(
      header: PageHeader(
        title: TextBox(
          controller: _textEditingController,
          onChanged: (word) {
            if (word.trim().isNotEmpty) {
              _store.search(word.trim());
            } else {
              _store.fetch();
            }
          },
          placeholder: I18n.of(context).search_word_hint,
        ),
        commandBar: CommandBar(primaryItems: [
          CommandBarButton(
            icon: Icon(FluentIcons.chrome_close),
            onPressed: () {
              _textEditingController.clear();
            },
          ),
          CommandBarButton(
            icon: Icon(FluentIcons.delete),
            onPressed: () {
              _cleanAll(context);
            },
          )
        ]),
      ),
      content: buildBody(),
    );
  }

  Future<void> _cleanAll(BuildContext context) async {
    final result = await showDialog(
        context: context,
        builder: (context) {
          return ContentDialog(
            title: Text("${I18n.of(context).delete} ${I18n.of(context).all}?"),
            actions: <Widget>[
              HyperlinkButton(
                child: Text(I18n.of(context).cancel),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              HyperlinkButton(
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
