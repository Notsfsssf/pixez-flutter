/*
 * Copyright (C) 2020. by perol_notsf, All rights reserved
 *
 * This program is free software: you can redistribute it and/or modify it under
 * the terms of the GNU General Public License as published by the Free Software
 * Foundation, either version 3 of the License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful, but WITHOUT ANY
 * WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
 * FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License along with
 * this program. If not, see <http://www.gnu.org/licenses/>.
 *
 */

import 'dart:async';
import 'dart:io';

import 'package:bot_toast/bot_toast.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_statusbar_manager/flutter_statusbar_manager.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pixez/component/pixiv_image.dart';
import 'package:pixez/exts.dart';
import 'package:pixez/generated/l10n.dart';
import 'package:pixez/main.dart';
import 'package:pixez/models/illust.dart';
import 'package:share_extend/share_extend.dart';

class PhotoViewerPage extends StatefulWidget {
  final int index;
  final Illusts illusts;

  const PhotoViewerPage({Key key, this.index, this.illusts}) : super(key: key);

  @override
  _PhotoViewerPageState createState() => _PhotoViewerPageState();
}

typedef DoubleClickAnimationListener = void Function();

class _PhotoViewerPageState extends State<PhotoViewerPage>
    with TickerProviderStateMixin {
  int index = 0;
  final StreamController<int> rebuildIndex = StreamController<int>.broadcast();
  final StreamController<bool> rebuildSwiper =
      StreamController<bool>.broadcast();
  final StreamController<double> rebuildDetail =
      StreamController<double>.broadcast();
  AnimationController _doubleClickAnimationController;
  AnimationController _slideEndAnimationController;
  Animation<double> _slideEndAnimation;
  Animation<double> _doubleClickAnimation;
  DoubleClickAnimationListener _doubleClickAnimationListener;
  List<double> doubleTapScales = <double>[1.0, 2.0];
  GlobalKey<ExtendedImageSlidePageState> slidePagekey =
      GlobalKey<ExtendedImageSlidePageState>();
  bool _showSwiper = true;
  double _imageDetailY = 0;
  Rect imageDRect;

  @override
  void dispose() {
    if (Platform.isAndroid || Platform.isIOS)
      FlutterStatusbarManager.setHidden(false);
    _doubleClickAnimationController.dispose();
    rebuildIndex.close();
    rebuildSwiper.close();
    rebuildDetail.close();
    super.dispose();
  }

  @override
  void initState() {
    _doubleClickAnimationController = AnimationController(
        duration: const Duration(milliseconds: 150), vsync: this);
    _slideEndAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _slideEndAnimationController.addListener(() {
      _imageDetailY = _slideEndAnimation.value;
      if (_imageDetailY == 0) {
        _showSwiper = true;
        rebuildSwiper.add(_showSwiper);
      }
      rebuildDetail.sink.add(_imageDetailY);
    });
    _loadSource = userSetting.zoomQuality == 1;
    super.initState();
    index = widget.index;
    if (Platform.isAndroid || Platform.isIOS)
      FlutterStatusbarManager.setHidden(true,
          animation: StatusBarAnimation.SLIDE);
  }

  Widget _buildContent(BuildContext context) {
    if (widget.illusts.pageCount == 1) {
      final url = (userSetting.zoomQuality == 1 || _loadSource
              ? widget.illusts.metaSinglePage.originalImageUrl
              : widget.illusts.imageUrls.large)
          .toTrueUrl();
      nowUrl = url;
      return Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: ExtendedImage.network(
          url,
          headers: {
            "referer": "https://app-api.pixiv.net/",
            "User-Agent": "PixivIOSApp/5.8.0",
            "Host": ImageHost
          },
          handleLoadingProgress: true,
          clearMemoryCacheWhenDispose: true,
          enableLoadState: true,
          loadStateChanged: (ExtendedImageState state) {
            return _loadStateWidget(state);
          },
          onDoubleTap: (ExtendedImageGestureState state) {
            _doubleTap(state);
          },
          filterQuality: FilterQuality.high,
          mode: ExtendedImageMode.gesture,
          initGestureConfigHandler: (state) {
            return GestureConfig(
              minScale: 0.9,
              animationMinScale: 0.7,
              maxScale: 3.0,
              animationMaxScale: 3.5,
              speed: 1.0,
              inertialSpeed: 100.0,
              initialScale: 1.0,
              inPageView: false,
              gestureDetailsIsChanged: (GestureDetails ge) {
                _showOrHideAppbar(ge); //肯定可以优化，先放着，想不动了
              },
              initialAlignment: InitialAlignment.center,
            );
          },
        ),
      );
    } else {
      final metaPages = widget.illusts.metaPages;
      final url = (userSetting.zoomQuality == 1 || _loadSource
              ? metaPages[index].imageUrls.original
              : metaPages[index].imageUrls.large)
          .toTrueUrl();
      nowUrl = url;
      return Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: ExtendedImageGesturePageView.builder(
          controller: PageController(
            initialPage: index,
          ),
          onPageChanged: (i) async {
            setState(() {
              shareShow = false;
              index = i;
            });
            final url = (userSetting.zoomQuality == 0
                    ? metaPages[index].imageUrls.large
                    : metaPages[index].imageUrls.original)
                .toTrueUrl();
            nowUrl = url;
            File file = await getCachedImageFile(url);
            if (file != null && mounted)
              setState(() {
                shareShow = true;
              });
          },
          itemCount: metaPages.length,
          itemBuilder: (BuildContext context, int index) {
            return ExtendedImage.network(
              (userSetting.zoomQuality == 0
                      ? metaPages[index].imageUrls.large
                      : metaPages[index].imageUrls.original)
                  .toTrueUrl(),
              headers: {
                "referer": "https://app-api.pixiv.net/",
                "User-Agent": "PixivIOSApp/5.8.0",
                "Host": ImageHost
              },
              handleLoadingProgress: true,
              clearMemoryCacheWhenDispose: true,
              enableLoadState: true,
              loadStateChanged: (ExtendedImageState state) =>
                  _loadStateWidget(state),
              onDoubleTap: (ExtendedImageGestureState state) =>
                  _doubleTap(state),
              mode: ExtendedImageMode.gesture,
              filterQuality: FilterQuality.high,
              initGestureConfigHandler: (ExtendedImageState state) {
                return GestureConfig(
                  inPageView: true,
                  initialScale: 1.0,
                  gestureDetailsIsChanged: (GestureDetails ge) {
                    _showOrHideAppbar(ge);
                  },
                  maxScale: 5.0,
                  animationMaxScale: 6.0,
                  initialAlignment: InitialAlignment.center,
                );
              },
            );
          },
        ),
      );
    }
  }

  String nowUrl = "";
  bool _loadSource = false;

  Widget _loadStateWidget(ExtendedImageState state) {
    if (state.extendedImageLoadState == LoadState.loading) {
      final ImageChunkEvent loadingProgress = state.loadingProgress;
      final double progress = loadingProgress?.expectedTotalBytes != null
          ? loadingProgress.cumulativeBytesLoaded /
              loadingProgress.expectedTotalBytes
          : null;
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            CircularProgressIndicator(
              value: progress,
            ),
            const SizedBox(
              height: 10.0,
            ),
            Text(
              '${((progress ?? 0.0) * 100).toInt()}%',
              style: TextStyle(color: Colors.white),
            ),
          ],
        ),
      );
    }
    if (state.extendedImageLoadState == LoadState.completed) {
      Future.delayed(Duration(milliseconds: 0), () {
        //defer
        if (mounted)
          setState(() {
            shareShow = true;
          });
      });
    }
    return null;
  }

  void _doubleTap(ExtendedImageGestureState state) {
    final Offset pointerDownPosition = state.pointerDownPosition;
    final double begin = state.gestureDetails.totalScale;
    double end;
    _doubleClickAnimation?.removeListener(_doubleClickAnimationListener);
    _doubleClickAnimationController.stop();
    _doubleClickAnimationController.reset();
    if (begin == doubleTapScales[0]) {
      end = doubleTapScales[1];
    } else {
      end = doubleTapScales[0];
    }
    _doubleClickAnimationListener = () {
      state.handleDoubleTap(
          scale: _doubleClickAnimation.value,
          doubleTapPosition: pointerDownPosition);
    };
    _doubleClickAnimation = _doubleClickAnimationController
        .drive(Tween<double>(begin: begin, end: end));
    _doubleClickAnimation.addListener(_doubleClickAnimationListener);
    _doubleClickAnimationController.forward();
  }

  void _showOrHideAppbar(GestureDetails ge) {
    if (ge.totalScale > 1.2) {
      if (show == true) {
        if (mounted)
          setState(() {
            show = false;
          });
      }
    } else {
      if (show == false) {
        if (mounted)
          setState(() {
            show = true;
          });
      }
    } //肯定可以优化，先放着，想不动了
  }

  bool show = true;
  bool shareShow = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.black,
        bottomNavigationBar: BottomAppBar(
          color: Colors.transparent,
          child: Visibility(
            visible: show,
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
                      "${index + 1}/${widget.illusts.pageCount}",
                      style: Theme.of(context)
                          .textTheme
                          .bodyText1
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
                          if (Platform.isAndroid || Platform.isIOS)
                            await FlutterStatusbarManager.setHidden(false);
                          Navigator.of(context).pop();
                        }),
                    IconButton(
                        icon: Icon(
                          Icons.save_alt,
                          color: Colors.white,
                        ),
                        onPressed: () async {
                          if (widget.illusts.metaPages.isNotEmpty)
                            saveStore.saveImage(widget.illusts, index: index);
                          else
                            saveStore.saveImage(widget.illusts);
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
                            File file = await getCachedImageFile(nowUrl);
                            if (file != null) {
                              String targetPath = join(
                                  (await getTemporaryDirectory()).path,
                                  "share_cache",
                                  basenameWithoutExtension(file.path) +
                                      (nowUrl.endsWith(".png")
                                          ? ".png"
                                          : ".jpg"));
                              File targetFile = new File(targetPath);
                              if (!targetFile.existsSync()) {
                                targetFile.createSync(recursive: true);
                              }
                              file.copySync(targetPath);
                              ShareExtend.share(targetPath, 'image');
                            } else {
                              BotToast.showText(
                                  text: "can not find image cache");
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
        ),
        extendBodyBehindAppBar: true,
        extendBody: true,
        body: _buildContent(context));
  }
}
