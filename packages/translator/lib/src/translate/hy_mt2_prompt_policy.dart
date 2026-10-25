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

/// Hy-MT2 官方 prompt 模板构建（移植自参考 HyMt2PromptPolicy.kt，逐条对齐语义）。
library;

import '../model/translate_request.dart';

/// 由 Tencent Hy-MT2 模型官方模板构建 prompt。
abstract final class HyMt2PromptPolicy {
  /// 官方语言名表（38 项，官方英文名）。
  static const Map<String, String> officialLanguageNames = {
    'zh': 'Chinese',
    'en': 'English',
    'fr': 'French',
    'pt': 'Portuguese',
    'es': 'Spanish',
    'ja': 'Japanese',
    'tr': 'Turkish',
    'ru': 'Russian',
    'ar': 'Arabic',
    'ko': 'Korean',
    'th': 'Thai',
    'it': 'Italian',
    'de': 'German',
    'vi': 'Vietnamese',
    'ms': 'Malay',
    'id': 'Indonesian',
    'tl': 'Filipino',
    'hi': 'Hindi',
    'zh-hant': 'Traditional Chinese',
    'pl': 'Polish',
    'cs': 'Czech',
    'nl': 'Dutch',
    'km': 'Khmer',
    'my': 'Burmese',
    'fa': 'Persian',
    'gu': 'Gujarati',
    'ur': 'Urdu',
    'te': 'Telugu',
    'mr': 'Marathi',
    'he': 'Hebrew',
    'bn': 'Bengali',
    'ta': 'Tamil',
    'uk': 'Ukrainian',
    'bo': 'Tibetan',
    'kk': 'Kazakh',
    'mn': 'Mongolian',
    'ug': 'Uyghur',
    'yue': 'Cantonese',
  };

  /// Hy-MT2 对话模板标记。
  ///
  /// 取自模型 GGUF 的 `tokenizer.chat_template`，注意竖线是全角 U+FF5C、
  /// 下划线是 U+2581，不是 ASCII。曾因只传裸文本（无轮次标记）导致模型
  /// 判不出「该收尾了」，每段一路续写到 max_tokens：真机实测 4 段各跑满
  /// 256 token、单批 68 秒，且末尾出现大段重复。
  ///
  /// BOS（`<｜hy_begin▁of▁sentence｜>`）由 tokenizer 的 add_special 自动
  /// 添加，这里只补 user/assistant 轮次边界。
  static const String userTurnStart = '<\uFF5Chy_User\uFF5C>';
  static const String assistantTurnStart = '<\uFF5Chy_Assistant\uFF5C>';

  /// 构建完整 user prompt：`glossaryPrefix + translationPrompt`。
  static String build(
    String source,
    String targetLang,
    RuntimePromptContext context,
  ) {
    final targetLanguage = targetLanguageName(targetLang);
    final glossary = glossaryPrefix(context);
    final background = backgroundInformation(source, context);
    final String translationPrompt;
    if (background.isEmpty) {
      final outputConstraint = glossary.isEmpty
          ? 'Note that you should only output the translated result without any additional explanation:'
          : 'Note that you must ONLY output the translated result without any additional explanation:';
      translationPrompt =
          'Translate the following text into $targetLanguage. $outputConstraint\n'
          '$source';
    } else {
      translationPrompt =
          '[Background Information]\n'
          '$background\n'
          'Please translate the following text into $targetLanguage, '
          'taking the provided background information into consideration.\n'
          '[Source Text]\n'
          '$source';
    }
    return '$userTurnStart$glossary$translationPrompt$assistantTurnStart';
  }

  /// 去背景重试 prompt：背景三段置空、术语表保留（规格 §6.1）。
  static String buildWithoutBackground(
    String source,
    String targetLang,
    RuntimePromptContext context,
  ) => build(source, targetLang, context.withoutBackground());

  /// 判定 prompt 是否为背景模式（同时含两个 header，与参考实现一致）。
  static bool isBackgroundPrompt(String prompt) =>
      prompt.contains('[Background Information]\n') &&
      prompt.contains('[Source Text]\n');

