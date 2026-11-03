import 'dart:convert';

import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/widgets.dart';
import 'package:pixez/exts.dart';
import 'package:pixez/models/novel_web_response.dart';
import 'package:pixez/network/api_client.dart';
import 'package:pixez/page/novel/viewer/novel_store.dart';
import 'package:pixez/utils/novel_save_target.dart';

/// 小说一键保存：拉正文 -> 直接写入「小说保存位置」（默认 Download/PixEz）/<标题>.txt
/// 不写入阅读历史，也不触发 NovelStore 的其它副作用。
class NovelQuickSave {
  static Future<void> save(
    BuildContext context,
    int id, {
    String? title,
  }) async {
    BotToast.showText(text: "正在保存…");
    try {
      final response = await apiClient.webviewNovel(id);
      final json = parseNovelJsonFromHtml(response.data);
      if (json == null) {
        throw FormatException("无法解析正文");
      }
      final web = NovelWebResponse.fromJson(jsonDecode(json));
      final text = web.text;
      if (text.trim().isEmpty) {
        throw FormatException("正文为空");
      }
      final name = "${(title ?? "novel_$id").trim().toLegal()}.txt";
      final path = await NovelSaveTarget.save(name, "text/plain", text);
      if (path == null) {
        throw FormatException("写入失败");
      }
      BotToast.showText(text: "已保存：$path");
    } catch (e) {
      BotToast.showText(text: "保存失败：$e");
    }
  }
}
