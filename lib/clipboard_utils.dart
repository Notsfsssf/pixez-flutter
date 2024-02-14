import 'dart:async';
import 'dart:ui';

import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/widgets.dart' hide Image;
import 'package:pixez/component/pixiv_image.dart';
import 'package:pixez/i18n.dart';
import 'package:pixez/models/illust.dart';
import 'package:super_clipboard/super_clipboard.dart';

class ClipboardUtils {
  static SystemClipboard? _clipboard = SystemClipboard.instance;
  static bool get supported => _clipboard != null;

  static String? getImageUrl(Illusts illusts, int index) {
    // TODO: 使用图片质量设置
    if (illusts.pageCount == 1) {
      return illusts.metaSinglePage?.originalImageUrl;
    } else {
      return illusts.metaPages[index].imageUrls?.original;
    }
  }

  static Future<void> showToast(BuildContext context, Future future) async {
    // TODO: 这里的本地化提示需要修改
    BotToast.showText(text: I18n.of(context).copy);
    await future;
    BotToast.showText(text: I18n.of(context).copied_to_clipboard);
  }

  /// 从图片链接中加载图片并复制到剪贴板
  static Future<void> copyImage(String url) async {
    final image = await _getImageFromUrl(url);
    final data = await image.toByteData(format: ImageByteFormat.png);
    if (data == null) return; // 失败

    final item = DataWriterItem();
    item.add(Formats.png.lazy(() => data.buffer.asUint8List()));
    await _clipboard?.write([item]);
  }

  /// 下载或从缓存中加载图片
  static Future<Image> _getImageFromUrl(String url) async {
    final completer = Completer<Image>();
    ImageStreamListener listener;
    final provider = PixivProvider.url(url);
    final stream = provider.resolve(ImageConfiguration.empty);
    listener = ImageStreamListener((ImageInfo frame, bool sync) {
      completer.complete(frame.image); //完成
    });
    stream.addListener(listener); //添加监听
    final img = await completer.future;
    stream.removeListener(listener);
    return img;
  }
}
