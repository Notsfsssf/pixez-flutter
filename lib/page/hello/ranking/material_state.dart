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

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:pixez/component/md2_tab_indicator.dart';
import 'package:pixez/i18n.dart';
import 'package:pixez/main.dart';
import 'package:pixez/page/hello/ranking/rank_page.dart';
import 'package:pixez/page/hello/ranking/ranking_mode/rank_mode_page.dart';

class MaterialRankPageState extends RankPageStateBase {
  @override
  Widget build(BuildContext context) {
    super.build(context);
    final rankListMean = I18n.of(context).mode_list.split(' ');
    return Observer(builder: (_) {
      if (rankStore.inChoice) {
        return _buildChoicePage(context, rankListMean);
      }
      if (rankStore.modeList.isNotEmpty) {
        var list = I18n.of(context).mode_list.split(' ');
        List<String> titles = [];
        for (var i = 0; i < rankStore.modeList.length; i++) {
          int index = modeList.indexOf(rankStore.modeList[i]);
          titles.add(list[index]);
        }
        return DefaultTabController(
          length: rankStore.modeList.length,
          child: Column(
            children: <Widget>[
              ValueListenableBuilder<double?>(
                valueListenable: appBarHeightNotifier,
                builder: (BuildContext context, double? value, Widget? child) =>
                    ValueListenableBuilder<bool>(
                        valueListenable: widget.isFullscreen,
                        builder: (BuildContext context, bool? isFullscreen,
                                Widget? child) =>
                            AnimatedContainer(
                              key: appBarKey,
                              duration: const Duration(milliseconds: 400),
                              height: isFullscreen != null && isFullscreen
                                  ? 0
                                  : appBarHeightNotifier.value,
                              child: AppBar(
                                elevation: 0.0,
                                title: TabBar(
                                  onTap: (i) => setState(() {
                                    this.index = i;
                                  }),
                                  indicator: MD2Indicator(
                                      indicatorHeight: 3,
                                      indicatorColor:
                                          Theme.of(context).colorScheme.primary,
                                      indicatorSize: MD2IndicatorSize.normal),
                                  indicatorSize: TabBarIndicatorSize.label,
                                  isScrollable: true,
                                  tabs: <Widget>[
                                    for (var i in titles)
                                      Tab(
                                        text: i,
                                      ),
                                  ],
                                ),
                                actions: <Widget>[
                                  if (widget.toggleFullscreen != null)
                                    IconButton(
                                      icon: Icon(Icons.fullscreen),
                                      onPressed: () {
                                        toggleFullscreen();
                                      },
                                    ),
                                  Visibility(
                                    visible: index < rankStore.modeList.length,
                                    child: IconButton(
                                      icon: Icon(Icons.date_range),
                                      onPressed: () async {
                                        await _showTimePicker(context);
                                      },
                                    ),
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.undo),
                                    onPressed: () {
                                      rankStore.reset();
                                    },
                                  )
                                ],
                              ),
                            )),
              ),
              Expanded(
                child: TabBarView(children: [
                  for (var element in rankStore.modeList)
                    RankModePage(
                      date: dateTime,
                      mode: element,
                      index: rankStore.modeList.indexOf(element),
                    ),
                ]),
              )
            ],
          ),
        );
      } else {
        return _buildChoicePage(context, rankListMean);
      }
    });
  }

  Widget _buildChoicePage(BuildContext context, List<String> rankListMean) {
    return Container(
      child: Column(
        children: <Widget>[
          AppBar(
            elevation: 0.0,
            title: Text(I18n.of(context).choice_you_like),
            actions: <Widget>[
              IconButton(
                icon: Icon(Icons.save),
                onPressed: () async {
                  await rankStore.saveChange(boolList);
                  rankStore.inChoice = false;
                },
              )
            ],
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.all(8.0),
              child: Wrap(
                spacing: 4,
                children: [
                  for (var e in rankListMean)
                    FilterChip(
                        label: Text(e),
                        selected: rankFilters.contains(e),
                        onSelected: (v) {
                          boolList[rankListMean.indexOf(e)] = v;
                          if (v) {
                            setState(() {
                              rankFilters.add(e);
                            });
                          } else {
                            setState(() {
                              rankFilters.remove(e);
                            });
                          }
                        }),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Future _showTimePicker(BuildContext context) async {
    var nowdate = DateTime.now();
    var date = await showDatePicker(
        context: context,
        initialDate: nowDateTime,
        locale: userSetting.locale,
        firstDate: DateTime(2007, 8),
        //pixiv于2007年9月10日由上谷隆宏等人首次推出第一个测试版...
        lastDate: nowdate);
    if (date != null && mounted) {
      nowDateTime = date;
      setState(() {
        this.dateTime = toRequestDate(date);
      });
    }
  }
}
