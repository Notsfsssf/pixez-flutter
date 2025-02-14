import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:pixez/component/pixiv_image.dart';
import 'package:pixez/constants.dart';
import 'package:pixez/main.dart';
import 'package:pixez/models/illust.dart';

final hIsNotAllowedImage = Container(
  color: Colors.white,
  child: Image.asset(Constants.no_h),
);

class PixivImageShielded extends StatefulWidget {
  final String url;
  final List<Tags> tags;
  final Widget? placeWidget;
  final bool fade;
  final BoxFit? fit;
  final bool? enableMemoryCache;
  final double? height;
  final double? width;
  final String? host;

  PixivImageShielded(
    this.url, {
    required this.tags,
    this.placeWidget,
    this.fade = true,
    this.fit,
    this.enableMemoryCache,
    this.height,
    this.host,
    this.width,
  });

  @override
  State<PixivImageShielded> createState() => _PixivImageShieldedState();
}

class _PixivImageShieldedState extends State<PixivImageShielded> {
  late PixivImage? _pixivImage = null;
  @override
  Widget build(BuildContext context) {
    return Observer(
      builder: (_) {
        if (userSetting.hIsNotAllow) {
          if (widget.tags.any((tag) => tag.name.startsWith('R-18'))) {
            return hIsNotAllowedImage;
          }
        }
        if (_pixivImage == null) {
          _pixivImage = PixivImage(
            widget.url,
            placeWidget: widget.placeWidget,
            fade: widget.fade,
            fit: widget.fit,
            enableMemoryCache: widget.enableMemoryCache,
            height: widget.height,
            width: widget.width,
            host: widget.host,
          );
        }
        return _pixivImage ?? Container();
      },
    );
  }
}
