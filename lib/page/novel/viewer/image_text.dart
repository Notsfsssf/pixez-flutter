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

import 'package:dio/dio.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:pixez/component/pixiv_image.dart';
import 'package:pixez/er/lprinter.dart';
import 'package:pixez/i18n.dart';
import 'package:pixez/models/illust.dart';
import 'package:pixez/network/api_client.dart';
import 'package:url_launcher/url_launcher.dart';

//这一堆都是专门给小说特殊约定写的
//[pixivimage:12551-1]
class PixivImageSpan extends WidgetSpan {
  final int id;
  final int targetIndex;
  final String actualText;

  static Future<Illusts?> _getData(int id) async {
    try {
      Response response = await apiClient.getIllustDetail(id);
      final result = Illusts.fromJson(response.data['illust']);
      return result;
    } catch (e) {
      print(e);
    }
    return null;
  }

  PixivImageSpan(this.id, this.targetIndex, this.actualText)
      : super(
            child: Container(
          child: FutureBuilder(
              future: _getData(id),
              builder:
                  (BuildContext context, AsyncSnapshot<Illusts?> snapshot) {
                if (snapshot.connectionState == ConnectionState.done &&
                    snapshot.data != null)
                  return Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: targetIndex != 0
                        ? PixivImage(snapshot
                            .data!.metaPages[targetIndex].imageUrls!.medium)
                        : PixivImage(snapshot.data!.imageUrls.medium),
                  );

                return Container();
              }),
        ));
}

// (newpage)
// [chapter:本章标题]
// [pixlvimage:作品1]
// [jump:链接目标的页面編号]
// [[jumpuri:标题 ＞ 链接目标的URL]]
// [[rb:汉宇＞假名]]
class NovelSpansGenerator {

   //🎵 Low Roar - "I'll Keep Coming"
  List<InlineSpan> buildSpans(BuildContext context, String source) {
    try {
      String nowStr = '';
      bool spanCollectStart = false;
      List<InlineSpan> result = [];
      for (var i = 0; i < source.length; i++) {
        final posStr = source[i];
        if (posStr == '[') {
          if (nowStr.isNotEmpty) {
            if (nowStr == '[') {
              spanCollectStart = true;
              nowStr += posStr;
            } else {
              result.add(TextSpan(text: nowStr));
              nowStr = posStr;
              spanCollectStart = true;
            }
          }
        } else if (posStr == ']') {
          if (nowStr.startsWith("[[")) {
            if (nowStr.endsWith("]")) {
              spanCollectStart = false;
              nowStr += posStr;
              result.add(_parseText(context, nowStr));
              nowStr = '';
            } else {
              nowStr += posStr;
            }
          } else {
            spanCollectStart = false;
            nowStr += posStr;
            result.add(_parseText(context, nowStr));
            nowStr = '';
          }
        } else if (spanCollectStart) {
          nowStr += posStr;
        } else {
          nowStr += posStr;
        }
      }
      if (nowStr.isNotEmpty) {
        result.add(TextSpan(text: nowStr));
      }
      print(result);
      return result;
    } catch (e) {
      print(e);
    }
    return [TextSpan(text: source)];
  }

  RegExp linkRegex = RegExp(r'https?://\S+');

  InlineSpan _parseText(BuildContext context, String spanStr) {
    if (spanStr.startsWith('[newpage]')) {
      return WidgetSpan(
          child: Container(
        child: Center(
          child: Text(''),
        ),
      ));
    } else if (spanStr.startsWith('[chapter:')) {
      final title = spanStr.replaceAll('[chapter:', '').replaceAll(']', '');
      return TextSpan(text: title);
    } else if (spanStr.startsWith('[pixivimage:')) {
      final String key = spanStr;
      final flag = '[pixivimage:';
      String now = key.substring(flag.length, key.indexOf("]"));
      int trueId = 0;
      int targetIndex = 0;
      if (now.contains('-')) {
        trueId = int.tryParse(now.split('-').first)!;
        targetIndex = int.tryParse(now.split('-').last)!;
      }
      return PixivImageSpan(trueId, targetIndex, key);
    } else if (spanStr.startsWith('[[jumpuri:')) {
      final String key = spanStr.toString();
      final flag = '[[jumpuri:';
      LPrinter.d(key);
      String now = key.substring(flag.length, key.indexOf("]"));
      Iterable<RegExpMatch> matches = linkRegex.allMatches(now);
      final matchLink = matches.firstOrNull;
      if (matchLink != null) {
        final link = matchLink.group(0);
        if (link != null) {
          final uri = Uri.tryParse(link);
          if (uri != null && uri.host.contains("pixiv.net")) {
            return TextSpan(
                text: now.split(">").firstOrNull ?? "",
                style: TextStyle(color: Theme.of(context).colorScheme.primary),
                recognizer: TapGestureRecognizer()
                  ..onTap = () async {
                    final open = await showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: Text("External link"),
                            content: SelectionArea(child: Text(link)),
                            actions: [
                              TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop("open");
                                  },
                                  child: Text("Open")),
                              TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  child: Text(I18n.of(context).cancel))
                            ],
                          );
                        });
                    if (open == "open") {
                      launch(link);
                    }
                  });
          }
        }
        return TextSpan(text: now);
      } else {
        return TextSpan(text: now);
      }
    } else if (spanStr.startsWith('[[rb:')) {
      final String key = spanStr.toString();
      final flag = '[[rb:';
      final contentText =
          key.replaceAll(flag, '').replaceAll(']', '').split('>');
      final resultText = '${contentText.first}(${contentText.last})';
      return TextSpan(text: resultText);
    } else {
      return TextSpan(text: spanStr);
    }
  }
}
