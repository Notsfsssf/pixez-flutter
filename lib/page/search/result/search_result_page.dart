import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:pixez/component/illust_card.dart';
import 'package:pixez/page/search/result/bloc/bloc.dart';

class SearchResultPage extends StatefulWidget {
  final String word;

  const SearchResultPage({Key key, this.word}) : super(key: key);
  @override
  _SearchResultPageState createState() => _SearchResultPageState();
}

class _SearchResultPageState extends State<SearchResultPage> with SingleTickerProviderStateMixin {
  TabController _tabController;
    Completer<void> _refreshCompleter, _loadCompleter;
  @override
  void initState() {
    super.initState();
    _refreshCompleter = Completer<void>();
    _loadCompleter = Completer<void>();
    _tabController=TabController(vsync: this,length: 2)  
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      builder: (context)=>SearchResultBloc(),
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.word),
          bottom: TabBar(controller: _tabController, tabs: <Widget>[Tab(child: Text("Illust"),)],),
        ),
        body: BlocBuilder<SearchResultBloc,SearchResultState>(builder: (_,state){
     if(state is DataState){
            EasyRefresh(
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
            )
     }
        },),
      ),
    );
  }
}