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

/// 译文缓存测试（语义对齐参考 TranslationCacheTest.kt）。
library;

import 'package:test/test.dart';
import 'package:translator/src/model/translate_request.dart';
import 'package:translator/src/translate/translation_cache.dart';

void main() {
  const request = TranslateRequest();
  const requestNoCache = TranslateRequest(useCache: false);

  group('缓存开关策略', () {
    test('表驱动：useCache 与空白值', () {
      final cases = <(String, bool, String, bool, bool)>[
        // (name, useCache, value, expectedEnabled, expectedShouldCache)
        ('normal mode valid translation', true, ' translated ', true, true),
        ('disabled flag', false, 'text', false, false),
        ('empty', true, '', true, false),
        ('space', true, '   ', true, false),
        ('line breaks and tabs', true, '\n\t', true, false),
      ];
      for (final (name, useCache, value, expectedEnabled, expected) in cases) {
        final req = TranslateRequest(useCache: useCache);
        expect(isEnabled(req), expectedEnabled, reason: '$name enabled');
        expect(shouldCache(req, value), expected, reason: '$name write');
      }
    });
  });

  test('get/put 命中与未命中', () {
    final cache = TranslationCache();
    expect(cache.get('k', request), isNull);
    cache.put('k', 'v', request);
    expect(cache.get('k', request), 'v');
    // useCache=false 时读写都被拦截
    expect(cache.get('k', requestNoCache), isNull);
    cache.put('k2', 'v2', requestNoCache);
    expect(cache.get('k2', request), isNull);
  });

  test('remove 只淘汰被拒绝的那条', () {
    final cache = TranslationCache(capacity: 2);
    cache.put('rejected', '[Background Information] leaked', request);
    cache.put('valid', '正常译文', request);

    cache.remove('rejected');

    expect(cache.get('rejected', request), isNull);
    expect(cache.get('valid', request), '正常译文');
  });

  test('access-order LRU：超出容量淘汰最久未访问条目', () {
    final cache = TranslationCache(capacity: 2);
    cache.put('a', '1', request);
    cache.put('b', '2', request);
    // 访问 a，使 b 变为最久未访问
    expect(cache.get('a', request), '1');
    cache.put('c', '3', request);

    expect(cache.get('b', request), isNull, reason: 'b 应被淘汰');
    expect(cache.get('a', request), '1');
    expect(cache.get('c', request), '3');
  });

  test('clear 清空全部', () {
    final cache = TranslationCache();
    cache.put('a', '1', request);
    cache.clear();
    expect(cache.get('a', request), isNull);
    expect(cache.length, 0);
  });

  test('容量必须为正', () {
    expect(() => TranslationCache(capacity: 0), throwsArgumentError);
  });
}
