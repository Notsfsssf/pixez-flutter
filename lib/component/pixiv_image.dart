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
import 'package:dio/dio.dart';
import 'package:dio_compatibility_layer/dio_compatibility_layer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager_dio/flutter_cache_manager_dio.dart';

import 'package:pixez/er/hoster.dart';
import 'package:pixez/er/illust_cacher.dart';
import 'package:pixez/er/pixiv_image_source.dart';
import 'package:pixez/main.dart';
import 'package:pixez/network/pixez_network_settings.dart';
import 'package:rhttp/rhttp.dart' as r;

const ImageHost = "i.pximg.net";
const ImageCatHost = "i.pixiv.re";
const ImageSHost = "s.pximg.net";

// 注意，stable的http_interceptor这里是无效的，因为实现send是todo
// 实现CacheManager和混入ImageCacheManager缺一不可
// 如果你恰好看到这个实现方法实例，且对你有些帮助或者启发：
// 听一首Mili-Salt, Pepper, Birds, And the Thought Police吧 🎵

DioCacheManager? pixivCacheManager = DioCacheManager.instance;

class PixEzCacheHeaderData {
  final String key;
  final IllustQuality quality;

  PixEzCacheHeaderData({required this.key, required this.quality});
}

class PixivImage extends StatefulWidget {
  final String url;
  final Widget? placeWidget;
  final bool fade;
  final BoxFit? fit;
  final bool? enableMemoryCache;
  final double? height;
  final double? width;
  final String? host;
  final PixEzCacheHeaderData? cacheHeaderData;

  PixivImage(
    this.url, {
    this.placeWidget,
    this.fade = true,
    this.fit,
    this.enableMemoryCache,
    this.height,
    this.host,
    this.width,
    this.cacheHeaderData,
  });

  @override
  _PixivImageState createState() => _PixivImageState();

  static Dio? _cacheDio;

  static Future<void> generatePixivCache() async {
    final client = await r.RhttpCompatibleClient.createSync(
      settings: PixezNetworkSettings.forImages(
        userSetting.pictureSource,
        userSetting.networkMode,
      ),
    );
    final existing = _cacheDio;
    if (existing != null) {
      existing.httpClientAdapter = ConversionLayerAdapter(client);
      return;
    }
    final dio = Dio();
    dio.interceptors.add(
      PixivImageSourceInterceptor(
        networkMode: () => userSetting.networkMode,
        pictureSource: () => userSetting.pictureSource,
      ),
    );
    dio.httpClientAdapter = ConversionLayerAdapter(client);
    _cacheDio = dio;
    DioCacheManager.initialize(dio);
  }
}

class PixivImageInterceptor extends Interceptor {
  static String cacheKey = 'cache_key';
  static String cacheQualityKey = 'cache_quality';
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    super.onRequest(options, handler);
    if (options.headers.containsKey(cacheKey)) {
      final key = options.headers[cacheKey] as String?;
      final quality = options.headers[cacheQualityKey] as String?;
      options.headers.remove(cacheKey);
      if (key != null && quality != null) {
        options.extra[cacheKey] = key;
        options.extra[cacheQualityKey] = quality;
      }
    }
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    super.onResponse(response, handler);
    final extra = response.extra;
    if (extra.containsKey(cacheKey)) {
      final key = extra[cacheKey] as String?;
      final quality = int.tryParse(extra[cacheQualityKey] as String? ?? '');
      if (key != null && quality != null) {
        IllustCacher.saveCacheIllustQuality(
          key,
          IllustQualityExtension.fromValue(quality),
          response.realUri.toString(),
        );
      }
    }
    handler.next(response);
  }
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
      placeholder: (context, url) =>
          widget.placeWidget ??
          Container(
            height: height,
            child: Center(
              child: SizedBox(
                width: size,
                height: size,
                child: const Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: const CircularProgressIndicator(),
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
                    child: CircularProgressIndicator(value: progress.progress),
                  ),
                ),
              ),
            )
          : null,
      errorWidget: (context, url, _) => Container(
        height: height,
        child: Center(
          child: TextButton(
            onPressed: () {
              setState(() {});
            },
            child: Text(":("),
          ),
        ),
      ),
      fadeOutDuration: widget.fade ? const Duration(milliseconds: 1000) : null,
      // memCacheWidth: width?.toInt(),
      // memCacheHeight: height?.toInt(),
      imageUrl: url,
      cacheManager: pixivCacheManager,
      height: height,
      width: width,
      fit: fit ?? BoxFit.fitWidth,
      httpHeaders: {...Hoster.header(url: url)},
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
