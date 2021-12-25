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

import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pixez/i18n.dart';
import 'package:pixez/lighting/lighting_page.dart';
import 'package:pixez/lighting/lighting_store.dart';
import 'package:pixez/main.dart';
import 'package:pixez/network/api_client.dart';
import 'package:pixez/page/search/result_illust_store.dart';
import 'package:pixez/page/search/suggest/search_suggestion_page.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class ResultIllustList extends StatefulWidget {
  final String word;

  const ResultIllustList({Key? key, required this.word}) : super(key: key);

  @override
  _ResultIllustListState createState() => _ResultIllustListState();
}

class _ResultIllustListState extends State<ResultIllustList> {
  late ResultIllustStore resultIllustStore;
  late ApiForceSource futureGet;
  late RefreshController _refreshController;
  late StreamSubscription<String> listen;

  @override
  void initState() {
    _refreshController = RefreshController();
    futureGet = ApiForceSource(
        futureGet: (e) => apiClient.getSearchIllust(widget.word));
    super.initState();
    listen = topStore.topStream.listen((event) {
      if (event == "401") {
        _refreshController.position?.jumpTo(0);
      }
    });
  }

  @override
  void dispose() {
    listen.cancel();
    super.dispose();
  }

  List<int> starNum = [
    0,
    100,
    250,
    500,
    1000,
    5000,
    10000,
    20000,
    30000,
    50000,
  ];

