import 'package:flutter/material.dart';
import 'package:pixez/generated/l10n.dart';
import 'package:pixez/page/search/result/painter/search_result_painter_page.dart';
import 'package:pixez/page/search/result_illust_list.dart';
import 'package:pixez/page/search/search_page.dart';

class ResultPage extends StatefulWidget {
  final String word;

  const ResultPage({Key key, this.word}) : super(key: key);
  @override
  _ResultPageState createState() => _ResultPageState();
}

class _ResultPageState extends State<ResultPage> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: InkWell(
            child: Text(widget.word),
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => Scaffold(
                          body: SearchPage(
                        preWord: widget.word,
                      ))));
            },
          ),
          bottom: TabBar(tabs: [
            Tab(
              text: I18n.of(context).Illust,
            ),
            Tab(
              text: I18n.of(context).Painter,
            ),
          ]),
        ),
        body: TabBarView(children: [
          ResultIllustList(word: widget.word),
           SearchResultPainterPage(
                  word: widget.word,
                ),
        ]),
      ),
    );
  }
}