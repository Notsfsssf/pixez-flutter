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
import 'package:pixez/component/md2_tab_indicator.dart';
import 'package:pixez/i18n.dart';
import 'package:pixez/main.dart';
import 'package:pixez/models/tags.dart';
import 'package:pixez/page/fluent/search/result/painter/search_result_painter_page.dart';
import 'package:pixez/page/fluent/search/result_illust_list.dart';

class ResultPage extends StatefulWidget {
  final String word;
  final String translatedName;

  const ResultPage({Key? key, required this.word, this.translatedName = ''})
      : super(key: key);

  @override
  _ResultPageState createState() => _ResultPageState();
}

class _ResultPageState extends State<ResultPage> {
  @override
  void initState() {
    super.initState();
    tagHistoryStore.insert(
        TagsPersist(name: widget.word, translatedName: widget.translatedName));
  }

  int index = 0;

  @override
  Widget build(BuildContext context) {
    return NavigationView(
      pane: NavigationPane(
        items: [
          PaneItem(
            icon: Icon(FluentIcons.picture),
            body: ResultIllustList(word: widget.word),
            title: Text(I18n.of(context).illust),
          ),
          PaneItem(
            icon: Icon(FluentIcons.format_painter),
            body: SearchResultPainterPage(word: widget.word),
            title: Text(I18n.of(context).painter),
          ),
        ],
      ),
    );
  }
}
