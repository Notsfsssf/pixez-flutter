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
import 'package:flutter/material.dart';
import 'package:pixez/er/prefer.dart';
import 'package:pixez/i18n.dart';
import 'package:pixez/lighting/lighting_page.dart';
import 'package:pixez/lighting/lighting_store.dart';
import 'package:pixez/main.dart';
import 'package:pixez/network/api_client.dart';
import 'package:pixez/page/search/result_illust_store.dart';
import 'package:pixez/page/search/suggest/search_suggestion_page.dart';

class ResultIllustList extends StatefulWidget {
  final String word;

  const ResultIllustList({Key? key, required this.word}) : super(key: key);

  @override
  _ResultIllustListState createState() => _ResultIllustListState();
}

class _ResultIllustListState extends State<ResultIllustList> {
  late ResultIllustStore resultIllustStore;
  late ApiForceSource futureGet;
  late ScrollController _scrollController;
  late StreamSubscription<String> listen;
  final sort = [
    "date_desc",
    "date_asc",
    "popular_desc",
    "popular_male_desc",
    "popular_female_desc"
  ];
  static List<String> search_target = [
    "partial_match_for_tags",
    "exact_match_for_tags",
    "title_and_caption"
  ];
  String searchTarget = search_target[0];
  String selectSort = "date_desc";
  int searchAIType = 0;
  int selectStarNum = 0;
  List<int> starNum = [
    0,
    100,
    250,
    500,
    1000,
    5000,
    7500,
    10000,
    20000,
    30000,
    50000,
  ];
  List<List<int>> premiumStarNum = [
    [],
    [10000],
    [50000, 99999],
    [10000, 49999],
    [5000, 9999],
    [1000, 4999],
    [500, 999],
    [300, 499],
    [100, 299],
    [50, 99],
    [30, 49],
    [10, 29],
  ];
  List<int> _bookmarkNumList = [];
  bool recordRememberCurrentSelection = false;
  bool inited = false;

  @override
  void initState() {
    _scrollController = ScrollController();
    checkInit();
    super.initState();
    listen = topStore.topStream.listen((event) {
      if (event == "401") {
        _scrollController.position.jumpTo(0);
      }
    });
  }

  checkInit() async {
    final prefix = 'illust_search_result_';
    final searchAIKey = '${prefix}_search_ai_type';
    final searchTargetKey = '${prefix}_search_target';
    final searchSortKey = '${prefix}_search_sort';
    final recordRememberCurrentSelectionKey =
        'illust_search_result_record_remember_current_selection';
    recordRememberCurrentSelection =
        Prefer.getBool(recordRememberCurrentSelectionKey) ?? false;
    if (recordRememberCurrentSelection) {
      if (mounted) {
        setState(() {
          searchTarget = Prefer.getString(searchTargetKey) ?? search_target[0];
          selectSort = Prefer.getString(searchSortKey) ?? "date_desc";
          searchAIType = Prefer.getInt(searchAIKey) ?? 0;
        });
      }
    }
    setState(() {
      _changeQueryParams();
      inited = true;
    });
  }

  record() async {
    final prefix = 'illust_search_result_';
    final searchAIKey = '${prefix}_search_ai_type';
    final searchTargetKey = '${prefix}_search_target';
    final searchSortKey = '${prefix}_search_sort';
    await Prefer.setString(searchTargetKey, searchTarget);
    await Prefer.setString(searchSortKey, selectSort);
    await Prefer.setInt(searchAIKey, searchAIType);
  }

