import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:pixez/er/hoster.dart';
import 'package:pixez/exts.dart';
import 'package:pixez/models/illust.dart';

class PhotoZoomPage extends StatefulWidget {
  final int index;
  final Illusts illusts;

  const PhotoZoomPage({Key? key, required this.index, required this.illusts})
      : super(key: key);

  @override
  _PhotoZoomPageState createState() => _PhotoZoomPageState();
}

class _PhotoZoomPageState extends State<PhotoZoomPage> {
  late Illusts _illusts;
  int _index = 0;

  @override
  void initState() {
    _illusts = widget.illusts;
    _index = widget.index;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (_illusts.pageCount == 1) {
      final url = _illusts.metaSinglePage!.originalImageUrl!;
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0.0,
        ),
        extendBody: true,
        extendBodyBehindAppBar: true,
        body: Center(
          child: InteractiveViewer(
            panEnabled: true,
            scaleEnabled: true,
            boundaryMargin: EdgeInsets.all(40),
            minScale: 0.5,
            maxScale: 2,
            child: CachedNetworkImage(
                placeholder: (context, url) => Container(
                      child: Center(child: CircularProgressIndicator()),
                    ),
                imageUrl: url.toTrueUrl(),
                httpHeaders: Hoster.header(url: url)),
          ),
        ),
      );
    } else {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0.0,
        ),
        extendBody: true,
        extendBodyBehindAppBar: true,
        body: PageView.builder(
          controller: PageController(initialPage: _index),
          itemBuilder: (context, index) {
            final url = _illusts.metaPages[index].imageUrls!.original;
            return InteractiveViewer(
              panEnabled: false,
              boundaryMargin: EdgeInsets.all(100),
              minScale: 0.5,
              maxScale: 2,
              child: CachedNetworkImage(
                  placeholder: (context, url) => Container(
                        child: Center(child: CircularProgressIndicator()),
                      ),
                  imageUrl: url.toTrueUrl(),
                  httpHeaders: Hoster.header(url: url)),
            );
          },
          itemCount: _illusts.metaPages.length,
        ),
      );
    }
    return Container();
  }
}
