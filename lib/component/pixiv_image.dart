import 'package:flutter/widgets.dart';
import 'package:cached_network_image/cached_network_image.dart';

class PixivImage extends StatelessWidget {
  final String url;
  final String placeHolder;

  PixivImage(this.url, {this.placeHolder});

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return CachedNetworkImage(
      placeholder: placeHolder != null
          ? (BuildContext context, String url) {
              return CachedNetworkImage(
                imageUrl: placeHolder,
                httpHeaders: {
                  "referer": "https://app-api.pixiv.net/",
                  "User-Agent": "PixivIOSApp/5.8.0"
                },
                fit: BoxFit.fitWidth,
              );
            }
          : null,
      imageUrl: url,
      httpHeaders: {
        "referer": "https://app-api.pixiv.net/",
        "User-Agent": "PixivIOSApp/5.8.0"
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
