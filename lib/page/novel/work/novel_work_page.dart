import 'package:flutter/material.dart';
import 'package:pixez/network/api_client.dart';
import 'package:pixez/page/novel/component/novel_lighting_list.dart';

class NovelWorkPage extends StatefulWidget {
  final int id;

  const NovelWorkPage({Key? key, required this.id}) : super(key: key);

  @override
  _NovelWorkPageState createState() => _NovelWorkPageState();
}

class _NovelWorkPageState extends State<NovelWorkPage> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: NovelLightingList(
        futureGet: () => apiClient.getUserNovels(widget.id),
      ),
    );
  }
}
