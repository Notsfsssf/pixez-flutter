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

/// 信息流缩略图的「就地翻译」（不进入详情 / 看图页）。
///
/// 与 [ImageTranslationStore] 的分工：
/// - 那个是「一个页面一份」的 mobx 状态，页面销毁即释放；
/// - 这里的状态必须活在全局——信息流卡片会被 ListView 回收重建，
///   状态挂在卡片 State 上会在滚动时丢失，滚回来又要重跑十几秒推理。
///
/// 翻译结果按图片 URL 缓存（原图像素坐标 + 原图尺寸），滚动时覆盖层
/// 直接复用缓存重新贴回卡片，不重新推理。
library;

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart' show Size;
import 'package:pixez/er/lprinter.dart';
import 'package:pixez/translation/translation_service.dart';
import 'package:pixez/translation/translation_store.dart'
    show TranslatedBlockData;
import 'package:translator/translator.dart';

/// 单张缩略图的翻译状态。
enum ThumbTranslationState { idle, running, done, empty, error }

/// 一张图的翻译结果快照（不可变，UI 直接读取）。
class ThumbTranslationEntry {
  final ThumbTranslationState state;

  /// 已定位的文本块（坐标为**原图像素**，与卡片显示尺寸解耦）。
  final List<TranslatedBlockData> blocks;

  /// 原图像素尺寸（覆盖层缩放基准）。
  final Size originalSize;

  /// state == error 时的原因（直接展示给用户，便于排障）。
  final String? error;

  const ThumbTranslationEntry({
    required this.state,
    required this.blocks,
    required this.originalSize,
    this.error,
  });

  static const idle = ThumbTranslationEntry(
    state: ThumbTranslationState.idle,
    blocks: [],
    originalSize: Size.zero,
  );
}

/// 信息流就地翻译服务（进程内单例）。
///
/// 只做三件事：按 URL 去重、跑一遍 OCR + 批量翻译、把结果按批通知 UI。
/// 并发交给底层的 [LlmEngineHost] 串行队列，这里不额外加锁。
class ThumbnailTranslationService extends ChangeNotifier {
  ThumbnailTranslationService._();

  static final ThumbnailTranslationService instance =
      ThumbnailTranslationService._();

  /// 缓存上限：信息流可能滑过几百张，只保留最近若干张的译文。
  static const int _cacheLimit = 24;

  /// 插入顺序即 LRU 顺序（Dart 的 Map 是 LinkedHashMap）。
  final Map<String, ThumbTranslationEntry> _entries = {};

  /// 进行中（含排队）的任务。value 的 Completer 让调用方 await 到自己这次。
  final Map<String, Completer<void>> _inflight = {};

  /// 待执行队列。端侧推理是同步 FFI、单 worker，并发发起只会互相抢模型，
  /// 这里串行执行：多页漫画把「当前页」先入队、「预取页」后入队。
  final List<String> _queue = [];
  bool _pumping = false;

  ThumbTranslationEntry entryFor(String url) {
    final entry = _entries[url];
    if (entry != null && _entries.length > 1) {
      // 访问即刷新插入顺序，淘汰时优先丢最久没看过的那页。
      _entries.remove(url);
      _entries[url] = entry;
    }
    return entry ?? ThumbTranslationEntry.idle;
  }

  bool isRunning(String url) => _inflight.containsKey(url);

  /// 是否有可显示的译文块。
  bool hasBlocks(String url) => (_entries[url]?.blocks.isNotEmpty ?? false);

  /// 触发一张图的翻译。
  ///
  /// 已有结果时直接返回（由 UI 切换译文 / 原文）；进行中重复点击忽略。
  /// 返回的 Future 在这次任务真正跑完时结束（排在前面的任务会拖慢它）。
  Future<void> translate(String url) {
    if (_inflight.containsKey(url)) return _inflight[url]!.future;
    final cached = _entries[url];
    if (cached != null && cached.state == ThumbTranslationState.done) {
      return Future<void>.value();
    }

    final completer = Completer<void>();
    _inflight[url] = completer;
    _queue.add(url);
    _pump();
    return completer.future;
  }

