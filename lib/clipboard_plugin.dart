import 'dart:async';
import 'dart:io';

import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:pixez/component/pixiv_image.dart';
import 'package:pixez/er/hoster.dart';
import 'package:pixez/i18n.dart';
import 'package:pixez/main.dart';
import 'package:pixez/models/illust.dart';

class ClipboardPlugin {
  static final supported = Platform.isWindows;
  static const _platform = const MethodChannel('com.perol.dev/clipboard');

  static Future<void> copyImageFromByteArray(Uint8List data) =>
      _platform.invokeMethod("copyImageFromByteArray", {"data": data});

  static Future<void> copy(
    BuildContext context,
    Illusts illusts,
    int index,
  ) async {
    final url = _getImageUrl(illusts, index);
    assert(url != null);

    // TODO: i18n
    BotToast.showText(text: 'Copying to clipboard...');
    try {
      final image = await _downloadImage(url!);

      await copyImageFromByteArray(image);

      BotToast.showText(text: I18n.of(context).copied_to_clipboard);
    } catch (e) {
      debugPrint(e.toString());
      BotToast.showText(text: e.toString());
    }
  }

  static Future<Uint8List> _downloadImage(String url) async {
    assert(pixivCacheManager != null);

    final image =
        await pixivCacheManager!.getFileFromCache(url) ??
        await pixivCacheManager!.downloadFile(
          url,
          authHeaders: Hoster.header(),
        );

    return await image.file.readAsBytes();
  }

  static String? _getImageUrl(Illusts illusts, int index) {
    final loadSource = userSetting.zoomQuality == 1;
    if (illusts.pageCount == 1) {
      return loadSource
          ? illusts.metaSinglePage?.originalImageUrl
          : illusts.imageUrls.large;
    } else {
      return loadSource
          ? illusts.metaPages[index].imageUrls?.original
          : illusts.metaPages[index].imageUrls?.large;
    }
  }
}
