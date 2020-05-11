import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:pixez/component/pixiv_image.dart';
import 'package:pixez/models/illust.dart';
import 'package:pixez/main.dart';

class PhotoViewerPage extends StatefulWidget {
  final int index;
  final Illusts illusts;
  const PhotoViewerPage({Key key, this.index, this.illusts}) : super(key: key);

  @override
  _PhotoViewerPageState createState() => _PhotoViewerPageState();
}

class _PhotoViewerPageState extends State<PhotoViewerPage> {
  var index = 0;

  @override
  void initState() {
    super.initState();
    index = widget.index;
  }

  Widget _buildPager() => PageView(
        onPageChanged: (index) {
          setState(() {
            this.index = index;
          });
        },
        controller: PageController(initialPage: widget.index),
        children: <Widget>[
          ...widget.illusts.metaPages.map((f) => PhotoView(
                imageProvider: PixivProvider.url(userSetting.zoomQuality == 0
                    ? f.imageUrls.large
                    : f.imageUrls.original),
              ))
        ],
      );
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.black,
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
          title: Text(
            "${index + 1}/${widget.illusts.pageCount}",
            style: TextStyle(color: Colors.white),
          ),
        ),
        extendBodyBehindAppBar: true,
        extendBody: true,
        body: widget.illusts.pageCount == 1
            ? PhotoView(
                imageProvider: PixivProvider.url(userSetting.zoomQuality == 0
                    ? widget.illusts.imageUrls.large
                    : widget.illusts.metaSinglePage.originalImageUrl),
              )
            : _buildPager());
  }
}
