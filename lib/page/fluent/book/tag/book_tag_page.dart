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

import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:pixez/i18n.dart';
import 'package:pixez/main.dart';
import 'package:pixez/page/fluent/search/result_illust_list.dart';

class BookTagPage extends StatefulWidget {
  @override
  _BookTagPageState createState() => _BookTagPageState();
}

class _BookTagPageState extends State<BookTagPage>
    with TickerProviderStateMixin {
  bool edit = false;

  @override
  Widget build(BuildContext context) {
    if (edit)
      return Observer(builder: (context) {
        return ScaffoldPage(
          header: PageHeader(
            title: Text(I18n.of(context).choice_you_like),
            commandBar: CommandBar(primaryItems: [
              CommandBarButton(
                  icon: Icon(FluentIcons.save),
                  onPressed: () {
                    setState(() {
                      edit = false;
                    });
                  })
            ]),
          ),
          content: Expanded(child: _buildTagChip()),
        );
      });

    return Observer(builder: (_) {
      return NavigationView(
        pane: NavigationPane(
          items: [
            for (var i in bookTagStore.bookTagList)
              PaneItem(
                icon: Icon(FluentIcons.tag),
                body: ResultIllustList(word: i),
                title: Text(i),
              )
          ],
          header: IconButton(
              icon: Icon(FluentIcons.undo),
              onPressed: () {
                setState(() {
                  edit = true;
                });
              }),
          displayMode: PaneDisplayMode.top,
        ),
        appBar: NavigationAppBar(
            leading: IconButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: Icon(FluentIcons.closed_caption),
        )),
        // Drawer(
        //   child: ListView(
        //     children: [
        //       for (var j in bookTagStore.bookTagList)
        //         ListTile(
        //           title: Text(j),
        //           onTap: () {
        //             _tabController
        //                 .animateTo(bookTagStore.bookTagList.indexOf(j));
        //           },
        //         )
        //     ],
        //   ),
        // ),
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
                ToggleSwitch(
                    content: Text(i),
                    checked: true,
                    onChanged: (v) {
                      showDialog(
                          context: context,
                          builder: (context) {
                            return ContentDialog(
                              title: Text(I18n.of(context).delete + "$i?"),
                              actions: [
                                HyperlinkButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                    child: Text(I18n.of(context).cancel)),
                                HyperlinkButton(
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