  /// 归一化目标语言：trim 后为空或 `auto` → `zh-CN`；`_` → `-`。
  static String normalizeTargetLang(String targetLang) {
    final normalized = targetLang.trim();
    if (normalized.isEmpty || normalized.toLowerCase() == 'auto') {
      return 'zh-CN';
    }
    return normalized.replaceAll('_', '-');
  }

  /// 目标语言的官方英文名。
  ///
  /// 优先级：繁中/简中别名 → 全名表 → 主语言（`-` 前段）→ 原串兜底。
  /// （参考实现还有一层 `Locale.getDisplayLanguage` 兜底，Dart 无此 API，
  /// 直接退化为原串，见交付说明。）
  static String targetLanguageName(String targetLang) {
    final normalized = normalizeTargetLang(targetLang);
    final normalizedLower = normalized.toLowerCase();
    return switch (normalizedLower) {
      'zh-tw' || 'zh-hk' || 'zh-mo' || 'zh-hant' => 'Traditional Chinese',
      'zh' || 'zh-cn' || 'zh-sg' || 'zh-hans' => 'Chinese',
      _ =>
        officialLanguageNames[normalizedLower] ??
            officialLanguageNames[normalizedLower.split('-').first] ??
            normalized,
    };
  }

  /// 术语表前缀：`Reference the following translations:\n…\n\n`；
  /// 无有效术语返回空串。
  static String glossaryPrefix(RuntimePromptContext context) {
    final terms = <String>[];
    for (final term in context.glossary) {
      final source = toInlineText(term.source);
      final target = toInlineText(term.target);
      if (source.isEmpty || target.isEmpty) continue;
      terms.add('$source translates to $target');
    }
    if (terms.isEmpty) return '';
    return 'Reference the following translations:\n'
        '${terms.join('\n')}\n\n';
  }

  /// 背景三段（Current application / Previous dialogue / Other text on the
  /// current page），以空行连接；全空返回空串。
  static String backgroundInformation(
    String activeSource,
    RuntimePromptContext context,
  ) {
    final sections = <String>[];
    final app = context.currentApplication == null
        ? null
        : toInlineText(context.currentApplication!);
    if (app != null && app.isNotEmpty) {
      sections.add('Current application: $app');
    }

    final previousTurns = <String>[];
    for (final turn in context.previousFrame) {
      final source = turn.source.trim();
      if (source.isEmpty) continue;
      final translation = turn.translation?.trim();
      final buffer = StringBuffer('Source: $source');
      if (translation != null && translation.isNotEmpty) {
        buffer.write('\nTranslation: $translation');
      }
      previousTurns.add(buffer.toString());
    }
    if (previousTurns.isNotEmpty) {
      sections.add('Previous dialogue:\n${previousTurns.join('\n\n')}');
    }

    final otherCurrentSources = withoutFirstActiveSource(
      context.currentPage,
      activeSource,
    );
    if (otherCurrentSources.isNotEmpty) {
      sections.add(
        'Other text on the current page:\n'
        '${otherCurrentSources.join('\n')}',
      );
    }
    return sections.join('\n\n');
  }

  /// 移除「第一个与当前 active source 相同」的候选；空串一律丢弃。
  static List<String> withoutFirstActiveSource(
    List<String> candidates,
    String activeSource,
  ) {
    final active = activeSource.trim();
    var removed = false;
    final result = <String>[];
    for (final candidate in candidates) {
      final trimmed = candidate.trim();
      if (trimmed.isEmpty) continue;
      if (!removed && trimmed == active) {
        removed = true;
        continue;
      }
      result.add(trimmed);
    }
    return result;
  }

  /// 行内文本：trim → 换行折叠为空格 → 连续空白折叠为单空格。
  static String toInlineText(String input) => input
      .trim()
      .replaceAll(RegExp(r'[\r\n]+'), ' ')
      .replaceAll(RegExp(r'\s{2,}'), ' ');
}
