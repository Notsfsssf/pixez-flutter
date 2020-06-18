import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:pixez/generated/l10n.dart';
import 'package:pixez/main.dart';
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
    return Scaffold(
        appBar: AppBar(
          title: Text(I18n.of(context).Task_progress),
        ),
        body: buildListView(context));
  }

  Widget buildListView(BuildContext context) {
    return Observer(builder: (_) {
      return ListView(
        controller: _scrollController,
        children: saveStore.progressMaps.values
            .map((f) => Container(
                  child: ListTile(
                    subtitle: Text('${f.min}/${f.max}'),
                    title: Text(f.illusts.title),
                    trailing: f.min / f.max != 1
                        ? CircularProgressIndicator(
                            value: f.min / f.max,
                          )
                        : Icon(Icons.check_circle),
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
    });
  }
}
