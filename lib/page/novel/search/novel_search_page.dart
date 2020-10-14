import 'package:flutter/material.dart';

class NovelSearchPage extends StatefulWidget {
  @override
  _NovelSearchPageState createState() => _NovelSearchPageState();
}

class _NovelSearchPageState extends State<NovelSearchPage> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: CustomScrollView(
        slivers: [
          SliverAppBar(
            actions: [
              IconButton(
                icon: Icon(Icons.search),
                onPressed: () {},
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