  final sort = ["date_desc", "date_asc", "popular_desc"];
  static List<String> search_target = [
    "partial_match_for_tags",
    "exact_match_for_tags",
    "title_and_caption"
  ];
  String searchTarget = search_target[0];
  String selectSort = "date_desc";
  int selectStarNum = 0;
  // double starValue = 0.0;

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              InkWell(
                onTap: () {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => SearchSuggestionPage(
                            preword: widget.word,
                          )));
                },
                child: Container(
                  width: MediaQuery.of(context).size.width * 2 / 3,
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: EdgeInsets.only(left: 16.0),
                      child: Text(
                        widget.word,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
              ),
              Align(
                alignment: Alignment.centerRight,
                child: Row(
                  children: [
                    IconButton(
                        icon: Icon(Icons.date_range),
                        onPressed: () {
                          _buildShowDateRange(context);
                        }),
                    _buildStar(),
                    IconButton(
                        icon: Icon(Icons.sort),
                        onPressed: () {
                          _buildShowBottomSheet(context);
                          // _showMaterialBottom();
                        }),
                  ],
                ),
              )
            ],
          ),
          Expanded(
              child: LightingList(
            source: futureGet,
            refreshController: _refreshController,
          ))
        ],
      ),
    );
  }

  Future _buildShowDateRange(BuildContext context) async {
    // await showDateRangePicker(
    //     context: context,
    //     locale: I18n.delegate.supportedLocales[
    //         userSetting.toRealLanguageNum(userSetting.languageNum)],
    //     firstDate: DateTime.fromMillisecondsSinceEpoch(
    //         DateTime.now().millisecondsSinceEpoch -
    //             (24 * 60 * 60 * 365 * 1000 * 8)),
    //     lastDate: DateTime.now());
    if (true) {
      DateTimeRange? dateTimeRange = await showDateRangePicker(
          context: context,
          firstDate: DateTime.fromMillisecondsSinceEpoch(
              DateTime.now().millisecondsSinceEpoch -
                  (24 * 60 * 60 * 365 * 1000 * 8)),
          lastDate: DateTime.now());
      if (dateTimeRange != null) {
        setState(() {
          futureGet = ApiForceSource(
              futureGet: (bool e) => apiClient.getSearchIllust(widget.word,
                  search_target: searchTarget,
                  sort: selectSort,
                  start_date: dateTimeRange.start,
                  end_date: dateTimeRange.end));
        });
      }
      return;
    }
  }

  void _buildShowBottomSheet(BuildContext context) {
    showModalBottomSheet(
        context: context,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(8.0))),
        builder: (context) {
          return StatefulBuilder(builder: (_, setS) {
            return SafeArea(
              child: Container(
                  width: MediaQuery.of(context).size.width,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          TextButton(
                              onPressed: () {},
                              child: Text(I18n.of(context).filter,
                                  style: TextStyle(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .secondary))),
                          TextButton(
                              onPressed: () {
                                setState(() {
                                  if (_starValue == 0)
                                    futureGet = ApiForceSource(
                                        futureGet: (bool e) => apiClient
                                            .getSearchIllust(widget.word,
                                                search_target: searchTarget,
                                                sort: selectSort));
                                  else
                                    futureGet = ApiForceSource(
                                        futureGet: (bool e) =>
                                            apiClient.getSearchIllust(
                                                '${widget.word} ${_starValue}users入り',
                                                search_target: searchTarget,
                                                sort: selectSort));
                                });
                                Navigator.of(context).pop();
                              },
                              child: Text(I18n.of(context).apply,
                                  style: TextStyle(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .secondary))),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: SizedBox(
                          width: double.infinity,
                          child: CupertinoSlidingSegmentedControl(
                            groupValue: search_target.indexOf(searchTarget),
                            children: <int, Widget>{
                              0: Text(I18n.of(context).partial_match_for_tag),
                              1: Text(I18n.of(context).exact_match_for_tag),
                              2: Text(I18n.of(context).title_and_caption),
                            },
                            onValueChanged: (int? index) {
                              setS(() {
                                searchTarget = search_target[index!];
                              });
                            },
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: SizedBox(
                          width: double.infinity,
                          child: CupertinoSlidingSegmentedControl(
                            groupValue: sort.indexOf(selectSort),
                            children: <int, Widget>{
                              0: Text(I18n.of(context).date_desc),
                              1: Text(I18n.of(context).date_asc),
                              2: Text(I18n.of(context).popular_desc),
                            },
                            onValueChanged: (int? index) {
                              if (accountStore.now != null && index == 2) {
                                if (accountStore.now!.isPremium == 0) {
                                  BotToast.showText(text: 'not premium');
                                  setState(() {
                                    futureGet = ApiForceSource(
                                        futureGet: (bool e) => apiClient
                                            .getPopularPreview(widget.word));
                                  });
                                  Navigator.of(context).pop();
                                  return;
                                }
                              }
                              setS(() {
                                selectSort = sort[index!];
                              });
                            },
                          ),
                        ),
                      ),
                      // Padding(
                      //   child: Container(
                      //     alignment: Alignment.centerLeft,
                      //     child: Text(starValue != 0
                      //         ? I18n.of(context).more_then_starnum_bookmark(
                      //             "${starNum[starValue.toInt()]}")
                      //         : 'users入り'),
                      //   ),
                      //   padding: const EdgeInsets.symmetric(
                      //       vertical: 0.0, horizontal: 16.0),
                      // ),
                      // Padding(
                      //   padding: const EdgeInsets.symmetric(
                      //       vertical: 0.0, horizontal: 8.0),
                      //   child: SizedBox(
                      //     width: double.infinity,
                      //     child: Slider(
                      //       activeColor:
                      //           Theme.of(context).colorScheme.secondary,
                      //       onChanged: (double value) {
                      //         int v = value.toInt();
                      //         setS(() {
                      //           starValue = v.toDouble();
                      //         });
                      //       },
                      //       value: starValue,
                      //       max: 9.0,
                      //     ),
                      //   ),
                      // ),
                      Container(
                        height: 16,
                      )
                    ],
                  )),
            );
          });
        });
  }

  int _starValue = 0;

  Widget _buildStar() {
    return PopupMenuButton(
      initialValue: _starValue,
      child: Icon(Icons.book),
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16.0))),
      itemBuilder: (context) {
        return starNum.map((int value) {
          if (value > 0) {
            return PopupMenuItem(
              value: value,
              child: Text("${value} users入り"),
              onTap: () {
                setState(() {
                  _starValue = value;
                  if (_starValue == 0)
                    futureGet = ApiForceSource(
                        futureGet: (bool e) => apiClient.getSearchIllust(
                            widget.word,
                            search_target: searchTarget,
                            sort: selectSort));
                  else
                    futureGet = ApiForceSource(
                        futureGet: (bool e) => apiClient.getSearchIllust(
                            '${widget.word} ${_starValue}users入り',
                            search_target: searchTarget,
                            sort: selectSort));
                });
              },
            );
          } else {
            return PopupMenuItem(
              value: value,
              child: Text("Default"),
              onTap: () {
                setState(() {
                  _starValue = value;
                });
              },
            );
          }
        }).toList();
      },
    );
  }
}
