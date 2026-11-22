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

import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:pixez/component/pixiv_image.dart' as shared;
import 'package:pixez/network/pixiv_cache_manager.dart';
import 'package:pixez/er/hoster.dart';

const ImageHost = "i.pximg.net";
const ImageCatHost = "i.pixiv.re";
const ImageSHost = "s.pximg.net";

// 注意，stable的http_interceptor这里是无效的，因为实现send是todo
// 实现CacheManager和混入ImageCacheManager缺一不可
// 如果你恰好看到这个实现方法实例，且对你有些帮助或者启发：
// 听一首Mili-Salt, Pepper, Birds, And the Thought Police吧 🎵
// Shares the cache manager initialized by the Material PixivImage, which is
// the one UserSetting configures on every platform.
CacheManager? pixivCacheManager = PixivCacheManager.instance;

class PixivImage extends StatefulWidget {
  final String url;
  final Widget? placeWidget;
  final bool fade;
  final BoxFit? fit;
  final bool? enableMemoryCache;
  final double? height;
  final double? width;
  final String? host;

  PixivImage(
    this.url, {
    this.placeWidget,
    this.fade = true,
    this.fit,
    this.enableMemoryCache,
    this.height,
    this.host,
    this.width,
  });

  @override
  _PixivImageState createState() => _PixivImageState();

  static Future<void> generatePixivCache() =>
      shared.PixivImage.generatePixivCache();
}

class _PixivImageState extends State<PixivImage> {
  late String url;
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
    super.initState();
  }

  @override
  void didUpdateWidget(covariant PixivImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.url != widget.url) {
      setState(() {
        url = widget.url;
        width = widget.width;
        height = widget.height;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = min(min(width ?? 60, height ?? 60), 60.0);
    return CachedNetworkImage(
      placeholder: widget.placeWidget == null
          ? null
          : (context, url) =>
                widget.placeWidget ??
                Container(
                  height: height,
                  child: Center(
                    child: SizedBox(
                      width: size,
                      height: size,
                      child: const Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: const ProgressRing(),
                      ),
                    ),
                  ),
                ),
      progressIndicatorBuilder: widget.placeWidget == null
          ? (context, url, progress) => Container(
              height: height,
              child: Center(
                child: SizedBox(
                  width: size,
                  height: size,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ProgressRing(value: progress.progress),
                  ),
                ),
              ),
            )
          : null,
      errorWidget: (context, url, _) => Container(
        height: height,
        child: Center(
          child: HyperlinkButton(
            onPressed: () {
              setState(() {});
            },
            child: Text(":("),
          ),
        ),
      ),
      fadeOutDuration: widget.fade
          ? const Duration(milliseconds: 1000)
          : Duration.zero,
      fadeInDuration: widget.fade
          ? const Duration(milliseconds: 500)
          : Duration.zero,
      // memCacheWidth: width?.toInt(),
      // memCacheHeight: height?.toInt(),
      imageUrl: url,
      cacheManager: pixivCacheManager,
      height: height,
      width: width,
      fit: fit ?? BoxFit.fitWidth,
      httpHeaders: Hoster.header(url: url),
    );
  }
}

class PixivProvider {
  static ImageProvider url(String url, {String? preUrl}) {
    return CachedNetworkImageProvider(
      url,
      headers: Hoster.header(url: preUrl),
      cacheManager: pixivCacheManager,
    );
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
