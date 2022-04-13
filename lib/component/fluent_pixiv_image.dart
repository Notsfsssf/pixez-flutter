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
import 'package:flutter/material.dart';
import 'package:pixez/component/pixiv_image.dart';
import 'package:pixez/er/hoster.dart';


class FluentPixivImage extends StatefulWidget {
  final String url;
  final Widget? placeWidget;
  final bool fade;
  final BoxFit? fit;
  final bool? enableMemoryCache;
  final double? height;
  final double? width;
  final String? host;

  FluentPixivImage(this.url,
      {this.placeWidget,
      this.fade = true,
      this.fit,
      this.enableMemoryCache,
      this.height,
      this.host,
      this.width});

  @override
  _FluentPixivImageState createState() => _FluentPixivImageState();
}

class _FluentPixivImageState extends State<FluentPixivImage> {
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
  void didUpdateWidget(covariant FluentPixivImage oldWidget) {
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
    return CachedNetworkImage(
        placeholder: (context, url) =>
            widget.placeWidget ?? Container(height: height),
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
        fadeOutDuration:
            widget.fade ? const Duration(milliseconds: 1000) : null,
        // memCacheWidth: width?.toInt(),
        // memCacheHeight: height?.toInt(),
        imageUrl: url,
        cacheManager: pixivCacheManager,
        height: height,
        width: width,
        fit: fit ?? BoxFit.fitWidth,
        httpHeaders: Hoster.header(url: url));
  }
}
