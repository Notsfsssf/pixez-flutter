import 'package:easy_refresh/easy_refresh.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:pixez/i18n.dart';
import 'package:pixez/models/board_info.dart';
import 'package:url_launcher/url_launcher.dart';

class BoardPage extends StatefulWidget {
  final List<BoardInfo> boardList;
  const BoardPage({super.key, required this.boardList});

  @override
  State<BoardPage> createState() => _BoardPageState();
}

class _BoardPageState extends State<BoardPage> {
  late List<BoardInfo> _boardList = widget.boardList;

  @override
  void initState() {
    super.initState();
    fetchBoard();
  }

  fetchBoard() async {
    try {
      if (_boardList.isNotEmpty) {
        return;
      }
      if (BoardInfo.boardDataLoaded) {
        setState(() {
          _boardList = BoardInfo.boardList;
        });
        return;
      }
      final list = await BoardInfo.load();
      BoardInfo.boardList = list;
      BoardInfo.boardDataLoaded = true;
      if (mounted) {
        setState(() {
          _boardList = list;
        });
      }
    } catch (e) {}
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldPage(
      header: PageHeader(title: Text(I18n.of(context).bulletin_board)),
      content: EasyRefresh(
        onRefresh: () async {
          await fetchBoard();
        },
        child: ListView(
          children: [
            for (final board in _boardList)
              Container(
                margin: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(height: 1),
                    Text(
                      board.title,
                      style: FluentTheme.of(context).typography.titleLarge,
                    ),
                    SizedBox(height: 1),
                    HtmlWidget(
                      board.content,
                      onTapUrl: (url) {
                        return launchUrl(Uri.parse(url));
                      },
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
