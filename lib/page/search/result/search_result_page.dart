import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:pixez/component/illust_card.dart';
import 'package:pixez/network/api_client.dart';
import 'package:pixez/page/search/result/bloc/bloc.dart';

class SearchResultPage extends StatefulWidget {
  final String word;

  const SearchResultPage({Key key, this.word}) : super(key: key);

  @override
  _SearchResultPageState createState() => _SearchResultPageState();
}

class _SearchResultPageState extends State<SearchResultPage>
    with SingleTickerProviderStateMixin {
  TabController _tabController;
  Completer<void> _refreshCompleter, _loadCompleter;

  @override
  void initState() {
    super.initState();
    _refreshCompleter = Completer<void>();
    _loadCompleter = Completer<void>();
    _tabController = TabController(vsync: this, length: 2);
  }

  final _scaffoldkey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      builder: (context) =>
          SearchResultBloc(ApiClient())..add(FetchEvent(widget.word)),
      child: BlocBuilder<SearchResultBloc, SearchResultState>(
        builder: (context, state) {
          if (state is DataState)
            return Scaffold(
                key: _scaffoldkey,
                appBar: AppBar(
                  title: Text(widget.word),
                  actions: <Widget>[
                    IconButton(
                      icon: Icon(Icons.more_vert),
                      onPressed: () {
                        _scaffoldkey.currentState.showBottomSheet((context) {
                          return Container(
                            height: 200,
                            child: Column(
                              children: <Widget>[
                                ListTile(
                                  title: Text("data"),
                                )
                              ],
                            ),
                          );
                        }, elevation: 20.0, shape: RoundedRectangleBorder());
                      },
                    )
                  ],
                  bottom: TabBar(
                    controller: _tabController,
                    tabs: <Widget>[
                      Tab(
                        child: Text("Illust"),
                      ),
                      Tab(
                        child: Text("Illust"),
                      ),
                    ],
                  ),
                ),
                body: BlocListener<SearchResultBloc, SearchResultState>(
                    listener: (context, state) {
                      if (state is DataState) {
                        _loadCompleter?.complete();
                        _loadCompleter = Completer();
                        _refreshCompleter?.complete();
                        _refreshCompleter = Completer();
                      }
                    },
                    child: _buildEasyRefresh(state, context)));
          else
            return Scaffold();
        },
      ),
    );
  }

  EasyRefresh _buildEasyRefresh(DataState state, BuildContext context) {
    return EasyRefresh(
      child: StaggeredGridView.countBuilder(
        crossAxisCount: 2,
        itemCount: state.illusts.length,
        itemBuilder: (context, index) {
          return IllustCard(state.illusts[index]);
        },
        staggeredTileBuilder: (int index) => StaggeredTile.fit(1),
      ),
      onRefresh: () async {
        BlocProvider.of<SearchResultBloc>(context).add(FetchEvent(widget.word));
        return _refreshCompleter.future;
      },
      onLoad: () async {
        BlocProvider.of<SearchResultBloc>(context)
            .add(LoadMoreEvent(state.nextUrl, state.illusts));
        return _loadCompleter.future;
      },
    );
  }
}
