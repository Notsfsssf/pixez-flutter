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
import 'package:md2_tab_indicator/md2_tab_indicator.dart';
import 'package:pixez/i18n.dart';
import 'package:pixez/main.dart';
import 'package:pixez/models/tags.dart';
import 'package:pixez/page/search/result/painter/search_result_painter_page.dart';
import 'package:pixez/page/search/result_illust_list.dart';

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
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          elevation: 0.0,
          backgroundColor: Colors.transparent,
          title: TabBar(
              indicatorSize: TabBarIndicatorSize.label,
              indicator: MD2Indicator(
                  indicatorHeight: 3,
                  indicatorColor: Theme.of(context).accentColor,
                  indicatorSize: MD2IndicatorSize.normal),
              onTap: (i) {
                if (i == index) {
                  topStore.setTop("401");
                }
                index = i;
              },
              tabs: [
                Tab(
                  text: I18n.of(context).illust,
                ),
                Tab(
                  text: I18n.of(context).painter,
                ),
              ]),
        ),
        body: TabBarView(children: [
          ResultIllustList(word: widget.word),
          SearchResultPainterPage(
            word: widget.word,
          ),
        ]),
      ),
    );
  }
}
