import 'package:flutter/material.dart';
import 'package:pixez/component/pixiv_image.dart';
import 'package:zoom_widget/zoom_widget.dart';

class ZoomPage extends StatefulWidget {
    final String url;

  const ZoomPage({Key key, this.url}) : super(key: key);
  @override
  _ZoomPageState createState() => _ZoomPageState();
}

class _ZoomPageState extends State<ZoomPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Zoom(
        height: 200,
        width: 200,
        child: PixivImage(widget.url),
      ),
    );
  }
}