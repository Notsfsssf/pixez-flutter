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

import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:http/http.dart';
import 'package:http/io_client.dart';
import 'package:http_interceptor/http/interceptor_contract.dart';
import 'package:http_interceptor/http_interceptor.dart';
import 'package:pixez/er/hoster.dart';
import 'package:pixez/er/lprinter.dart';
import 'package:pixez/exts.dart';
import 'package:pixez/main.dart';

const ImageHost = "i.pximg.net";
const ImageCatHost = "i.pixiv.re";
const ImageSHost = "s.pximg.net";

class PixivHostInterceptor implements InterceptorContract {
  @override
  Future<RequestData> interceptRequest({required RequestData data}) async {
    data.baseUrl = data.baseUrl.toTrueUrl();
    LPrinter.d("i===${data.baseUrl}==i");
    return data;
  }

  @override
  Future<ResponseData> interceptResponse({required ResponseData data}) async {
    if (data.statusCode != 200) {
      splashStore.maybeFetch();
    }
    return data;
  }
}

class CustomCacheManager {
  static const key = 'pixiv_image_cache';
  static Client client = InterceptedClient.build(
      interceptors: [
        PixivHostInterceptor(),
      ],
      client: IOClient(HttpClient()
        ..badCertificateCallback =
            (X509Certificate cert, String host, int port) => true));
  static CacheManager instance = CacheManager(
    Config(
      key,
      repo: JsonCacheInfoRepository(databaseName: key),
      fileService: HttpFileService(httpClient: client),
    ),
  );
}

CacheManager get pixivCacheManager => CustomCacheManager.instance;

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
      });
    }
  }

  @override
  void dispose() {
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
        imageUrl: url,
        cacheManager: pixivCacheManager,
        height: height,
        width: width,
        fit: fit ?? BoxFit.fitWidth,
        httpHeaders: Hoster.header(url: url));
  }
}

class PixivProvider {
  static CachedNetworkImageProvider url(String url, {String? preUrl}) {
    return CachedNetworkImageProvider(url,
        headers: Hoster.header(url: preUrl), cacheManager: pixivCacheManager);
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
