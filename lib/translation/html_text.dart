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

/// caption / 评论的轻量 HTML 纯文本化。
///
/// Pixiv 的简介是 HTML（`<br />`、`<a>`、`<img>` 占位），直接塞给模型既浪费
/// 上下文，又容易把标签原样译进译文。简介翻译入口和推荐卡片都只需要「读得懂
/// 的正文」，所以抽成一处，避免两边正则漂移。
library;

/// 去掉 HTML 标签与常见实体，保留换行。
String stripHtmlToText(String input) {
  if (!input.contains('<')) return input;
  var text = input
      .replaceAll(RegExp(r'<br\s*/?>', caseSensitive: false), '\n')
      .replaceAll(RegExp(r'</p\s*>', caseSensitive: false), '\n\n')
      .replaceAll(RegExp(r'<[^>]+>'), '');
  text = text
      .replaceAll('&nbsp;', ' ')
      .replaceAll('&amp;', '&')
      .replaceAll('&lt;', '<')
      .replaceAll('&gt;', '>')
      .replaceAll('&quot;', '"')
      .replaceAll('&#39;', "'");
  return text.trim();
}
