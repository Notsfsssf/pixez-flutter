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

/// 小说段落翻译状态（规格 §8.2）：AppBar 开关（不持久化）、逐段流式上屏、
/// 译文替换原文（可切回对照）、按 `novelId + spanIndex + 目标语言` 的
/// 会话级内存缓存。
library;

import 'package:mobx/mobx.dart';
import 'package:pixez/er/lprinter.dart';

import 'translation_service.dart';

class NovelTranslationStore {
  /// 开关状态（不持久化，规格 §8.2）。
  final Observable<bool> enabled = Observable(false);

  /// 显示模式：true = 译文替换原文（默认），false = 对照（原文 + 译文）。
  ///
  /// 默认改成替换：开翻译的动机就是「看不懂原文」，把日文继续留在译文上面
  /// 会让人以为没翻成功。对照模式仍在，AppBar 上可随时切回去比对。
  final Observable<bool> showOnlyTranslation = Observable(true);

  /// 译文缓存：spanIndex → 译文（null/缺失 = 未译或失败，保留原文）。
  final ObservableMap<int, String?> translations = ObservableMap();

  final Observable<bool> translating = Observable(false);

  /// 已完成段落数 / 总段落数（AppBar 上显示进度用）。
  final Observable<int> translatedCount = Observable(0);
  final Observable<int> totalCount = Observable(0);

  /// 本轮翻译的失败提示（null = 没问题）。一段都没译出来时由 UI 弹提示，
  /// 否则用户只会看到转圈结束后什么都没变。
  final Observable<String?> lastError = Observable(null);

  /// 会话级内存缓存 key：novelId|spanIndex|targetLang。
  final Map<String, String> _memoryCache = {};

  void resetFor(int novelId) {
    runInAction(() {
      enabled.value = false;
      translating.value = false;
      showOnlyTranslation.value = true;
      translations.clear();
      translatedCount.value = 0;
      totalCount.value = 0;
      lastError.value = null;
    });
    _memoryCache.clear();
    _currentNovelId = novelId;
  }

  int? _currentNovelId;

  String? cached(int spanIndex, String targetLang) =>
      _memoryCache['$_currentNovelId|$spanIndex|$targetLang'];

  Future<void> toggle(List<(int spanIndex, String text)> paragraphs) async {
    final next = !enabled.value;
    runInAction(() => enabled.value = next);
    if (!next) return;
    await translateAll(paragraphs);
  }

  Future<void> translateAll(
    List<(int spanIndex, String text)> paragraphs,
  ) async {
    if (translating.value) return;
    if (paragraphs.isEmpty) {
      runInAction(() {
        totalCount.value = 0;
        lastError.value = '这一话没有可翻译的正文';
      });
      return;
    }
    final service = TranslationService.instance;
    await service.ensureInitialized();
    runInAction(() {
      translating.value = true;
      translatedCount.value = 0;
      totalCount.value = paragraphs.length;
      lastError.value = null;
    });
    // 段落是流式发射的：同一段会回调多次，只在首次拿到非空译文时计数。
    final counted = <int>{};
    try {
      final texts = paragraphs.map((p) => p.$2).toList(growable: false);
      final translator = await service.getTextTranslator();
      final request = await service.buildRequest();
      // 逐段翻译：onParagraph 每译完一段回调一次（规格 §8.2）
      await translator.translateParagraphs(
        texts,
        request,
        // 关掉开关就停止后续段落（已译出的保留）。
        isCancelled: () => !enabled.value,
        onParagraph: (index, text) {
          runInAction(() {
            translations[paragraphs[index].$1] = text;
            if (text != null && text.isNotEmpty) {
              _memoryCache['$_currentNovelId|${paragraphs[index].$1}|${request.targetLang}'] =
                  text;
              if (counted.add(index)) {
                translatedCount.value = counted.length;
              }
            }
          });
        },
      );
      if (counted.isEmpty) {
        runInAction(() {
          lastError.value = '这一段没有译出内容：请检查端侧模型是否可用，'
              '或到设置里确认翻译引擎 / 接口配置';
        });
      }
    } catch (e) {
      LPrinter.d('novel translate failed: $e');
      runInAction(() => lastError.value = '翻译失败：$e');
    } finally {
      runInAction(() => translating.value = false);
    }
  }

  void toggleShowMode() =>
      runInAction(() => showOnlyTranslation.value = !showOnlyTranslation.value);
}
