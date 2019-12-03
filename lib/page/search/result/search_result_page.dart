import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pixez/page/search/result/bloc/bloc.dart';

class SearchResultPage extends StatefulWidget {
  final String word;

  const SearchResultPage({Key key, this.word}) : super(key: key);
  @override
  _SearchResultPageState createState() => _SearchResultPageState();
}

class _SearchResultPageState extends State<SearchResultPage> with SingleTickerProviderStateMixin {
  TabController _tabController;
  @override
  void initState() {
_tabController=TabController(vsync: this,length: 2)    
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      builder: (context)=>SearchResultBloc(),
      child: Scaffold(
        appBar: AppBar(
          title: Text("Result"),
          bottom: TabBar(controller: _tabController, tabs: <Widget>[Tab(child: Text("Illust"),)],),
        ),
        body: Container(),
      ),
    );
  }
}