import 'package:cached_network_image/cached_network_image.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:pixez/component/pixiv_image.dart';
import 'package:pixez/er/hoster.dart';

class FluentPixivImageState extends PixivImageStateBase {
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
