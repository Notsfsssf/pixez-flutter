import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class PixivImage extends StatelessWidget {
  final String url;
  final String placeHolder;
  PixivImage(this.url, {this.placeHolder});

  @override
  Widget build(BuildContext context) {
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

class PixivProvider extends CachedNetworkImageProvider {
  PixivProvider(String url)
      : super(url, headers: {
          "referer": "https://app-api.pixiv.net/",
          "User-Agent": "PixivIOSApp/5.8.0"
        });
}
