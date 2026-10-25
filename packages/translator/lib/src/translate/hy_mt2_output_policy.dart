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

/// Hy-MT2 输出校验：拒绝 prompt / 上下文渗透（移植自参考 HyMt2OutputPolicy.kt）。
///
/// 9 类拒绝见 [OutputReason]；全部检测在 NFKC 归一化后的文本上进行
/// （NFKC 由逐码点映射近似实现，见 nfkc_table.dart）。
library;

import 'letter_ranges.dart';
import 'nfkc_table.dart';

/// 行数超限哨兵（参考 LlamaMultiSequence.LINE_LIMIT_SENTINEL）。
const String lineLimitSentinel = '<|gameocr_line_limit|>';

/// token 超限哨兵（参考 LlamaMultiSequence.TOKEN_LIMIT_SENTINEL）。
const String tokenLimitSentinel = '<|gameocr_token_limit|>';

/// 校验拒绝原因（9 类，名称与参考实现一致）。
enum OutputReason {
  MULTI_SECTION_ECHO,
  BACKGROUND_HEADER_ECHO,
  SOURCE_HEADER_ECHO,
  TRANSLATION_INSTRUCTION_ECHO,
  MULTI_ITEM_OUTPUT,
  UNEXPECTED_ITEM_PREFIX,
  PUNCTUATION_SOURCE_EXPANSION,
  SHORT_SOURCE_CONTEXT_EXPANSION,
  NATIVE_LINE_LIMIT,
}

/// 校验结论。
sealed class OutputDecision {
  const OutputDecision();
}

class OutputAccept extends OutputDecision {
  const OutputAccept();

  @override
  bool operator ==(Object other) => other is OutputAccept;

  @override
  int get hashCode => 'OutputAccept'.hashCode;
}

class OutputReject extends OutputDecision {
  final OutputReason reason;

  const OutputReject(this.reason);

  @override
  bool operator ==(Object other) =>
      other is OutputReject && other.reason == reason;

  @override
  int get hashCode => Object.hash('OutputReject', reason);

  @override
  String toString() => 'OutputReject(${reason.name})';
}

/// Hy-MT2 输出策略（纯静态）。
abstract final class HyMt2OutputPolicy {
  static const int _shortSourceExpansionMultiplier = 8;
  static const int _shortSourceExpansionAllowance = 8;

  /// 列表项前缀（用于「源是否本身是列表」的判定）。
  static final RegExp _itemPrefix = RegExp(r'^\s*(?:\d{1,3}[.)、．:：]|[-*•])\s+');

  /// 单行列表前缀剥离（含全角数字与全角分隔符）。
  static final RegExp _singleItemPrefix = RegExp(
    r'^\s*(?:[0-9０-９]{1,3}[.)）、．:：]|[-*•])\s+(.+?)\s*$',
  );

  static final RegExp _backgroundHeader = RegExp(
    r'(?:\[\s*background\s+information\s*]|[\[【〖]\s*(?:背景信息|背景资料|上下文信息)\s*[\]】〗])',
    caseSensitive: false,
  );

  static final RegExp _sourceHeader = RegExp(
    r'(?:\[\s*source\s+text\s*]|[\[【〖]\s*(?:待翻译文本|原文文本|源文本)\s*[\]】〗])',
    caseSensitive: false,
  );

  static final RegExp _translationInstruction = RegExp(
    r'(?:'
    r'please\s+translate\s+the\s+following\s+text\s+into.{1,80}'
    r'taking\s+the\s+provided\s+background\s+information\s+into\s+consideration'
    r'|translate\s+the\s+following\s+text\s+into.{1,80}'
    r'note\s+that\s+you\s+(?:should|must)\s+only\s+output\s+the\s+translated\s+result'
    r'|请结合背景信息将以下文本翻译为.{1,30}'
    r'|将以下文本翻译(?:为|成).{1,30}[，,。.]?\s*注意.{0,20}只(?:需要|需)输出翻译后的结果'
    r')',
    caseSensitive: false,
    dotAll: true,
  );

  /// 剥掉单个无害列表标记——Hy-MT2 偶尔会从上下文背景里复制列表前缀。
  ///
  /// 仅背景模式、输出单行、源文本非列表时才尝试；剥离后的结果必须重新
  /// 通过全部输出校验才采纳（多行输出与列表源文本一律不动）。
  static String normalizeHarmlessSingleItemPrefix(
    String source,
    String output,
    bool requestHadBackground,
  ) {
    if (!requestHadBackground) return output;
    final sourceLines = linesOf(nfkcNormalize(source));
    if (sourceLines.any(hasItemPrefix)) return output;

    final outputLines = linesOf(output);
    if (outputLines.length != 1) return output;
    final match = _singleItemPrefix.firstMatch(outputLines.single);
    final stripped = match?.group(1)?.trim();
    if (stripped == null || stripped.isEmpty) return output;
    return inspect(source, stripped, requestHadBackground) is OutputAccept
        ? stripped
        : output;
  }

