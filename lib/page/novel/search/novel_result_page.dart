import 'package:flutter/material.dart';
import 'package:pixez/generated/l10n.dart';
import 'package:pixez/network/api_client.dart';
import 'package:pixez/page/novel/search/novel_result_list.dart';
import 'package:pixez/page/painter/painter_list.dart';

class NovelResultPage extends StatefulWidget {
  final String word;

  const NovelResultPage({Key key, this.word}) : super(key: key);
  @override
  _NovelResultPageState createState() => _NovelResultPageState();
}

class _NovelResultPageState extends State<NovelResultPage> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.word),
          bottom: TabBar(tabs: [
            Tab(
              child: Text(I18n.of(context).illust),
            ),
            Tab(
              child: Text(I18n.of(context).painter),
            ),
          ]),
        ),
        body: TabBarView(
          children: [
            NovelResultList(word: widget.word),
            PainterList(
              futureGet: () => apiClient.getSearchUser(widget.word),
              isNovel: true,
            )
          ],
        ),
      ),
    );
  }
}
