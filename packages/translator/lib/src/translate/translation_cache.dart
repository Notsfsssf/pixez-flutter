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

/// 译文内存缓存（移植自参考 TranslationCache.kt）。
///
/// access-order LRU；命中率高的话 token 消耗能压一大截，
/// 同句重复出现的场景特别明显。**缓存命中也要重跑输出校验**（脏缓存剔除，
/// 由调用方负责，见 LocalLlamaTranslator.validatedCachedOutput）。
library;

import '../model/translate_request.dart';

class TranslationCache {
  /// 缓存容量；超过即淘汰最久未访问的条目。
  final int capacity;

  // Dart 的 LinkedHashMap 保持插入序；access-order 由 get/put 里的
  // 「删除重插」手动维护（对齐 Kotlin LinkedHashMap(accessOrder = true)）。
  final Map<String, String> _cache = <String, String>{};

  TranslationCache({this.capacity = 256}) {
    if (capacity <= 0) {
      throw ArgumentError.value(
        capacity,
        'capacity',
        'capacity must be positive',
      );
    }
  }

  /// 键格式：`model | targetLang | promptHash | sourceHash | sourceLen`。
  ///
  /// 哈希用 Dart `String.hashCode`（进程内一致即可，缓存不落盘）。
  String key(String source, String model, String targetLang, String prompt) =>
      '$model|$targetLang|${prompt.hashCode}|${source.hashCode}|${source.length}';

  String? get(String key, TranslateRequest request) {
    if (!isEnabled(request)) return null;
    final value = _cache.remove(key);
    if (value == null) return null;
    _cache[key] = value; // 重新插入尾部 = 标记为最近访问
    return value;
  }

  void put(String key, String value, TranslateRequest request) {
    if (!shouldCache(request, value)) return;
    _cache.remove(key);
    _cache[key] = value;
    while (_cache.length > capacity) {
      _cache.remove(_cache.keys.first);
    }
  }

  void remove(String key) => _cache.remove(key);

  void clear() => _cache.clear();

  int get length => _cache.length;
}

/// 缓存开关策略（参考 TranslationCachePolicy）。
///
/// 参考实现由 developerOptionsEnabled + disableTranslationCache 两个设置
/// 推导；本包简化为请求级 [TranslateRequest.useCache] 单开关，
/// app 侧负责把开发者选项合并进去。
bool isEnabled(TranslateRequest request) => request.useCache;

bool shouldCache(TranslateRequest request, String value) =>
    isEnabled(request) && value.trim().isNotEmpty;
