import 'dart:io';

import 'package:bot_toast/bot_toast.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/gestures.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:pixez/clipboard_plugin.dart';
import 'package:pixez/er/pixiv_image_source.dart';
import 'package:pixez/fluent/component/pixiv_image.dart';
import 'package:pixez/i18n.dart';
import 'package:pixez/main.dart';
import 'package:pixez/models/illust.dart';
import 'package:share_plus/share_plus.dart';

class PhotoZoomPage extends StatefulWidget {
  final int index;
  final Illusts illusts;

  const PhotoZoomPage({Key? key, required this.index, required this.illusts})
    : super(key: key);

  @override
  _PhotoZoomPageState createState() => _PhotoZoomPageState();
}

class _PhotoZoomPageState extends State<PhotoZoomPage> {
  // PageController? _pageController;
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
    var fileInfo = await pixivCacheManager!.getFileFromCache(
      _sourceUrl(nowUrl),
    );
    if (mounted)
      setState(() {
        shareShow = fileInfo != null;
      });
  }

  @override
  void dispose() {
    super.dispose();
  }

  final PhotoViewController _photoViewController = PhotoViewController();

  @override
  Widget build(BuildContext context) {
    return ScaffoldPage(
      padding: const EdgeInsets.all(0),
      header: _buildCommandBar(context),
      content: Builder(
        builder: (context) {
          if (_illusts.pageCount == 1) {
            final url = _loadSource
                ? _illusts.metaSinglePage!.originalImageUrl!
                : _illusts.imageUrls.large;
            return Listener(
              onPointerSignal: (event) {
                if (event is PointerScrollEvent) {
                  _photoViewController.scale =
                      (_photoViewController.scale ?? 0) -
                      event.scrollDelta.dy / 1000;
                }
              },
              child: PhotoView(
                filterQuality: FilterQuality.high,
                initialScale: PhotoViewComputedScale.contained,
                heroAttributes: PhotoViewHeroAttributes(tag: url),
                imageProvider: PixivProvider.url(url),
                loadingBuilder: (context, event) => _buildLoading(event),
                controller: _photoViewController,
              ),
            );
          } else {
            return Container(
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
                  var file = await pixivCacheManager!.getFileFromCache(
                    _sourceUrl(nowUrl),
                  );
                  if (file != null && mounted)
                    setState(() {
                      shareShow = true;
                    });
                },
                loadingBuilder: (context, event) => _buildLoading(event),
              ),
            );
          }
        },
      ),
    );
  }

  String nowUrl = "";

  String _sourceUrl(String url) => PixivImageSource.resolve(
    url,
    networkMode: userSetting.networkMode,
    pictureSource: userSetting.pictureSource,
  );

  bool show = false;
  bool shareShow = false;
  bool _loadSource = false;

  Widget _buildCommandBar(BuildContext context) {
    return CommandBar(
      mainAxisAlignment: MainAxisAlignment.end,
      primaryItems: [
        // CommandBarButton(
        //   icon: Icon(FluentIcons.previous),
        //   label: Text(I18n.of(context).pre),
        //   onPressed: () {
        //     if (_index - 1 > 0) _pageController?.jumpToPage(_index - 1);
        //   },
        // ),
        CommandBarButton(
          icon: Icon(FluentIcons.picture_library),
          label: Text("${_index + 1}/${widget.illusts.pageCount}"),
          onPressed: () {},
        ),
        // CommandBarButton(
        //   icon: Icon(FluentIcons.next),
        //   label: Text(I18n.of(context).next),
        //   onPressed: () {
        //     if (_index + 1 <= widget.illusts.pageCount)
        //       _pageController?.jumpToPage(_index + 1);
        //   },
        // ),
        CommandBarSeparator(),
        CommandBarButton(
          icon: Icon(FluentIcons.copy),
          label: Text(I18n.of(context).copy),
          onPressed: () => ClipboardPlugin.copy(context, _illusts, _index),
        ),
        CommandBarButton(
          icon: Icon(FluentIcons.save),
          label: Text(I18n.of(context).save),
          onPressed: () {
            if (_illusts.metaPages.isNotEmpty)
              saveStore.saveImage(widget.illusts, index: _index);
            else
              saveStore.saveImage(widget.illusts);
          },
        ),
        CommandBarButton(
          icon: Icon(FluentIcons.share),
          label: Text(I18n.of(context).share),
          onPressed: () async {
            var file = await pixivCacheManager!.getFileFromCache(
              _sourceUrl(nowUrl),
            );
            if (file != null) {
              String targetPath = join(
                (await getTemporaryDirectory()).path,
                "share_cache",
                basenameWithoutExtension(file.file.path) +
                    (nowUrl.endsWith(".png") ? ".png" : ".jpg"),
              );
              File targetFile = new File(targetPath);
              if (!targetFile.existsSync()) {
                targetFile.createSync(recursive: true);
              }
              file.file.copySync(targetPath);
              SharePlus.instance.share(ShareParams(files: [XFile(targetPath)]));
            } else {
              BotToast.showText(text: "can not find image cache");
            }
          },
        ),
        CommandBarButton(
          icon: Icon(
            _loadSource ? FluentIcons.picture : FluentIcons.picture_fill,
          ),
          label: Text(
            _loadSource ? I18n.of(context).source : I18n.of(context).large,
          ),
          onPressed: () {
            setState(() {
              _loadSource = !_loadSource;
            });
          },
        ),
      ],
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
      child: Container(width: 60.0, height: 60.0, child: ProgressRing()),
    );
  }
}
