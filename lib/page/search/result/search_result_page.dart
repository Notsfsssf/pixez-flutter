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
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_cupertino_date_picker/flutter_cupertino_date_picker.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:pixez/component/illust_card.dart';
import 'package:pixez/generated/l10n.dart';
import 'package:pixez/main.dart';
import 'package:pixez/models/tags.dart';
import 'package:pixez/network/api_client.dart';
import 'package:pixez/page/search/result/bloc/search_result_bloc.dart';
import 'package:pixez/page/search/result/bloc/search_result_state.dart';
import 'package:pixez/page/search/result/painter/search_result_painter_page.dart';

import 'bloc/search_result_event.dart';

class SearchResultPage extends StatefulWidget {
  final String word;
  final String translatedName;

  const SearchResultPage({Key key, this.word, this.translatedName = ""})
      : super(key: key);

  @override
  _SearchResultPageState createState() => _SearchResultPageState();
}

class _SearchResultPageState extends State<SearchResultPage>
    with SingleTickerProviderStateMixin {
  TabController _tabController;
  EasyRefreshController _refreshController;
  Completer<void> _refreshCompleter, _loadCompleter;
  int _selectindex = 0;
  ScrollController _scrollController;

  @override
  void initState() {
    _scrollController = ScrollController();
    super.initState();
    _refreshCompleter = Completer<void>();
    _loadCompleter = Completer<void>();
    _tabController = TabController(vsync: this, length: 2);
    _refreshController = EasyRefreshController();
    _tabController.addListener(() {
      setState(() {
        _selectindex = this._tabController.index;
      });
    });
    tagHistoryStore.insert(TagsPersist()
      ..name = widget.word
      ..translatedName = widget.translatedName);
  }

  @override
  void dispose() {
    _tabController?.dispose();
    _scrollController?.dispose();
    _refreshController?.dispose();
    super.dispose();
  }

  List<int> starNum = [
    50000,
    30000,
    20000,
    10000,
    5000,
    1000,
    500,
    250,
    100,
    0
  ];

  String toUserBookString(String keyWord, int num) {
    if (num == 0)
      return "${keyWord} users入り";
    else
      return "${keyWord} ${num.toString()}users入り";
  }

  String _sortValue = "date_desc";
  String _searchTargetValue = "partial_match_for_tags";
  bool enableDuration = false;
  DateTime startDate = DateTime.now(), endDate = DateTime.now();
  var tapTime = 0;
  var routes = ['result/illust', 'result/painter'];

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SearchResultBloc(apiClient, _refreshController),
      child: MultiBlocListener(
        listeners: [
          BlocListener<SearchResultBloc, SearchResultState>(
            listener: (context, state) {
              if (state is DataState) {
                _loadCompleter?.complete();
                _loadCompleter = Completer();
                _refreshCompleter?.complete();
                _refreshCompleter = Completer();
              }
              if (state is RefreshFailState) {
                _loadCompleter.complete();
                _refreshCompleter.complete();
                _refreshCompleter = Completer<void>();
                _loadCompleter = Completer<void>();
              }
            },
          ),
        ],
        child: BlocBuilder<SearchResultBloc, SearchResultState>(
            condition: (pre, now) {
          return now is DataState;
        }, builder: (context, state) {
          return Scaffold(
            appBar: AppBar(
              title: SelectableText(widget.word),
              actions: <Widget>[
                IconButton(
                  icon: Icon(Icons.more_vert),
                  onPressed: () {
                    showModalBottomSheet<void>(
                        context: context,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(16),
                          ),
                        ),
                        builder: (_) {
                          return StatefulBuilder(
                              builder: (_, setBottomSheetState) {
                            if (startDate.isAfter(endDate)) {
                              startDate = DateTime.now();
                              endDate = DateTime.now();
                            }
                            return Container(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                  Row(
                                    children: <Widget>[
                                      Flexible(
                                        child: RadioListTile<String>(
                                          value: sort[0],
                                          title:
                                              Text(I18n.of(context).date_desc),
                                          groupValue: _sortValue,
                                          onChanged: (value) {
                                            setBottomSheetState(() {
                                              _sortValue = value;
                                            });
                                          },
                                        ),
                                      ),
                                      Flexible(
                                        child: RadioListTile<String>(
                                          value: sort[1],
                                          title:
                                              Text(I18n.of(context).date_asc),
                                          groupValue: _sortValue,
                                          onChanged: (value) {
                                            setBottomSheetState(() {
                                              _sortValue = value;
                                            });
                                          },
                                        ),
                                      ),
                                      Flexible(
                                        child: RadioListTile<String>(
                                          value: sort[2],
                                          title: Text(
                                              I18n.of(context).popular_desc),
                                          groupValue: _sortValue,
                                          onChanged: (value) async {
                                            if (accountStore.now != null) {
                                              if (accountStore.now.isPremium ==
                                                  1)
                                                setBottomSheetState(() {
                                                  _sortValue = value;
                                                });
                                              else {
                                                BotToast.showText(
                                                    text: "Not Premium!");
                                                BlocProvider.of<
                                                            SearchResultBloc>(
                                                        context)
                                                    .add(PreviewEvent(
                                                        widget.word));
                                              }
                                            }
                                          },
                                        ),
                                      )
                                    ],
                                  ),
                                  Row(
                                    children: <Widget>[
                                      Flexible(
                                        child: RadioListTile<String>(
                                          value: search_target[0],
                                          title: Text(I18n.of(context)
                                              .Partial_Match_for_tag),
                                          groupValue: _searchTargetValue,
                                          onChanged: (value) {
                                            setBottomSheetState(() {
                                              _searchTargetValue = value;
                                            });
                                          },
                                        ),
                                      ),
                                      Flexible(
                                        child: RadioListTile<String>(
                                          value: search_target[0],
                                          title: Text(I18n.of(context)
                                              .Exact_Match_for_tag),
                                          groupValue: _searchTargetValue,
                                          onChanged: (value) {
                                            setBottomSheetState(() {
                                              _searchTargetValue = value;
                                            });
                                          },
                                        ),
                                      ),
                                      Flexible(
                                        child: RadioListTile<String>(
                                          value: search_target[0],
                                          title: Text(I18n.of(context)
                                              .title_and_caption),
                                          groupValue: _searchTargetValue,
                                          onChanged: (value) {
                                            setBottomSheetState(() {
                                              _searchTargetValue = value;
                                            });
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                  SwitchListTile(
                                      title:
                                          Text(I18n.of(context).Date_duration),
                                      value: enableDuration,
                                      onChanged: (v) {
                                        setBottomSheetState(() {
                                          enableDuration = v;
                                        });
                                      }),
                                  Visibility(
                                    child: Row(
                                      children: <Widget>[
                                        OutlineButton(
                                          onPressed: () {
                                            DatePicker.showDatePicker(context,
                                                maxDateTime: endDate,
                                                initialDateTime: startDate,
                                                onConfirm: (DateTime dateTime,
                                                    List<int> list) {
                                              setBottomSheetState(() {
                                                startDate = dateTime;
                                              });
                                              setState(() {
                                                startDate = dateTime;
                                              });
                                            });
                                          },
                                          child: Text(startDate
                                              .toIso8601String()
                                              .split("T")[0]), //AXAXAX
                                        ),
                                        Text("~"),
                                        OutlineButton(
                                          onPressed: () {
                                            DatePicker.showDatePicker(context,
                                                maxDateTime: DateTime.now(),
                                                initialDateTime: endDate,
                                                onConfirm: (DateTime dateTime,
                                                    List<int> list) {
                                              setBottomSheetState(() {
                                                endDate = dateTime;
                                              });
                                              setState(() {
                                                endDate = dateTime;
                                              });
                                            });
                                          },
                                          child: Text(endDate
                                              .toIso8601String()
                                              .split("T")[0]),
                                        ),
                                      ],
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceAround,
                                    ),
                                    visible: enableDuration,
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        left: 8.0, right: 8.0),
                                    child: RaisedButton(
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                        BlocProvider.of<SearchResultBloc>(
                                                context)
                                            .add(ApplyEvent(
                                                widget.word,
                                                _sortValue,
                                                _searchTargetValue,
                                                startDate,
                                                endDate,
                                                enableDuration));
                                      },
                                      child: Text(I18n.of(context).Apply),
                                      color: Theme.of(context).primaryColor,
                                      textColor: Colors.white,
                                    ),
                                  ),
                                  Container(
                                    height:
                                        MediaQuery.of(context).padding.bottom,
                                  )
                                ],
                              ),
                            );
                          });
                        });
                  },
                )
              ],
              bottom: TabBar(
                controller: _tabController,
                onTap: (position) {
                  var spaceTime =
                      DateTime.now().millisecondsSinceEpoch - tapTime;
                  print("${spaceTime}/${tapTime}");
                  if (spaceTime > 2000) {
                    tapTime = DateTime.now().millisecondsSinceEpoch;
                  } else {}
                },
                tabs: <Widget>[
                  Tab(
                    child: Text(I18n.of(context).Illust),
                  ),
                  Tab(
                    child: Text(I18n.of(context).Painter),
                  ),
                ],
              ),
            ),
            body: TabBarView(
              controller: _tabController,
              children: <Widget>[
                EasyRefresh(
                  controller: _refreshController,
                  enableControlFinishLoad: true,
                  enableControlFinishRefresh: true,
                  child: state is DataState
                      ? StaggeredGridView.countBuilder(
                          crossAxisCount: 2,
                          controller: _scrollController,
                          itemCount: state.illusts.length,
                          itemBuilder: (context, index) {
                            return IllustCard(
                              state.illusts[index],
                              illustList: state.illusts,
                            );
                          },
                          staggeredTileBuilder: (int index) =>
                              StaggeredTile.fit(1),
                        )
                      : Container(),
                  onRefresh: () async {
                    BlocProvider.of<SearchResultBloc>(context).add(FetchEvent(
                        widget.word,
                        _sortValue,
                        _searchTargetValue,
                        startDate,
                        endDate,
                        enableDuration));
                    return _refreshCompleter.future;
                  },
                  firstRefresh: true,
                  onLoad: () async {
                    if (state is DataState) {
                      BlocProvider.of<SearchResultBloc>(context)
                          .add(LoadMoreEvent(state.nextUrl, state.illusts));
                      return _loadCompleter.future;
                    }
                    return;
                  },
                ),
                SearchResultPainterPage(
                  word: widget.word,
                ),
              ],
            ),
            floatingActionButton: FloatingActionButton(
              onPressed: () {
                showDialog(
                    context: context,
                    builder: (_) {
                      return AlertDialog(
                        content: SingleChildScrollView(
                          child: ListBody(
                            children: starnum
                                .map((f) => ListTile(
                                      title: Text("$f users入り"),
                                      subtitle: Text(I18n.of(context)
                                          .More_then_starNum_Bookmark(
                                              f.toString())),
                                      onTap: () {
                                        Navigator.of(context).pop();
                                        BlocProvider.of<SearchResultBloc>(
                                                context)
                                            .add(FetchEvent(
                                                toUserBookString(
                                                    widget.word, f),
                                                _sortValue,
                                                _searchTargetValue,
                                                startDate,
                                                endDate,
                                                enableDuration));
                                      },
                                    ))
                                .toList(),
                          ),
                        ),
                      );
                    });
              },
              child: Icon(Icons.sort),
            ),
          );
        }),
      ),
    );
  }

  final starnum = [50000, 30000, 20000, 10000, 5000, 1000, 500, 250, 100, 0];
  final sort = ["date_desc", "date_asc", "popular_desc"];
  var search_target = [
    "partial_match_for_tags",
    "exact_match_for_tags",
    "title_and_caption"
  ];
}
