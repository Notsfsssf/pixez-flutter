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

/// 缓存键测试（语义对齐参考 LocalLlamaTranslationCacheKeyTest.kt）。
library;

import 'package:test/test.dart';
import 'package:translator/src/translate/cache_key.dart';
import 'package:translator/src/translate/translation_cache.dart';

void main() {
  late TranslationCache cache;

  setUp(() {
    cache = TranslationCache();
  });

  String buildKey({
    String source = 'こんにちは',
    String model = 'SAKURA_1_5B_Q4',
    String sourceLang = 'ja',
    String targetLang = 'zh-CN',
    int maxNewTokens = 256,
    String? systemPrompt = 'system',
    String userPrompt = 'translate: こんにちは',
  }) => LocalLlamaTranslationCacheKey.build(
    cache: cache,
    source: source,
    model: model,
    sourceLang: sourceLang,
    targetLang: targetLang,
    maxNewTokens: maxNewTokens,
    systemPrompt: systemPrompt,
    userPrompt: userPrompt,
  );

  test('空白与语言大小写不影响键等价', () {
    final first = buildKey(
      source: '  こんにちは  ',
      sourceLang: ' JA ',
      targetLang: ' ZH-CN ',
    );
    final second = buildKey(
      source: 'こんにちは',
      sourceLang: 'ja',
      targetLang: 'zh-cn',
    );
    expect(first, second);
  });

  test('语义不同的请求键不同', () {
    final baseline = buildKey();
    final differentCases = <String, String Function()>{
      'source text': () => buildKey(source: 'こんばんは'),
      'model kind': () => buildKey(model: 'HY_MT2_1_8B_Q4_K_M'),
      'source language': () => buildKey(sourceLang: 'en'),
      'target language': () => buildKey(targetLang: 'zh-TW'),
      'max new tokens': () => buildKey(maxNewTokens: 128),
      'system prompt': () => buildKey(systemPrompt: 'other system'),
      'no system prompt': () => buildKey(systemPrompt: null),
      'user prompt': () => buildKey(userPrompt: 'Translate only: こんにちは'),
    };
    differentCases.forEach((name, build) {
      expect(build(), isNot(baseline), reason: name);
    });
  });

  test('promptFingerprint 指纹格式与归一化', () {
    expect(
      LocalLlamaTranslationCacheKey.promptFingerprint(
        sourceLang: ' JA ',
        targetLang: ' ZH-CN ',
        maxNewTokens: 256,
        systemPrompt: 'system',
        userPrompt: 'translate: こんにちは',
      ),
      'sourceLang=ja|targetLang=zh-cn|maxNewTokens=256|system=system'
      '|user=translate: こんにちは',
    );
    expect(
      LocalLlamaTranslationCacheKey.promptFingerprint(
        sourceLang: 'ja',
        targetLang: 'zh-CN',
        maxNewTokens: 256,
        systemPrompt: null,
        userPrompt: 'translate: こんにちは',
      ),
      contains('|system=|'),
    );
  });
}
