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
import 'package:extended_text/extended_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/painting/inline_span.dart';
import 'package:flutter/src/painting/text_style.dart';
import 'package:pixez/component/pixiv_image.dart';
import 'package:pixez/models/illust.dart';
import 'package:pixez/network/api_client.dart';

//这一堆都是专门给小说特殊约定写的
//[pixivimage:12551-1]
class PixivImageSpan extends ExtendedWidgetSpan {
  final int id;
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

  PixivImageSpan(this.id, this.actualText)
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
                    child: PixivImage(snapshot.data!.imageUrls.medium),
                  );

                return Container();
              }),
        ));
}

class SpecialImageText extends SpecialText {
  static const String flag = '[pixivimage';
  final int? start;

  SpecialImageText(TextStyle textStyle, {this.start})
      : super(SpecialImageText.flag, ']', textStyle);

  @override
  InlineSpan finishText() {
    final String key = toString();
    String now = key.substring(flag.length + 1, key.indexOf("]"));
    int trueId = 0;
    if (now.contains('-')) {
      trueId = int.tryParse(now.split('-').first)!;
    }
    if (int == null) return TextSpan(text: key, style: textStyle);
    return PixivImageSpan(trueId, key);
  }
}

//[[rb:]]
class RbText extends SpecialText {
  RbText(TextStyle textStyle, {this.start})
      : super(ChapterText.flag, ']', textStyle);
  static const String flag = '[[rb:';
  final int? start;

  @override
  InlineSpan finishText() {
    final String key = toString();
    final contentText = key.replaceAll(flag, '').replaceAll(']', '').split('>');
    final resultText = '${contentText.first}(${contentText.last})';
    return TextSpan(text: resultText, style: textStyle);
  }
}

//[chapter]
class ChapterText extends SpecialText {
  ChapterText(TextStyle textStyle, {this.start})
      : super(ChapterText.flag, ']', textStyle);
  static const String flag = '[chapter:';
  final int? start;

  @override
  InlineSpan finishText() {
    final String key = toString();

    return TextSpan(
        text: key.replaceAll(flag, '').replaceAll(']', ''), style: textStyle);
  }
}

//[newpage]
class NextPageSpan extends ExtendedWidgetSpan {
  final String actualText;
  final TextStyle? style;

  NextPageSpan(this.actualText, {this.style})
      : super(
            child: Container(
          child: Center(
            child: Text(
              '',
              style: style,
            ),
          ),
        ));
}

class NextPageText extends SpecialText {
  NextPageText(TextStyle textStyle, {this.start})
      : super(SpecialImageText.flag, ']', textStyle);
  static const String flag = '[newpage';
  final int? start;

  @override
  InlineSpan finishText() {
    return NextPageSpan("下一页", style: textStyle);
  }
}

class NovelSpecialTextSpanBuilder extends SpecialTextSpanBuilder {
  NovelSpecialTextSpanBuilder();

  @override
  TextSpan build(String data,
      {TextStyle? textStyle, SpecialTextGestureTapCallback? onTap}) {
    return super.build(data, textStyle: textStyle, onTap: onTap);
  }

  @override
  SpecialText? createSpecialText(String flag,
      {TextStyle? textStyle,
      SpecialTextGestureTapCallback? onTap,
      int? index}) {
    if (flag == null || flag == '') {
      return null;
    }
    if (isStart(flag, NextPageText.flag)) {
      return NextPageText(textStyle!,
          start: index! - (NextPageText.flag.length - 1));
    }
    if (isStart(flag, ChapterText.flag)) {
      return ChapterText(
          textStyle!.copyWith(fontSize: 16.0, fontWeight: FontWeight.bold),
          start: index! - (NextPageText.flag.length - 1));
    }
    if (isStart(flag, SpecialImageText.flag)) {
      return SpecialImageText(textStyle!,
          start: index! - (SpecialImageText.flag.length - 1));
    }
    if (isStart(flag, RbText.flag)) {
      return RbText(textStyle!, start: index! - (RbText.flag.length - 1));
    }
    return null;
  }
}
