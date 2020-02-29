import 'package:flutter/widgets.dart';
import 'package:pixez/models/illust.dart';
import 'package:pixez/page/picture/picture_page.dart';

class PictureListPage extends StatefulWidget {
  final List<Illusts> illusts;
  final int nowPosition;

  const PictureListPage(
      {Key key, @required this.illusts, @required this.nowPosition})
      : super(key: key);

  @override
  _PictureListPageState createState() => _PictureListPageState();
}

class _PictureListPageState extends State<PictureListPage> {
  PageController _pageController;

  @override
  void initState() {
    _pageController = PageController(initialPage: widget.nowPosition);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return PageView(
      controller: _pageController,
      children: <Widget>[...widget.illusts.map((f) => PicturePage(f, f.id))],
    );
  }
}
