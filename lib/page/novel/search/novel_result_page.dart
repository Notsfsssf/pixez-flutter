import 'package:flutter/material.dart';
import 'package:pixez/i18n.dart';
import 'package:pixez/main.dart';
import 'package:pixez/models/tags.dart';
import 'package:pixez/network/api_client.dart';
import 'package:pixez/page/novel/search/novel_result_list.dart';
import 'package:pixez/page/painter/painter_list.dart';

class NovelResultPage extends StatefulWidget {
  final String word;
  final String? translatedName;

  const NovelResultPage({Key? key, required this.word, this.translatedName})
      : super(key: key);

  @override
  _NovelResultPageState createState() => _NovelResultPageState();
}

class _NovelResultPageState extends State<NovelResultPage> {
  @override
  void initState() {
    super.initState();
    tagHistoryStore.insert(TagsPersist(
        name: widget.word, translatedName: widget.translatedName ?? ""));
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.word),
          bottom: TabBar(tabs: [
            Tab(
              child: Text('Novel'),
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
