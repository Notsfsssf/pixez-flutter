import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:pixez/component/dropdown_list.dart';
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
  TabController _tabController1;
  Completer<void> _refreshCompleter, _loadCompleter;
  GlobalKey<ScaffoldState> _scaffoldStateKey;

  @override
  void initState() {
    super.initState();
    _scaffoldStateKey = GlobalKey<ScaffoldState>();
    _refreshCompleter = Completer<void>();
    _loadCompleter = Completer<void>();
    _tabController = TabController(vsync: this, length: 2);
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      builder: (context) =>
          SearchResultBloc(ApiClient())..add(FetchEvent(widget.word)),
      child: Scaffold(
        key: _scaffoldStateKey,
        appBar: _buildAppBar(context),
        body: BlocBuilder<SearchResultBloc, SearchResultState>(
          builder: (context, state) {
            if (state is DataState)
              return BlocListener<SearchResultBloc, SearchResultState>(
                  listener: (context, state) {
                    if (state is DataState) {
                      _loadCompleter?.complete();
                      _loadCompleter = Completer();
                      _refreshCompleter?.complete();
                      _refreshCompleter = Completer();
                    }
                  },
                  child: _buildEasyRefresh(state, context));
            else
              return Center(
                child: CircularProgressIndicator(),
              );
          },
        ),
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      title: Text(widget.word),
      actions: <Widget>[
        IconButton(
          icon: Icon(Icons.more_vert),
          onPressed: () {
            showModalBottomSheet(
                context: context,
                builder: (context) {
                  return Container(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Padding(
                          child: Text("1"),
                          padding: EdgeInsets.all(8.0),
                        ),
                        Padding(
                          child: DropDownList(),
                          padding: EdgeInsets.all(8.0),
                        ),
                      ],
                    ),
                  );
                });
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
