import 'package:flutter/material.dart';
import 'package:pixez/network/api_client.dart';
import 'package:pixez/page/novel/component/novel_lighting_list.dart';

class NovelResultList extends StatefulWidget {
  final String word;

  const NovelResultList({Key key, this.word}) : super(key: key);
  @override
  _NovelResultListState createState() => _NovelResultListState();
}

class _NovelResultListState extends State<NovelResultList> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: NovelLightingList(
          futureGet: () => apiClient.getSearchNovel(widget.word)),
    );
  }
}
