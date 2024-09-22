import 'package:flutter/material.dart';
import 'package:pixez/i18n.dart';
import 'package:pixez/models/board_info.dart';

class BoardPage extends StatefulWidget {
  const BoardPage({super.key});

  @override
  State<BoardPage> createState() => _BoardPageState();
}

class _BoardPageState extends State<BoardPage> {
  bool _needBoardSection = false;
  List<BoardInfo> _boardList = [];

  @override
  void initState() {
    super.initState();
    fetchBoard();
  }

  fetchBoard() async {
    try {
      final list = await BoardInfo.load();
      setState(() {
        _needBoardSection = _boardList.isNotEmpty;
        _boardList = list;
      });
    } catch (e) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(I18n.of(context).bulletin_board),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await fetchBoard();
        },
        backgroundColor: Theme.of(context).cardColor,
        child: ListView(
          children: [
            for (final board in _boardList)
              Column(
                children: [
                  Text(board.title),
                ],
              )
          ],
        ),
      ),
    );
  }
}
