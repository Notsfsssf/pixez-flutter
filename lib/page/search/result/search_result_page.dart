import 'dart:async';

import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_cupertino_date_picker/flutter_cupertino_date_picker.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:pixez/bloc/account_bloc.dart';
import 'package:pixez/bloc/account_state.dart';
import 'package:pixez/component/illust_card.dart';
import 'package:pixez/generated/i18n.dart';
import 'package:pixez/models/account.dart';
import 'package:pixez/models/tags.dart';
import 'package:pixez/network/api_client.dart';
import 'package:pixez/page/search/bloc/tag_history_bloc.dart';
import 'package:pixez/page/search/bloc/tag_history_event.dart';
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

  @override
  void initState() {
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
    BlocProvider.of<TagHistoryBloc>(context)
        .add(InsertTagHistoryEvent(TagsPersist()
          ..name = widget.word
          ..translatedName = widget.translatedName));
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

  EasyRefresh _buildEasyRefresh(DataState state, BuildContext context) {
    return EasyRefresh(
      controller: _refreshController,
      child: StaggeredGridView.countBuilder(
        crossAxisCount: 2,
        itemCount: state.illusts.length,
        itemBuilder: (context, index) {
          return IllustCard(state.illusts[index]);
        },
        staggeredTileBuilder: (int index) => StaggeredTile.fit(1),
      ),
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
      onLoad: () async {
        BlocProvider.of<SearchResultBloc>(context)
            .add(LoadMoreEvent(state.nextUrl, state.illusts));
        return _loadCompleter.future;
      },
    );
  }

  Widget _buildFirst(state) =>
      BlocListener<SearchResultBloc, SearchResultState>(
          listener: (context, state) {
            if (state is DataState) {
              _loadCompleter?.complete();
              _loadCompleter = Completer();
              _refreshCompleter?.complete();
              _refreshCompleter = Completer();
            }
          },
          child: _buildEasyRefresh(state, context));

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          SearchResultBloc(RepositoryProvider.of<ApiClient>(context))
            ..add(FetchEvent(widget.word, _sortValue, _searchTargetValue,
                startDate, endDate, enableDuration)),
      child: BlocBuilder<SearchResultBloc, SearchResultState>(
        condition: (pre, now) {
          return now is DataState;
        },
        builder: (context, state) {
          if (state is DataState)
            return Scaffold(
              body: NestedScrollView(
                body: TabBarView(
                  controller: _tabController,
                  children: <Widget>[
                    _buildFirst(state),
                    SearchResultPainerPage(
                      word: widget.word,
                    )
                  ],
                ),
                headerSliverBuilder:
                    (BuildContext context, bool innerBoxIsScrolled) {
                  return [
                    SliverAppBar(
                      pinned: true,
                      floating: true,
                      title: SelectableText(widget.word),
                      actions: <Widget>[
                        IconButton(
                          icon: Icon(Icons.more_vert),
                          onPressed: () {
                            showModalBottomSheet<void>(
                                context: context,
                                builder: (_) {
                                  return StatefulBuilder(
                                      builder: (_, setBottomSheetState) {
                                    if (startDate.isAfter(endDate)) {
                                      startDate = DateTime.now();
                                      endDate = DateTime.now();
                                    }
                                    return Container(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.stretch,
                                        mainAxisSize: MainAxisSize.min,
                                        children: <Widget>[
                                          Row(
                                            children: <Widget>[
                                              Flexible(
                                                child: RadioListTile<String>(
                                                  value: sort[0],
                                                  title: Text(I18n.of(context)
                                                      .date_desc),
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
                                                  title: Text(I18n.of(context)
                                                      .date_asc),
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
                                                  title: Text(I18n.of(context)
                                                      .popular_desc),
                                                  groupValue: _sortValue,
                                                  onChanged: (value) async {
                                                 var userState=   BlocProvider.of<
                                                                AccountBloc>(
                                                            context)
                                                        .state;
                                                    if (userState is HasUserState) {
                                                      if(userState.list.isPremium==1)
                                                      setBottomSheetState(() {
                                                        _sortValue = value;
                                                      });
                                                      else BotToast.showText(text: "Not Premium!");
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
                                                  groupValue:
                                                      _searchTargetValue,
                                                  onChanged: (value) {
                                                    setBottomSheetState(() {
                                                      _searchTargetValue =
                                                          value;
                                                    });
                                                  },
                                                ),
                                              ),
                                              Flexible(
                                                child: RadioListTile<String>(
                                                  value: search_target[0],
                                                  title: Text(I18n.of(context)
                                                      .Exact_Match_for_tag),
                                                  groupValue:
                                                      _searchTargetValue,
                                                  onChanged: (value) {
                                                    setBottomSheetState(() {
                                                      _searchTargetValue =
                                                          value;
                                                    });
                                                  },
                                                ),
                                              ),
                                              Flexible(
                                                child: RadioListTile<String>(
                                                  value: search_target[0],
                                                  title: Text(I18n.of(context)
                                                      .title_and_caption),
                                                  groupValue:
                                                      _searchTargetValue,
                                                  onChanged: (value) {
                                                    setBottomSheetState(() {
                                                      _searchTargetValue =
                                                          value;
                                                    });
                                                  },
                                                ),
                                              ),
                                            ],
                                          ),
                                          SwitchListTile(
                                              title: Text(I18n.of(context)
                                                  .Date_duration),
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
                                                    DatePicker.showDatePicker(
                                                        context,
                                                        maxDateTime: endDate,
                                                        initialDateTime:
                                                            startDate,
                                                        onConfirm: (DateTime
                                                                dateTime,
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
                                                    DatePicker.showDatePicker(
                                                        context,
                                                        maxDateTime:
                                                            DateTime.now(),
                                                        initialDateTime:
                                                            endDate,
                                                        onConfirm: (DateTime
                                                                dateTime,
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
                                                BlocProvider.of<
                                                            SearchResultBloc>(
                                                        context)
                                                    .add(ApplyEvent(
                                                        widget.word,
                                                        _sortValue,
                                                        _searchTargetValue,
                                                        startDate,
                                                        endDate,
                                                        enableDuration));
                                              },
                                              child:
                                                  Text(I18n.of(context).Apply),
                                              color: Theme.of(context)
                                                  .primaryColor,
                                              textColor: Colors.white,
                                            ),
                                          ),
                                          Container(
                                            height: MediaQuery.of(context).padding.bottom,
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
                  ];
                },
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
          else
            return Scaffold(
              appBar: _buildAppBar(context),
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );
        },
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

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      title: Text(widget.word),
      actions: <Widget>[
        IconButton(
          icon: Icon(Icons.more_vert),
          onPressed: () {
            showModalBottomSheet<void>(
                context: context,
                builder: (_) {
                  return StatefulBuilder(builder: (_, setBottomSheetState) {
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
                              ...sort
                                  .map((f) => Flexible(
                                        child: RadioListTile<String>(
                                          value: f,
                                          title: Text(f),
                                          groupValue: _sortValue,
                                          onChanged: (value) {
                                            setBottomSheetState(() {
                                              _sortValue = value;
                                            });
                                          },
                                        ),
                                      ))
                                  .toList(),
                            ],
                          ),
                          Row(
                            children: <Widget>[
                              ...search_target
                                  .map((f) => Flexible(
                                        child: RadioListTile<String>(
                                          value: f,
                                          title: Text(f),
                                          groupValue: _searchTargetValue,
                                          onChanged: (value) {
                                            setBottomSheetState(() {
                                              _searchTargetValue = value;
                                            });
                                          },
                                        ),
                                      ))
                                  .toList(),
                            ],
                          ),
                          SwitchListTile(
                              title: Text("Duration"),
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
                                        initialDateTime: startDate, onConfirm:
                                            (DateTime dateTime,
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
                                        initialDateTime: endDate, onConfirm:
                                            (DateTime dateTime,
                                                List<int> list) {
                                      setBottomSheetState(() {
                                        endDate = dateTime;
                                      });
                                      setState(() {
                                        endDate = dateTime;
                                      });
                                    });
                                  },
                                  child: Text(
                                      endDate.toIso8601String().split("T")[0]),
                                ),
                              ],
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                            ),
                            visible: enableDuration,
                          ),
                          Padding(
                            padding:
                                const EdgeInsets.only(left: 8.0, right: 8.0),
                            child: RaisedButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                                BlocProvider.of<SearchResultBloc>(context).add(
                                    ApplyEvent(
                                        widget.word,
                                        _sortValue,
                                        _searchTargetValue,
                                        startDate,
                                        endDate,
                                        enableDuration));
                              },
                              child: Text("Apply"),
                              color: Theme.of(context).primaryColor,
                              textColor: Colors.white,
                            ),
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
        tabs: <Widget>[
          Tab(
            child: Text(I18n.of(context).Illust),
          ),
          Tab(
            child: Text(I18n.of(context).Painter),
          ),
        ],
      ),
    );
  }
}
