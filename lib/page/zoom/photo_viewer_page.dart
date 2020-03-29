import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:pixez/component/pixiv_image.dart';

class PhotoViewerPage extends StatefulWidget {
  final String url;

  const PhotoViewerPage({Key key, this.url}) : super(key: key);

  @override
  _PhotoViewerPageState createState() => _PhotoViewerPageState();
}

class _PhotoViewerPageState extends State<PhotoViewerPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back,
              color: Colors.white,
            ),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          elevation: 0.0,
          backgroundColor: Colors.transparent,
        ),
        extendBodyBehindAppBar: true,
        extendBody: true,
        body: PhotoView(
          imageProvider: PixivProvider(widget.url),
        ));
  }
}