  @override
  void dispose() {
    listen.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: InkWell(
                  onTap: () {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => SearchSuggestionPage(
                              preword: widget.word,
                            )));
                  },
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
                child: Padding(
                  padding:
                      const EdgeInsets.only(top: 8.0, bottom: 8.0, right: 8.0),
                  child: Row(
                    children: [
                      InkWell(
                          child: Padding(
                            padding: const EdgeInsets.all(4.0),
                            child: Icon(Icons.date_range),
                          ),
                          onTap: () {
                            _buildShowDateRange(context);
                          }),
                      if (accountStore.now?.isPremium == 1)
                        Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: _buildPremiumStar(),
                        ),
                      Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: _buildStar(),
                      ),
                      InkWell(
                          child: Padding(
                            padding: const EdgeInsets.all(4.0),
                            child: Icon(Icons.filter_alt_outlined),
                          ),
                          onTap: () {
                            _buildShowBottomSheet(context);
                          }),
                    ],
                  ),
                ),
              )
            ],
          ),
          Expanded(
              child: !inited
                  ? Container()
                  : LightingList(
                      source: futureGet,
                      scrollController: _scrollController,
                    ))
        ],
      ),
    );
  }

  DateTimeRange? _dateTimeRange;

  Future _buildShowDateRange(BuildContext context) async {
    DateTimeRange? dateTimeRange = await showDateRangePicker(
        context: context,
        initialDateRange: _dateTimeRange,
        firstDate: DateTime(2007, 8),
        lastDate: DateTime.now());
    if (dateTimeRange != null) {
      _dateTimeRange = dateTimeRange;
      setState(() {
        _changeQueryParams();
      });
    }
  }

  _changeQueryParams() {
    if (_starValue == 0)
      futureGet = ApiForceSource(
          futureGet: (bool e) => apiClient.getSearchIllust(widget.word,
              search_target: searchTarget,
              sort: selectSort,
              start_date: _dateTimeRange?.start,
              end_date: _dateTimeRange?.end,
              bookmark_num: _bookmarkNumList,
              search_ai_type: searchAIType));
    else
      futureGet = ApiForceSource(
          futureGet: (bool e) => apiClient.getSearchIllust(
              '${widget.word} ${_starValue}users入り',
              search_target: searchTarget,
              sort: selectSort,
              start_date: _dateTimeRange?.start,
              end_date: _dateTimeRange?.end,
              bookmark_num: _bookmarkNumList,
              search_ai_type: searchAIType));
  }

  void _buildShowBottomSheet(BuildContext context) {
    showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(8.0))),
        builder: (context) {
          return ResultIllustSortWidget(
              searchAIType: searchAIType,
              selectSort: selectSort,
              searchTarget: searchTarget,
              onPremium: () {
                setState(() {
                  futureGet = ApiForceSource(
                      futureGet: (bool e) =>
                          apiClient.getPopularPreview(widget.word));
                });
              },
              onApply: () {
                setState(() {
                  _changeQueryParams();
                });
              },
              onSateChange: (
                  {required bool recordRememberCurrentSelection,
                  required int searchAIType,
                  required String searchTarget,
                  required String selectSort}) {
                setState(() {
                  this.searchAIType = searchAIType;
                  this.searchTarget = searchTarget;
                  this.selectSort = selectSort;
                  this.recordRememberCurrentSelection =
                      recordRememberCurrentSelection;
                });
                if (recordRememberCurrentSelection) {
                  record();
                }
              });
        });
  }

  int _starValue = 0;

  Widget _buildPremiumStar() {
    return PopupMenuButton<List<int>>(
      initialValue: _bookmarkNumList,
      child: Icon(
        Icons.format_list_numbered,
      ),
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16.0))),
      itemBuilder: (context) {
        return premiumStarNum.map((List<int> value) {
          if (value.isEmpty) {
            return PopupMenuItem(
              value: value,
              child: Text("Default"),
              onTap: () {
                setState(() {
                  _bookmarkNumList = value;
                  _changeQueryParams();
                });
              },
            );
          } else {
            final minStr = value.elementAtOrNull(1) == null
                ? ">${value.elementAtOrNull(0) ?? ''}"
                : "${value.elementAtOrNull(0) ?? ''}";
            final maxStr = value.elementAtOrNull(1) == null
                ? ""
                : "〜${value.elementAtOrNull(1)}";

            return PopupMenuItem(
              value: value,
              child: Text("${minStr}${maxStr}"),
              onTap: () {
                setState(() {
                  _bookmarkNumList = value;
                  _changeQueryParams();
                });
              },
            );
          }
        }).toList();
      },
    );
  }

  Widget _buildStar() {
    return PopupMenuButton(
      initialValue: _starValue,
      child: Icon(
        Icons.sort,
      ),
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
                  _changeQueryParams();
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
                  _changeQueryParams();
                });
              },
            );
          }
        }).toList();
      },
    );
  }
}

class ResultIllustSortWidget extends StatefulWidget {
  final int searchAIType;
  final String selectSort;
  final String searchTarget;
  final Function onPremium;
  final Function onApply;
  final Function(
      {required String searchTarget,
      required String selectSort,
      required int searchAIType,
      required bool recordRememberCurrentSelection}) onSateChange;
  const ResultIllustSortWidget(
      {super.key,
      required this.searchAIType,
      required this.selectSort,
      required this.searchTarget,
      required this.onPremium,
      required this.onApply,
      required this.onSateChange});

  @override
  State<ResultIllustSortWidget> createState() => _ResultIllustSortWidgetState();
}

class _ResultIllustSortWidgetState extends State<ResultIllustSortWidget> {
  late int searchAIType = widget.searchAIType;
  late String selectSort = widget.selectSort;
  late String searchTarget = widget.searchTarget;
  final sort = [
    "date_desc",
    "date_asc",
    "popular_desc",
    "popular_male_desc",
    "popular_female_desc"
  ];
  static List<String> search_target = [
    "partial_match_for_tags",
    "exact_match_for_tags",
    "title_and_caption"
  ];
  bool recordRememberCurrentSelection = false;
  final rememberKey = 'illust_search_result_record_remember_current_selection';
  @override
  void initState() {
    super.initState();
    initMethod();
  }

