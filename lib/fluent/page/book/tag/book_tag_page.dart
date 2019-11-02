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

import 'dart:collection';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:pixez/i18n.dart';
import 'package:pixez/main.dart';
import 'package:pixez/fluent/page/search/result_illust_list.dart';

class BookTagPage extends StatefulWidget {
  @override
  _BookTagPageState createState() => _BookTagPageState();
}

class _BookTagPageState extends State<BookTagPage>
    with TickerProviderStateMixin {
  int _index = 0;
  late Map<String, bool> _tags;

  @override
  Widget build(BuildContext context) {
    return Observer(builder: (_) {
      return NavigationView(
        pane: NavigationPane(
          selected: _index,
          onChanged: (value) => setState(() {
            _index = value;
          }),
          items: [
            for (var i in bookTagStore.bookTagList)
              PaneItem(
                icon: Icon(FluentIcons.tag),
                body: ResultIllustList(word: i),
                title: Text(i),
              )
          ],
          footerItems: [
            PaneItemAction(
              icon: Icon(FluentIcons.edit),
              onTap: () => _showEditDialog(context),
            ),
          ],
          displayMode: PaneDisplayMode.top,
        ),
      );
    });
  }

  void _showEditDialog(BuildContext context) {
    _tags = HashMap.fromEntries(
      bookTagStore.bookTagList.map((i) => MapEntry(i, true)),
    );

    showDialog(
      context: context,
      useRootNavigator: false,
      builder: (context) => ContentDialog(
        title: Text(I18n.of(context).choice_you_like),
        content: _buildTagChip(),
        actions: [
          Button(
            child: Text(I18n.of(context).cancel),
            onPressed: Navigator.of(context).pop,
          ),
          FilledButton(
            child: Text(I18n.of(context).ok),
            onPressed: () {
              _tags.entries
                  .where((i) => !i.value)
                  .map((i) => i.key)
                  .forEach(bookTagStore.unBookTag);
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTagChip() {
    return StatefulBuilder(
      builder: (context, setState) => SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (var i in _tags.entries)
              Padding(
                padding: const EdgeInsets.all(2.0),
                child: Checkbox(
                  content: Text(i.key),
                  checked: i.value,
                  onChanged: (v) => setState(() {
                    _tags[i.key] = v ?? false;
                  }),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
