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

import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_statusbar_manager/flutter_statusbar_manager.dart';
import 'package:pixez/component/pixiv_image.dart';
import 'package:pixez/generated/l10n.dart';
import 'package:pixez/main.dart';
import 'package:pixez/models/illust.dart';
import 'package:pixez/exts.dart';

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
  int _currentIndex = 0;
  bool _showSwiper = true;
  double _imageDetailY = 0;
  Rect imageDRect;

  @override
  void dispose() {
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
    super.initState();
    index = widget.index;
    FlutterStatusbarManager.setHidden(true,
        animation: StatusBarAnimation.SLIDE);
  }

  Widget _buildContent(BuildContext context) {
    if (widget.illusts.pageCount == 1) {
      final url = userSetting.zoomQuality == 0
          ? widget.illusts.imageUrls.large
          : widget.illusts.metaSinglePage.originalImageUrl;
      return InkWell(
        onLongPress: () {
          showModalBottomSheet(
              context: context,
              shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.vertical(top: Radius.circular(16.0))),
              builder: (_) {
                return SafeArea(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      ListTile(
                        title: Text(I18n.of(context).save),
                        onTap: () {
                          saveStore.saveImage(widget.illusts);
                          Navigator.of(context).pop();
                        },
                      ),
                    ],
                  ),
                );
              });
        },
        child: Container(
          height: MediaQuery.of(context).size.height,
          child: ExtendedImage.network(
            url.toTrueUrl(),
            headers: {
              "referer": "https://app-api.pixiv.net/",
              "User-Agent": "PixivIOSApp/5.8.0",
              "Host": ImageHost
            },
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
        ),
      );
    } else {
      final metaPages = widget.illusts.metaPages;
      return InkWell(
        onLongPress: () {
          showModalBottomSheet(
              context: context,
              shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.vertical(top: Radius.circular(16.0))),
              builder: (_) {
                return SafeArea(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      ListTile(
                        title: Text(I18n.of(context).save),
                        onTap: () {
                          saveStore.saveImage(widget.illusts, index: index);
                          Navigator.of(context).pop();
                        },
                      ),
                    ],
                  ),
                );
              });
        },
        child: Container(
          height: MediaQuery.of(context).size.height,
          child: ExtendedImageGesturePageView.builder(
            controller: PageController(
              initialPage: index,
            ),
            onPageChanged: (i) {
              setState(() {
                index = i;
              });
            },
            itemCount: metaPages.length,
            itemBuilder: (BuildContext context, int index) {
              return ExtendedImage.network(
                (userSetting.zoomQuality == 0
                    ? metaPages[index].imageUrls.large
                    : metaPages[index].imageUrls.original).toTrueUrl(),
                headers: {
                  "referer": "https://app-api.pixiv.net/",
                  "User-Agent": "PixivIOSApp/5.8.0",
                  "Host": ImageHost
                },
                enableLoadState: true,
                loadStateChanged: (ExtendedImageState state) {
                  return _loadStateWidget(state);
                },
                onDoubleTap: (ExtendedImageGestureState state) {
                  ///you can use define pointerDownPosition as you can,
                  ///default value is double tap pointer down postion.
                  _doubleTap(state);
                },
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
        ),
      );
    }
  }

  Widget _loadStateWidget(ExtendedImageState state) {
    if (state.extendedImageLoadState == LoadState.loading) {
      // return CircularProgressIndicator(
      //   value: state.loadingProgress.cumulativeBytesLoaded.toDouble() /
      //       state.loadingProgress.expectedTotalBytes,
      // );
    }
    return null;
  }

  void _doubleTap(ExtendedImageGestureState state) {
    ///you can use define pointerDownPosition as you can,
    ///default value is double tap pointer down postion.
    final Offset pointerDownPosition = state.pointerDownPosition;
    final double begin = state.gestureDetails.totalScale;
    double end;

    //remove old
    _doubleClickAnimation?.removeListener(_doubleClickAnimationListener);

    //stop pre
    _doubleClickAnimationController.stop();

    //reset to use
    _doubleClickAnimationController.reset();

    if (begin == doubleTapScales[0]) {
      end = doubleTapScales[1];
    } else {
      end = doubleTapScales[0];
    }

    _doubleClickAnimationListener = () {
      //print(_animation.value);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.black,
        floatingActionButton: Visibility(
          visible: show,
          child: FloatingActionButton.extended(
            onPressed: () async {
              await FlutterStatusbarManager.setHidden(false);
              Navigator.of(context).pop();
            },
            label: Text(
              "${index + 1}/${widget.illusts.pageCount}",
            ),
            icon: Icon(
              Icons.arrow_back,
            ),
          ),
        ),
        extendBodyBehindAppBar: true,
        extendBody: true,
        body: _buildContent(context));
  }
}