  /// 输出校验入口。
  static OutputDecision inspect(
    String source,
    String output,
    bool requestHadBackground,
  ) {
    if (output.trim().isEmpty) return const OutputAccept();
    if (output.contains(lineLimitSentinel) &&
        !source.contains(lineLimitSentinel)) {
      return const OutputReject(OutputReason.NATIVE_LINE_LIMIT);
    }

    final normalizedSource = nfkcNormalize(source);
    final normalizedOutput = nfkcNormalize(output);
    final outputHasBackgroundHeader = _backgroundHeader.hasMatch(
      normalizedOutput,
    );
    final outputHasSourceHeader = _sourceHeader.hasMatch(normalizedOutput);
    final sourceHasBackgroundHeader = _backgroundHeader.hasMatch(
      normalizedSource,
    );
    final sourceHasSourceHeader = _sourceHeader.hasMatch(normalizedSource);
    final unexpectedBackgroundHeader =
        outputHasBackgroundHeader && !sourceHasBackgroundHeader;
    final unexpectedSourceHeader =
        outputHasSourceHeader && !sourceHasSourceHeader;

    if (requestHadBackground &&
        outputHasBackgroundHeader &&
        outputHasSourceHeader &&
        (unexpectedBackgroundHeader || unexpectedSourceHeader)) {
      return const OutputReject(OutputReason.MULTI_SECTION_ECHO);
    }
    if (unexpectedBackgroundHeader) {
      return const OutputReject(OutputReason.BACKGROUND_HEADER_ECHO);
    }
    if (unexpectedSourceHeader) {
      return const OutputReject(OutputReason.SOURCE_HEADER_ECHO);
    }
    if (_translationInstruction.hasMatch(normalizedOutput) &&
        !_translationInstruction.hasMatch(normalizedSource)) {
      return const OutputReject(OutputReason.TRANSLATION_INSTRUCTION_ECHO);
    }
    if (requestHadBackground) {
      final shape = inspectContextShape(normalizedSource, normalizedOutput);
      if (shape != null) return shape;
    }
    return const OutputAccept();
  }

  /// 背景模式下的结构膨胀检测；返回 null 表示未命中拒绝。
  static OutputReject? inspectContextShape(String source, String output) {
    final sourceLines = linesOf(source);
    final outputLines = linesOf(output);
    final sourceItemPrefixes = sourceLines.where(hasItemPrefix).length;
    final outputItemPrefixes = outputLines.where(hasItemPrefix).length;

    if (outputItemPrefixes >= 2 && outputItemPrefixes > sourceItemPrefixes) {
      return const OutputReject(OutputReason.MULTI_ITEM_OUTPUT);
    }
    if (sourceLines.length == 1 &&
        outputLines.length >= 3 &&
        outputLines.length > sourceLines.length * 2) {
      return const OutputReject(OutputReason.MULTI_ITEM_OUTPUT);
    }
    if (outputItemPrefixes == 1 &&
        sourceItemPrefixes == 0 &&
        (outputLines.firstOrNull != null && hasItemPrefix(outputLines.first))) {
      return const OutputReject(OutputReason.UNEXPECTED_ITEM_PREFIX);
    }
    if (isPunctuationOnly(source) &&
        output.runes.any(isLetterOrDigitCodePoint)) {
      return const OutputReject(OutputReason.PUNCTUATION_SOURCE_EXPANSION);
    }

    final sourceCodePoints = codePointLength(source);
    final outputCodePoints = codePointLength(output);
    if (sourceCodePoints >= 1 &&
        sourceCodePoints <= 2 &&
        outputCodePoints >
            sourceCodePoints * _shortSourceExpansionMultiplier +
                _shortSourceExpansionAllowance) {
      return const OutputReject(OutputReason.SHORT_SOURCE_CONTEXT_EXPANSION);
    }
    return null;
  }

  /// 行序列：语义对齐 Kotlin `CharSequence.lineSequence()`
  /// （`\r\n`|\r|\n 分隔；空串产出 0 行；其余分隔产生的空段保留）。
  static List<String> linesOf(String input) {
    if (input.isEmpty) return const [];
    return input.split(RegExp(r'\r\n|\n|\r'));
  }

  /// 行是否以列表项前缀开头。
  static bool hasItemPrefix(String line) => _itemPrefix.hasMatch(line);

  /// 非空且不含字母 / 数字（仅标点或符号）。
  static bool isPunctuationOnly(String input) {
    if (input.trim().isEmpty) return false;
    return !input.runes.any(isLetterOrDigitCodePoint);
  }

  /// 码点长度（对齐 Kotlin codePointCount）。
  static int codePointLength(String input) => input.runes.length;
}
