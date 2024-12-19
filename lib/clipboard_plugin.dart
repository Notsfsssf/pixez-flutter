import 'dart:async';
import 'dart:io';

import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:pixez/component/pixiv_image.dart';
import 'package:pixez/i18n.dart';
import 'package:pixez/main.dart';
import 'package:pixez/models/illust.dart';

class ClipboardPlugin {
  static final supported = Platform.isWindows;
  static const _platform = const MethodChannel('com.perol.dev/clipboard');

  static String? getImageUrl(Illusts illusts, int index) {
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

  static Future<void> showToast(BuildContext context, Future future) async {
    // TODO: 这里的本地化提示需要修改
    BotToast.showText(text: I18n.of(context).copy);
    await future;
    BotToast.showText(text: I18n.of(context).copied_to_clipboard);
  }

  /// 从图片链接中加载图片并复制到剪贴板
  static Future<void> copyImageFromUrl(String url) async {
    final imageFile = await _getImagePathFromUrl(url);
    await _platform.invokeMethod("copyImageFromPath", {"path": imageFile.path});
  }

  /// 下载或从缓存中加载图片
  static Future<File> _getImagePathFromUrl(String url) async {
    final image = await pixivCacheManager!.getFileFromCache(url) ??
        await pixivCacheManager!.downloadFile(url);

    return image.file;
  }
}
