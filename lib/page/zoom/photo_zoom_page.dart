import 'dart:io';

import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:pixez/component/pixiv_image.dart';
import 'package:pixez/main.dart';
import 'package:pixez/models/illust.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path/path.dart';

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
    _loadSource = userSetting.zoomQuality == 1;
    _illusts = widget.illusts;
    _index = widget.index;
    nowUrl = _illusts.pageCount == 1
        ? (_loadSource
            ? _illusts.metaSinglePage!.originalImageUrl!
            : _illusts.imageUrls.large)
        : (_loadSource
            ? _illusts.metaPages[_index].imageUrls!.original
            : _illusts.metaPages[_index].imageUrls!.large);

    super.initState();
    initCache();
  }

  initCache() async {
    var fileInfo = await pixivCacheManager.getFileFromCache(nowUrl);
    if (mounted)
      setState(() {
        shareShow = fileInfo != null;
      });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Builder(builder: (context) {
      if (_illusts.pageCount == 1) {
        final url = _loadSource
            ? _illusts.metaSinglePage!.originalImageUrl!
            : _illusts.imageUrls.large;
        return Scaffold(
          extendBody: true,
          extendBodyBehindAppBar: true,
          backgroundColor: Colors.black,
          bottomNavigationBar: _buildBottom(context),
          body: Container(
            child: PhotoView(
              filterQuality: FilterQuality.high,
              initialScale: PhotoViewComputedScale.contained,
              heroAttributes: PhotoViewHeroAttributes(tag: url),
              imageProvider: PixivProvider.url(url),
              loadingBuilder: (context, event) => _buildLoading(event),
            ),
          ),
        );
      } else {
        return Scaffold(
          backgroundColor: Colors.black,
          extendBody: true,
          bottomNavigationBar: _buildBottom(context),
          extendBodyBehindAppBar: true,
          body: Container(
              child: PhotoViewGallery.builder(
            scrollPhysics: const BouncingScrollPhysics(),
            pageController: PageController(initialPage: _index),
            builder: (BuildContext context, int index) {
              final url = _loadSource
                  ? _illusts.metaPages[index].imageUrls!.original
                  : _illusts.metaPages[index].imageUrls!.large;
              return PhotoViewGalleryPageOptions(
                imageProvider: PixivProvider.url(url),
                initialScale: PhotoViewComputedScale.contained,
                heroAttributes: PhotoViewHeroAttributes(tag: url),
                filterQuality: FilterQuality.high,
              );
            },
            itemCount: _illusts.metaPages.length,
            onPageChanged: (index) async {
              nowUrl = _loadSource
                  ? _illusts.metaPages[index].imageUrls!.original
                  : _illusts.metaPages[index].imageUrls!.large;
              setState(() {
                _index = index;
                shareShow = false;
              });
              var file = await pixivCacheManager.getFileFromCache(nowUrl);
              if (file != null && mounted)
                setState(() {
                  shareShow = true;
                });
            },
            loadingBuilder: (context, event) => _buildLoading(event),
          )),
        );
      }
    });
  }

  String nowUrl = "";

  bool show = false;
  bool shareShow = false;
  bool _loadSource = false;

  Widget _buildBottom(BuildContext context) {
    return BottomAppBar(
      color: Colors.transparent,
      child: Visibility(
        visible: true,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              children: [
                IconButton(
                  iconSize: 16,
                  icon: Icon(
                    Icons.photo_library_outlined,
                    color: Colors.white,
                  ),
                  onPressed: () {},
                ),
                Text(
                  "${_index + 1}/${widget.illusts.pageCount}",
                  style: Theme.of(context)
                      .textTheme
                      .bodyText1!
                      .copyWith(color: Colors.white),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                    icon: Icon(
                      Icons.arrow_back,
                      color: Colors.white,
                    ),
                    onPressed: () async {
                      Navigator.of(context).pop();
                    }),
                GestureDetector(
                    child: IconButton(
                        icon: Icon(
                          Icons.save_alt,
                          color: Colors.white,
                        ),
                        onPressed: () {
                          if (_illusts.metaPages.isNotEmpty)
                            saveStore.saveImage(widget.illusts, index: _index);
                          else
                            saveStore.saveImage(widget.illusts);
                        }),
                    onLongPress: () async {
                      if (_illusts.metaPages.isNotEmpty)
                        saveStore.saveImage(widget.illusts,
                            index: _index, antiHashCheck: true);
                      else
                        saveStore.saveImage(widget.illusts,
                            antiHashCheck: true);
                    }),
                AnimatedOpacity(
                  opacity: shareShow ? 1 : 0.5,
                  duration: Duration(milliseconds: 500),
                  child: IconButton(
                      icon: Icon(
                        Icons.share,
                        color: Colors.white,
                      ),
                      onPressed: () async {
                        var file =
                            await pixivCacheManager.getFileFromCache(nowUrl);
                        if (file != null) {
                          String targetPath = join(
                              (await getTemporaryDirectory()).path,
                              "share_cache",
                              basenameWithoutExtension(file.file.path) +
                                  (nowUrl.endsWith(".png") ? ".png" : ".jpg"));
                          File targetFile = new File(targetPath);
                          if (!targetFile.existsSync()) {
                            targetFile.createSync(recursive: true);
                          }
                          file.file.copySync(targetPath);
                          Share.shareFiles(
                            [targetPath],
                          );
                        } else {
                          BotToast.showText(text: "can not find image cache");
                        }
                      }),
                ),
                IconButton(
                    icon: Icon(
                      !_loadSource ? Icons.hd_outlined : Icons.hd,
                      color: Colors.white,
                    ),
                    onPressed: () {
                      setState(() {
                        _loadSource = !_loadSource;
                      });
                    }),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Center _buildLoading(ImageChunkEvent? event) {
    double value = event == null || event.expectedTotalBytes == null
        ? 0
        : event.cumulativeBytesLoaded / event.expectedTotalBytes!;
    if (value == 1.0) {
      Future.delayed(Duration(milliseconds: 500), () {
        if (mounted) {
          setState(() {
            shareShow = true;
          });
        }
      });
    }
    return Center(
      child: Container(
        width: 20.0,
        height: 20.0,
        child: CircularProgressIndicator(
          value: value,
        ),
      ),
    );
  }
}
