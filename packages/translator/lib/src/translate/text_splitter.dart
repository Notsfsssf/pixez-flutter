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
 * this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 */

/// 长文本切块：把一段超出模型单次处理能力的文本按行 / 句末标点切开。
///
/// 为什么必须切：端侧 4096 上下文里，源文本 + 输出共用一个预算；云端
/// 接口也各有 max_tokens。整段几千字时有两种失败方式——
/// ① prompt 超上下文，引擎直接报错；② 输出被 maxNewTokens 截断，校验
/// 判成不合格后返回 null。两者在 UI 上都是「这一段没有译出内容」。
library;

import 'dart:math' as math;

/// 单块默认字数上限。
///
/// 320 是折中：中文/日文约 1 字 ≈ 1 token，320 字的输出仍在 512 token
/// 预算内；再小会让长段落切成太多块、请求数暴涨。
const int kDefaultMaxPieceChars = 320;

/// 句末标点（用于尽量不把一句话劈成两半）。
const String _kSentenceEnders = '。！？!?；;';

/// 按空行 / 换行 / 句末标点切块，单块不超过 [maxChars] 个字符。
List<String> splitTextForModel(
  String text, {
  int maxChars = kDefaultMaxPieceChars,
}) {
  final pieces = <String>[];
  final buffer = StringBuffer();
  void flush() {
    final s = buffer.toString().trim();
    if (s.isNotEmpty) pieces.add(s);
    buffer.clear();
  }

  for (final rawLine in text.split(RegExp(r'\r\n|\n|\r'))) {
    final line = rawLine.trim();
    if (line.isEmpty) {
      flush();
      continue;
    }
    if (line.length > maxChars) {
      flush();
      pieces.addAll(_splitLongLine(line, maxChars));
      continue;
    }
    if (buffer.isNotEmpty && buffer.length + 1 + line.length > maxChars) {
      flush();
    }
    if (buffer.isNotEmpty) buffer.write('\n');
    buffer.write(line);
  }
  flush();
  return pieces;
}

/// 把切开的译文拼回一段。
///
/// 中文/日文句末直接拼接；拉丁文补一个空格，避免 "end.Next" 这种粘连。
String joinTranslatedPieces(List<String> pieces) {
  if (pieces.isEmpty) return '';
  final buffer = StringBuffer(pieces.first);
  for (var i = 1; i < pieces.length; i++) {
    final current = buffer.toString();
    final lastChar = current.isEmpty ? '' : current[current.length - 1];
    final needsSpace = !'。！？；：、，」』）…!?;:,.”’'.contains(lastChar);
    if (needsSpace) buffer.write(' ');
    buffer.write(pieces[i]);
  }
  return buffer.toString();
}

List<String> _splitLongLine(String line, int maxChars) {
  final out = <String>[];
  var start = 0;
  while (start < line.length) {
    final end = math.min(start + maxChars, line.length);
    if (end >= line.length) {
      out.add(line.substring(start));
      break;
    }
    var cut = end;
    // 在窗口后半段找句末标点，尽量不把一句话劈成两半。
    for (var i = end - 1; i > start + maxChars ~/ 2; i--) {
      if (_kSentenceEnders.contains(line[i])) {
        cut = i + 1;
        break;
      }
    }
    out.add(line.substring(start, cut));
    start = cut;
  }
  return out;
}
