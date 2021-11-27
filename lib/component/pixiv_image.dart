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

import 'package:cached_network_image/cached_network_image.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:pixez/er/hoster.dart';
import 'package:pixez/exts.dart';
import 'package:pixez/i18n.dart';
import 'package:pixez/main.dart';

const ImageHost = "i.pximg.net";
const ImageCatHost = "i.pixiv.re";
const ImageSHost = "s.pximg.net";

class PixivImage extends StatefulWidget {
  final String url;
  final Widget? placeWidget;
  final bool fade;
  final BoxFit? fit;
  final bool? enableMemoryCache;
  final double? height;
  final double? width;
  final String? host;

  PixivImage(this.url,
      {this.placeWidget,
      this.fade = true,
      this.fit,
      this.enableMemoryCache,
      this.height,
      this.host,
      this.width});

  @override
  _PixivImageState createState() => _PixivImageState();
}

class _PixivImageState extends State<PixivImage>
    with SingleTickerProviderStateMixin {
  late String url;
  late AnimationController _controller;
  bool already = false;
  bool? enableMemoryCache;
  double? width;
  double? height;
  BoxFit? fit;
  bool fade = true;
  Widget? placeWidget;

  @override
  void initState() {
    url = widget.url;
    enableMemoryCache = widget.enableMemoryCache ?? true;
    width = widget.width;
    height = widget.height;
    fit = widget.fit;
    fade = widget.fade;
    placeWidget = widget.placeWidget;
    _controller = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 500),
        lowerBound: 0.2,
        upperBound: 1.0);
    super.initState();
  }

  @override
  void didUpdateWidget(covariant PixivImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.url != widget.url) {
      setState(() {
        url = widget.url;
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
        placeholder: (context, url) =>
            widget.placeWidget ??
            Container(
              child: Center(child: CircularProgressIndicator()),
            ),
        imageUrl: url.toTrueUrl(),
        height: height,
        width: width,
        fit: fit ?? BoxFit.fitWidth,
        httpHeaders: Hoster.header(url: url));
    return ExtendedImage.network(
      url.toTrueUrl(),
      height: height,
      width: width,
      fit: fit ?? BoxFit.fitWidth,
      headers: Hoster.header(url: url),
      enableMemoryCache: enableMemoryCache ?? true,
      loadStateChanged: (ExtendedImageState state) {
        return null;
        if (state.extendedImageLoadState == LoadState.loading) {
          if (!_controller.isCompleted) _controller.reset();
          return placeWidget;
        }
        if (state.extendedImageLoadState == LoadState.completed) {
          if (already) {
            return null;
          }
          already = true;
          if (!_controller.isCompleted) _controller.forward();
          if (!fade)
            return ExtendedRawImage(
              fit: fit ?? BoxFit.fitWidth,
              image: state.extendedImageInfo?.image,
            );
          return FadeTransition(
            opacity: _controller,
            child: ExtendedRawImage(
              fit: BoxFit.fitWidth,
              image: state.extendedImageInfo?.image,
            ),
          );
        }
        if (state.extendedImageLoadState == LoadState.failed) {
          if (!_controller.isCompleted) _controller.reset();
          splashStore.maybeFetch();
          return Container(
            height: 150,
            child: GestureDetector(
              child: Stack(
                fit: StackFit.expand,
                children: <Widget>[
                  Icon(Icons.error),
                  Positioned(
                    bottom: 0.0,
                    left: 0.0,
                    right: 0.0,
                    child: Text(
                      I18n.of(context).load_image_failed_click_to_reload,
                      textAlign: TextAlign.center,
                    ),
                  )
                ],
              ),
              onTap: () {
                splashStore.maybeFetch();
                state.reLoadImage();
              },
            ),
          );
        }
        return null;
      },
    );
  }
}

class PixivProvider {
  static CachedNetworkImageProvider url(String url, {String? preUrl}) {
    return CachedNetworkImageProvider(url, headers: Hoster.header(url: preUrl));
  }
}

// class RubyProvider extends ImageProvider{
//   @override
//   ImageStreamCompleter load(Object key, Future<Codec> Function(Uint8List bytes, {bool allowUpscaling, int cacheHeight, int cacheWidth}) decode) {
//     // TODO: implement load
//     throw UnimplementedError();
//   }
//
//   @override
//   Future<Object> obtainKey(ImageConfiguration configuration) {
//     // TODO: implement obtainKey
//     throw UnimplementedError();
//   }
// }
