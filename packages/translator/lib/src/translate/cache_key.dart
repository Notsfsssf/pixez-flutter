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

/// 端侧翻译缓存键（移植自参考 LocalLlamaTranslationCacheKey.kt）。
library;

import 'translation_cache.dart';

/// 键 = `model | targetLang.lowercase | promptHash | sourceHash | sourceLen`，
/// prompt 指纹 = `sourceLang=…|targetLang=…|maxNewTokens=n|system=…|user=…`。
abstract final class LocalLlamaTranslationCacheKey {
  static String build({
    required TranslationCache cache,
    required String source,
    required String model,
    required String sourceLang,
    required String targetLang,
    required int maxNewTokens,
    String? systemPrompt,
    required String userPrompt,
  }) => cache.key(
    source.trim(),
    model,
    targetLang.trim().toLowerCase(),
    promptFingerprint(
      sourceLang: sourceLang,
      targetLang: targetLang,
      maxNewTokens: maxNewTokens,
      systemPrompt: systemPrompt,
      userPrompt: userPrompt,
    ),
  );

  static String promptFingerprint({
    required String sourceLang,
    required String targetLang,
    required int maxNewTokens,
    String? systemPrompt,
    required String userPrompt,
  }) =>
      'sourceLang=${sourceLang.trim().toLowerCase()}'
      '|targetLang=${targetLang.trim().toLowerCase()}'
      '|maxNewTokens=$maxNewTokens'
      '|system=${systemPrompt ?? ''}'
      '|user=$userPrompt';
}
