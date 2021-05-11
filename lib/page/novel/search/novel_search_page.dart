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
import 'package:pixez/er/leader.dart';
import 'package:pixez/i18n.dart';
import 'package:pixez/main.dart';
import 'package:pixez/models/tags.dart';
import 'package:pixez/page/novel/search/novel_result_page.dart';

class NovelSearchPage extends StatefulWidget {
  @override
  _NovelSearchPageState createState() => _NovelSearchPageState();
}

class _NovelSearchPageState extends State<NovelSearchPage> {
  late TextEditingController _textEditingController;

  @override
  void initState() {
    tagHistoryStore.fetch();
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
    return Observer(builder: (context) {
      return Container(
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              title: TextField(
                controller: _textEditingController,
              ),
              actions: [
                IconButton(
                  icon: Icon(Icons.search),
                  onPressed: () {
                    if (_textEditingController.text.isNotEmpty) {
                      Leader.push(
                          context,
                          NovelResultPage(
                            word: _textEditingController.text,
                          ));
                    }
                  },
                )
              ],
            ),
            SliverToBoxAdapter(
                child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Wrap(
                children: [
                  for (var f in tagHistoryStore.tags
                      .where((element) => element.type == 1))
                    buildActionChip(f, context),
                ],
                runSpacing: 0.0,
                spacing: 3.0,
              ),
            )),
            SliverToBoxAdapter(
              child: Observer(builder: (context) {
                if (tagHistoryStore.tags
                    .where((element) => element.type == 1)
                    .isNotEmpty)
                  return InkWell(
                    onTap: () {
                      tagHistoryStore.deleteAll();
                    },
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.delete_outline,
                              size: 18.0,
                              color: Theme.of(context).textTheme.caption!.color,
                            ),
                            Text(
                              I18n.of(context).clear_search_tag_history,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyText2!
                                  .copyWith(
                                      color: Theme.of(context)
                                          .textTheme
                                          .caption!
                                          .color),
                            )
                          ],
                        ),
                      ),
                    ),
                  );
                return Container();
              }),
            ),
            // SliverGrid(
            //   gridDelegate:
            //       SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
            //   delegate: SliverChildBuilderDelegate((context,index){},childCount: ),
            // )
          ],
        ),
      );
    });
  }

  Widget buildActionChip(TagsPersist f, BuildContext context) {
    return InkWell(
      onLongPress: () {
        showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: Text('${I18n.of(context).delete}?'),
                actions: [
                  TextButton(
                      onPressed: () {
                        tagHistoryStore.delete(f.id!);
                        Navigator.of(context).pop();
                      },
                      child: Text(I18n.of(context).ok)),
                  TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: Text(I18n.of(context).cancel)),
                ],
              );
            });
      },
      onTap: () {
        Navigator.of(context, rootNavigator: true).push(MaterialPageRoute(
            builder: (context) => NovelResultPage(
                  word: f.name,
                  translatedName: f.translatedName,
                )));
      },
      child: Chip(
        padding: EdgeInsets.all(0.0),
        label: Text(
          f.name,
          style: TextStyle(fontSize: 12.0),
        ),
      ),
    );
  }
}