  /// 串行消费队列；同一时刻只有一个页面在跑 OCR + 推理。
  Future<void> _pump() async {
    if (_pumping) return;
    _pumping = true;
    try {
      while (_queue.isNotEmpty) {
        final url = _queue.removeAt(0);
        final completer = _inflight[url];
        if (completer == null) continue; // 排队期间被 forget 掉了
        try {
          await _run(url);
        } finally {
          _inflight.remove(url);
          if (!completer.isCompleted) completer.complete();
          notifyListeners();
        }
      }
    } finally {
      _pumping = false;
    }
  }

  Future<void> _run(String url) async {
    _put(
      url,
      ThumbTranslationEntry(
        state: ThumbTranslationState.running,
        blocks: const [],
        originalSize: Size.zero,
      ),
    );
    try {
      final service = TranslationService.instance;
      await service.ensureInitialized();
      final resolution = OcrResolution
          .values[service.settings.ocrResolutionIndex];
      final decoded = await service.decodeService.decode(url, resolution);
      final request = await service.buildRequest();
      final translator = await service.imageTranslator;
      final originalSize = Size(
        decoded.originalWidth.toDouble(),
        decoded.originalHeight.toDouble(),
      );
      var current = const <TranslatedBlockData>[];

      final result = await translator.translate(
        image: DecodedImage(
          width: decoded.decodedWidth,
          height: decoded.decodedHeight,
          bytes: decoded.bytes,
          format: DecodedImageFormat.png,
        ),
        originalWidth: decoded.originalWidth,
        originalHeight: decoded.originalHeight,
        request: request,
        // OCR 完成先挂占位块（译文 null → 显示原文），随后每批译文
        // 落到对应块上，卡片上就能看到译文一段段浮出来。
        onBlocksReady: (ready) {
          current = ready
              .map((b) => TranslatedBlockData(b, null))
              .toList(growable: false);
          _put(
            url,
            ThumbTranslationEntry(
              state: ThumbTranslationState.running,
              blocks: current,
              originalSize: originalSize,
            ),
          );
        },
        onBlockTranslated: (index, text) {
          if (index < 0 || index >= current.length) return;
          final next = List<TranslatedBlockData>.of(current);
          next[index] = TranslatedBlockData(next[index].block, text);
          current = next;
          _put(
            url,
            ThumbTranslationEntry(
              state: ThumbTranslationState.running,
              blocks: current,
              originalSize: originalSize,
            ),
          );
        },
      );

      // 以管线最终结果为准（回调顺序与 blocks 一一对应，这里兜底对齐）。
      if (result.blocks.isNotEmpty) {
        current = [
          for (var i = 0; i < result.blocks.length; i++)
            TranslatedBlockData(result.blocks[i], result.translations[i]),
        ];
      }
      _put(
        url,
        ThumbTranslationEntry(
          state: current.isEmpty
              ? ThumbTranslationState.empty
              : ThumbTranslationState.done,
          blocks: current,
          originalSize: originalSize,
        ),
      );
    } catch (e, st) {
      LPrinter.i('thumbnail translate failed: $e\n$st');
      _put(
        url,
        ThumbTranslationEntry(
          state: ThumbTranslationState.error,
          blocks: const [],
          originalSize: Size.zero,
          error: '$e',
        ),
      );
    }
  }

  /// 丢弃一张图的缓存（长按按钮「重译」用）。
  void forget(String url) {
    // 还在排队但没开跑：直接从队列摘掉并把等待者放行，避免白跑一次推理。
    if (_queue.remove(url)) {
      final pending = _inflight.remove(url);
      if (pending != null && !pending.isCompleted) pending.complete();
    }
    _entries.remove(url);
    notifyListeners();
  }

  void _put(String url, ThumbTranslationEntry entry) {
    _entries[url] = entry;
    _evictIfNeeded(keep: url);
    notifyListeners();
  }

  /// 超限时按插入顺序淘汰最旧的已完成项（不动进行中的任务）。
  void _evictIfNeeded({required String keep}) {
    if (_entries.length <= _cacheLimit) return;
    final removable = _entries.keys
        .where((k) => k != keep && !_inflight.containsKey(k))
        .toList(growable: false);
    var overflow = _entries.length - _cacheLimit;
    for (final key in removable) {
      if (overflow <= 0) break;
      _entries.remove(key);
      overflow--;
    }
  }
}