  initMethod() async {
    if (mounted) {
      setState(() {
        recordRememberCurrentSelection = Prefer.getBool(rememberKey) ?? false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final searchTargetMap = {
      0: I18n.of(context).partial_match_for_tag,
      1: I18n.of(context).exact_match_for_tag,
      2: I18n.of(context).title_and_caption,
    };
    final selectSortMap = {
      0: I18n.of(context).date_desc,
      1: I18n.of(context).date_asc,
      2: I18n.of(context).popular_desc,
      if (accountStore.now != null && accountStore.now!.isPremium == 1) ...{
        3: I18n.of(context).popular_male_desc,
        4: I18n.of(context).popular_female_desc,
      }
    };
    return SafeArea(
      child: Container(
          width: MediaQuery.of(context).size.width,
          child: SingleChildScrollView(
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
                                color:
                                    Theme.of(context).colorScheme.secondary))),
                    TextButton(
                        onPressed: () {
                          widget.onApply();
                          Navigator.of(context).pop();
                        },
                        child: Text(I18n.of(context).apply,
                            style: TextStyle(
                                color:
                                    Theme.of(context).colorScheme.secondary))),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      for (final (index, data)
                          in searchTargetMap.entries.indexed)
                        _buildTargetItem(index, data, context),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      for (final (index, data) in selectSortMap.entries.indexed)
                        _buildSortItem(index, context, data),
                    ],
                  ),
                ),
                SwitchListTile(
                  value: searchAIType != 1,
                  onChanged: (v) {
                    setState(() {
                      searchAIType = !v ? 1 : 0;
                    });
                    widget.onSateChange(
                        searchTarget: searchTarget,
                        selectSort: selectSort,
                        searchAIType: searchAIType,
                        recordRememberCurrentSelection:
                            recordRememberCurrentSelection);
                  },
                  title: Text(I18n.of(context).ai_generated),
                ),
                SwitchListTile(
                  value: recordRememberCurrentSelection,
                  onChanged: (v) async {
                    await Prefer.setBool(rememberKey, v);
                    setState(() {
                      recordRememberCurrentSelection = v;
                    });
                    widget.onSateChange(
                        searchTarget: searchTarget,
                        selectSort: selectSort,
                        searchAIType: searchAIType,
                        recordRememberCurrentSelection:
                            recordRememberCurrentSelection);
                  },
                  title: Text(I18n.of(context).remember_current_selections),
                ),
                Container(
                  height: 16,
                )
              ],
            ),
          )),
    );
  }

  Widget _buildSortItem(
      int index, BuildContext context, MapEntry<int, String> data) {
    return GestureDetector(
      onTap: () {
        if (accountStore.now != null && index == 2) {
          if (accountStore.now!.isPremium == 0) {
            BotToast.showText(text: 'not premium');
            widget.onPremium();
            Navigator.of(context).pop();
            return;
          }
        }
        setState(() {
          selectSort = sort[index];
        });
        widget.onSateChange(
            searchTarget: searchTarget,
            selectSort: selectSort,
            searchAIType: searchAIType,
            recordRememberCurrentSelection: recordRememberCurrentSelection);
      },
      behavior: HitTestBehavior.opaque,
      child: Container(
        margin: EdgeInsets.only(bottom: 8.0),
        child: Text(data.value),
        decoration: selectSort == sort[index]
            ? BoxDecoration(
                color: Theme.of(context).colorScheme.secondaryContainer,
                borderRadius: BorderRadius.circular(8.0),
              )
            : null,
        padding:
            const EdgeInsets.only(top: 10.0, bottom: 10.0, left: 8, right: 8),
        alignment: Alignment.centerLeft,
      ),
    );
  }

  Widget _buildTargetItem(
      int index, MapEntry<int, String> data, BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() {
          searchTarget = search_target[index];
        });
        widget.onSateChange(
            searchTarget: searchTarget,
            selectSort: selectSort,
            searchAIType: searchAIType,
            recordRememberCurrentSelection: recordRememberCurrentSelection);
      },
      behavior: HitTestBehavior.opaque,
      child: Container(
        margin: EdgeInsets.only(bottom: 8.0),
        child: Text(data.value),
        decoration: search_target.indexOf(searchTarget) == index
            ? BoxDecoration(
                color: Theme.of(context).colorScheme.secondaryContainer,
                borderRadius: BorderRadius.circular(8.0),
              )
            : null,
        padding:
            const EdgeInsets.only(top: 10.0, bottom: 10.0, left: 8, right: 8),
        alignment: Alignment.centerLeft,
      ),
    );
  }
}
