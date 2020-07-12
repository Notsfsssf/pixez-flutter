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
import 'package:flutter/widgets.dart';

class PixivImage extends StatelessWidget {
  final String url;
  final String placeHolder;
  final Widget placeWidget;
  PixivImage(this.url, {this.placeHolder, this.placeWidget});

  @override
  Widget build(BuildContext context) {
    if (placeWidget != null) {
      return CachedNetworkImage(
        placeholder: (BuildContext context, String url) {
          return placeWidget;
        },
        imageUrl: url,
        httpHeaders: {
          "referer": "https://app-api.pixiv.net/",
          "User-Agent": "PixivIOSApp/5.8.0"
        },
        fit: BoxFit.fitWidth,
      );
    }
    return placeHolder != null
        ? CachedNetworkImage(
            placeholder: (BuildContext context, String url) {
              return CachedNetworkImage(
                imageUrl: placeHolder,
                httpHeaders: {
                  "referer": "https://app-api.pixiv.net/",
                  "User-Agent": "PixivIOSApp/5.8.0"
                },
                fit: BoxFit.fitWidth,
              );
            },
            imageUrl: url,
            httpHeaders: {
              "referer": "https://app-api.pixiv.net/",
              "User-Agent": "PixivIOSApp/5.8.0"
            },
            fit: BoxFit.fitWidth,
          )
        : CachedNetworkImage(
            imageUrl: url,
            httpHeaders: {
              "referer": "https://app-api.pixiv.net/",
              "User-Agent": "PixivIOSApp/5.8.0"
            },
            placeholder: (context, url) {
              return Container(
                height: 100,
              );
            },
            fit: BoxFit.fitWidth,
          );
  }
}

class PixivProvider {
  static CachedNetworkImageProvider url(String url) {
    return CachedNetworkImageProvider(url, headers: {
      "referer": "https://app-api.pixiv.net/",
      "User-Agent": "PixivIOSApp/5.8.0"
    });
  }
}
