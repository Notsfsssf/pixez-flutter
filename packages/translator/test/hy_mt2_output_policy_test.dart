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

/// HyMt2OutputPolicy 测试（语义对齐参考 HyMt2OutputPolicyTest.kt）。
library;

import 'package:test/test.dart';
import 'package:translator/src/translate/hy_mt2_output_policy.dart';

void main() {
  group('normalizeHarmlessSingleItemPrefix', () {
    // (name, source, output, requestHadBackground, expected)
    final cases = <(String, String, String, bool, String)>[
      ('numbered single line', 'あっ!?', '1. 啊！？', true, '啊！？'),
      ('alternative number delimiter', 'あっ!?', '23） 啊！？', true, '啊！？'),
      ('full width number marker', 'あっ!?', '１． 啊！？', true, '啊！？'),
      ('bullet single line', 'あっ!?', '- 啊！？', true, '啊！？'),
      ('ordinary output', 'あっ!?', '啊！？', true, '啊！？'),
      ('quick request is unchanged', 'あっ!?', '1. 啊！？', false, '1. 啊！？'),
      ('list source keeps list output', '1. 最初の項目', '1. 第一项', true, '1. 第一项'),
      (
        'multiple output lines remain rejectable',
        'あっ!?',
        '1. 第一条\n2. 第二条',
        true,
        '1. 第一条\n2. 第二条',
      ),
      (
        'header leakage remains rejectable after prefix',
        'あっ!?',
        '1. [Source Text] 梓酱，你是谁？',
        true,
        '1. [Source Text] 梓酱，你是谁？',
      ),
      (
        'punctuation expansion remains rejectable after prefix',
        '?',
        '1. 如果听到那样的声音肯定很可怕',
        true,
        '1. 如果听到那样的声音肯定很可怕',
      ),
      (
        'short source expansion remains rejectable after prefix',
        'え',
        '1. 哎呀，阿比仓同学愿意帮忙的话，也许就能成功呢！',
        true,
        '1. 哎呀，阿比仓同学愿意帮忙的话，也许就能成功呢！',
      ),
    ];

    test('表驱动：严格且内容无关', () {
      for (final (name, source, output, hadBackground, expected) in cases) {
        expect(
          HyMt2OutputPolicy.normalizeHarmlessSingleItemPrefix(
            source,
            output,
            hadBackground,
          ),
          expected,
          reason: name,
        );
      }
    });
  });

  group('inspect 拒绝与接受', () {
    // (name, source, output, requestHadBackground, expected)
    final cases = <(String, String, String, bool, OutputDecision)>[
      ('normal translation', '梓ちゃん誰?', '梓酱，你是谁？', true, const OutputAccept()),
      (
        'valid long translation is not rejected by length',
        'そうなの?',
        '真的是这样吗？我此前完全不知道这件事情，也没有任何人向我解释过。',
        true,
        const OutputAccept(),
      ),
      (
        'raw Japanese onomatopoeia can be intentionally retained',
        'ドキドキ',
        'ドキドキ',
        true,
        const OutputAccept(),
      ),
      (
        'multiple source lines can keep multiple output lines',
        '一行目\n二行目\n三行目',
        '第一行\n第二行\n第三行',
        true,
        const OutputAccept(),
      ),
      (
        'source list item can keep its item prefix',
        '1. 最初の項目',
        '1. 第一项',
        true,
        const OutputAccept(),
      ),
      ('punctuation remains punctuation', '?', '？', true, const OutputAccept()),
      (
        'short interjection remains short',
        'え',
        '诶？',
        true,
        const OutputAccept(),
      ),
      (
        'ordinary word background is valid',
        '背景はきれいだね',
        '背景真漂亮啊。',
        true,
        const OutputAccept(),
      ),
      (
        'English prompt sections',
        '梓ちゃん誰?',
        '[Background Information]\nTranslated context\n[Source Text]\n梓酱，你是谁？',
        true,
        const OutputReject(OutputReason.MULTI_SECTION_ECHO),
      ),
      (
        'translated Chinese prompt sections from device log',
        '梓ちゃん誰?',
        '【背景信息】\n同页的其他对话……\n[原文文本]\n梓酱，你是谁？',
        true,
        const OutputReject(OutputReason.MULTI_SECTION_ECHO),
      ),
      (
        'official Chinese prompt sections',
        '梓ちゃん誰?',
        '〖背景信息〗\n其他台词\n〖待翻译文本〗\n梓酱，你是谁？',
        true,
        const OutputReject(OutputReason.MULTI_SECTION_ECHO),
      ),
      (
        'background header only',
        '梓ちゃん誰?',
        '[Background Information]\n其他台词',
        true,
        const OutputReject(OutputReason.BACKGROUND_HEADER_ECHO),
      ),
      (
        'source header only',
        '梓ちゃん誰?',
        '【原文文本】\n梓酱，你是谁？',
        true,
        const OutputReject(OutputReason.SOURCE_HEADER_ECHO),
      ),
      (
        'English instruction echo',
        '梓ちゃん誰?',
        'Please translate the following text into Chinese, taking the provided '
            'background information into consideration.',
        true,
        const OutputReject(OutputReason.TRANSLATION_INSTRUCTION_ECHO),
      ),
      (
        'Chinese instruction echo',
        '梓ちゃん誰?',
        '请结合背景信息将以下文本翻译为中文。',
        true,
        const OutputReject(OutputReason.TRANSLATION_INSTRUCTION_ECHO),
      ),
      (
        'native line cap marker is never displayable',
        '梓ちゃん誰?',
        '1. 第一条\n2. 第二条\n$lineLimitSentinel',
        true,
        const OutputReject(OutputReason.NATIVE_LINE_LIMIT),
      ),
      (
        'numbered whole page from device log',
        '?',
        '1. 我们学校会举办体育节\n2. 哇\n3. 从现在开始练习吧',
        true,
        const OutputReject(OutputReason.MULTI_ITEM_OUTPUT),
      ),
      (
        'numbered Japanese background from device log',
        'ゼェ...ゼェ...',
        '14. はあ\n15. 色んな意味で!!\n16. びくんっ',
        true,
        const OutputReject(OutputReason.MULTI_ITEM_OUTPUT),
      ),
      (
        'unnumbered multi paragraph response for one source',
        'ひっ...',
        '第一段\n第二段\n第三段',
        true,
        const OutputReject(OutputReason.MULTI_ITEM_OUTPUT),
      ),
      (
        'single unexpected numbering is structural leakage',
        'あっ!?',
        '1. 啊！？',
        true,
        const OutputReject(OutputReason.UNEXPECTED_ITEM_PREFIX),
      ),
      (
        'punctuation source cannot expand into translated page',
        '?',
        '如果听到那样的声音肯定很可怕',
        true,
        const OutputReject(OutputReason.PUNCTUATION_SOURCE_EXPANSION),
      ),
      (
        'one character source cannot absorb neighboring dialogue',
        'え',
        '哎呀，阿比仓同学愿意帮忙的话，也许就能成功呢！',
        true,
        const OutputReject(OutputReason.SHORT_SOURCE_CONTEXT_EXPANSION),
      ),
      (
        'structural expansion checks only apply to background requests',
        'え',
        '哎呀，阿比仓同学愿意帮忙的话，也许就能成功呢！',
        false,
        const OutputAccept(),
      ),
      (
        'literal source header requested by source is retained',
        '[Source Text]',
        '[Source Text]',
        true,
        const OutputAccept(),
      ),
      (
        'literal background header requested by source is retained',
        '[Background Information]',
        '[Background Information]',
        true,
        const OutputAccept(),
      ),
      (
        'unexpected header is rejected without background request too',
        '梓ちゃん誰?',
        '[Source Text]\n梓酱，你是谁？',
        false,
        const OutputReject(OutputReason.SOURCE_HEADER_ECHO),
      ),
    ];

    test('表驱动：拒绝 prompt 与整页渗透', () {
      for (final (name, source, output, hadBackground, expected) in cases) {
        final actual = HyMt2OutputPolicy.inspect(source, output, hadBackground);
        expect(actual, expected, reason: name);
      }
    });
  });

  group('行数语义', () {
    test('linesOf 对齐 Kotlin lineSequence', () {
      expect(HyMt2OutputPolicy.linesOf(''), isEmpty);
      expect(HyMt2OutputPolicy.linesOf('一行\n\n二行'), ['一行', '', '二行']);
      expect(HyMt2OutputPolicy.linesOf('一行\r\n二行'), ['一行', '二行']);
      expect(HyMt2OutputPolicy.linesOf('一行\n二行'), ['一行', '二行']);
    });

    test('全角标点归一后不再视为字母数字（punctuation-only 判定）', () {
      expect(HyMt2OutputPolicy.isPunctuationOnly('？'), isTrue);
      expect(HyMt2OutputPolicy.isPunctuationOnly('！'), isTrue);
      expect(HyMt2OutputPolicy.isPunctuationOnly('あ'), isFalse);
      expect(HyMt2OutputPolicy.isPunctuationOnly(''), isFalse);
    });
  });
}
