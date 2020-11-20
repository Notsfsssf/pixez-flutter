import 'package:flutter/material.dart';
import 'package:pixez/er/leader.dart';
import 'package:pixez/page/novel/search/novel_result_page.dart';

class NovelSearchPage extends StatefulWidget {
  @override
  _NovelSearchPageState createState() => _NovelSearchPageState();
}

class _NovelSearchPageState extends State<NovelSearchPage> {
  TextEditingController _textEditingController;
  @override
  void initState() {
    _textEditingController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _textEditingController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: CustomScrollView(
        slivers: [
          SliverAppBar(
            title: TextField(
              controller: _textEditingController,
            ),
            actions: [
              IconButton(
                icon: Icon(Icons.search),
                onPressed: () {
                  if (_textEditingController.text.isNotEmpty) {
                    Leader.push(
                        context,
                        NovelResultPage(
                          word: _textEditingController.text,
                        ));
                  }
                },
              )
            ],
          ),
          
          // SliverGrid(
          //   gridDelegate:
          //       SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
          //   delegate: SliverChildBuilderDelegate((context,index){},childCount: ),
          // )
        ],
      ),
    );
  }
}
