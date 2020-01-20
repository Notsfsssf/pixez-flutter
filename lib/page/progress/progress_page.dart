import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pixez/bloc/bloc.dart';
import 'package:pixez/generated/i18n.dart';
import 'package:pixez/page/picture/picture_page.dart';

class ProgressPage extends StatefulWidget {
  @override
  _ProgressPageState createState() => _ProgressPageState();
}

class _ProgressPageState extends State<ProgressPage>
    with SingleTickerProviderStateMixin {
  ScrollController _scrollController;
  TabController _tabController;
  @override
  void initState() {
    _tabController = TabController(length: 1, vsync: this);
    _scrollController = ScrollController();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    _scrollController?.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SaveBloc, SaveState>(condition: (pre, now) {
      return now is SaveProgressSate;
    }, builder: (context, snapshot) {
      if (snapshot is SaveProgressSate)
        return Scaffold(
          appBar: AppBar(
          title: Text(I18n.of(context).Task_progress),),
          body: TabBarView(
            controller: _tabController,
            children: <Widget>[buildListView(snapshot, context)],
          ),
        );
      return Scaffold(
        appBar: AppBar(
          title: Text(I18n.of(context).Task_progress),
        ),
        body: Center(
          child: Text("Nobody here but us chickens!"),
        ),
      );
    });
  }

  ListView buildListView(SaveProgressSate snapshot, BuildContext context) {
    return ListView(
      controller: _scrollController,
      children: snapshot.progressMaps.values
          .map((f) => Container(
                child: ListTile(
                  subtitle: LinearProgressIndicator(
                    value: f.min / f.max,
                  ),
                  title: Text(f.illusts.title),
                  onTap: () {
                    Navigator.of(context, rootNavigator: true).push(
                        MaterialPageRoute(
                            builder: (context) =>
                                PicturePage(f.illusts, f.illusts.id)));
                  },
                ),
              ))
          .toList(),
    );
  }
}
