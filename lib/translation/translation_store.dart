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

/// 图片翻译状态（规格 §8.1）：
/// `TranslatedImageState { idle, decoding, ocr, translating, done, error }`
/// + 进度（已译块数 / 总块数）+ 全局 / 单块「译文 / 原文」切换。
///
/// 用 mobx 核心 API 手写 Observable（不依赖 build_runner codegen，
/// 原因见 translation_settings.dart 头注释）。
library;

import 'package:mobx/mobx.dart';
import 'package:pixez/er/lprinter.dart';
import 'package:translator/translator.dart';

import 'image_decode_service.dart';
import 'translation_settings.dart';

enum TranslatedImageState { idle, decoding, ocr, translating, done, error }

extension _OcrResolutionX on int {
  OcrResolution toOcrResolution() => OcrResolution.values[this];
}

/// 一块已定位的译文（坐标系 = 原图像素）。
class TranslatedBlockData {
  final TextBlock block;

  /// 译文；null = 翻译失败（保留原文显示，规格 §6.2）。
  final String? translated;

  TranslatedBlockData(this.block, this.translated);
}

class ImageTranslationStore {
  final Observable<TranslatedImageState> _state = Observable(
    TranslatedImageState.idle,
  );
  final ObservableList<TranslatedBlockData> blocks = ObservableList();
  final Observable<int> _translatedCount = Observable(0);
  final Observable<String?> _error = Observable(null);

  /// 全局「显示原文」开关（译文 / 原文切换）。
  final Observable<bool> showAllOriginal = Observable(false);

  /// 单块点击切换记录。
  final ObservableSet<int> _originalBlocks = ObservableSet();

  /// 空闲时是否提示「未识别到文字」（规格 R3）。
  final Observable<bool> noTextFound = Observable(false);

  /// 原图真实像素尺寸（解码后回填；覆盖层 childSize 用）。
  final Observable<int> originalWidth = Observable(0);
  final Observable<int> originalHeight = Observable(0);

  /// 解码回填真实尺寸后的通知（页面据此重建 childSize）。
  ///
  /// PhotoView 的 childSize 与覆盖层必须同时切到真实像素：一边用元数据、
  /// 一边用真实尺寸时，译文块会整体偏移、字号也会算错。
  void Function()? onLayoutChanged;

  TranslatedImageState get state => _state.value;

  set state(TranslatedImageState v) => runInAction(() => _state.value = v);

  int get translatedCount => _translatedCount.value;
  int get totalCount => blocks.length;

  String? get error => _error.value;

  bool get isWorking =>
      state == TranslatedImageState.decoding ||
      state == TranslatedImageState.ocr ||
      state == TranslatedImageState.translating;

  /// 该块当前是否显示原文（全局开关 XOR 单块切换）。
  bool showsOriginal(int index) =>
      showAllOriginal.value != _originalBlocks.contains(index);

  void toggleAllOriginal() =>
      runInAction(() => showAllOriginal.value = !showAllOriginal.value);

  void toggleBlockOriginal(int index) => runInAction(() {
    if (!_originalBlocks.add(index)) _originalBlocks.remove(index);
  });

  /// 覆盖层重跑前清空旧块（质量门：四档重跑不残留，规格 §15）。
  void reset() {
    runInAction(() {
      _state.value = TranslatedImageState.idle;
      blocks.clear();
      _translatedCount.value = 0;
      _error.value = null;
      _originalBlocks.clear();
      showAllOriginal.value = false;
      noTextFound.value = false;
    });
  }

  void setError(String message) {
    runInAction(() {
      _state.value = TranslatedImageState.error;
      _error.value = message;
    });
  }

  /// 执行图片翻译全流程：解码 → OCR → 翻译（逐块上屏）。
  ///
  /// 由 photo_zoom_page 调用；[originalWidth]/[originalHeight] 来自
  /// illusts 元数据，用于 RectMapper 与覆盖层 childSize。
  Future<void> translateImage({
    required String url,
    required int originalWidth,
    required int originalHeight,
    required TranslationPipeline pipeline,
  }) async {
    reset();
    try {
      state = TranslatedImageState.decoding;
      final decoded = await pipeline.decodeService.decode(
        url,
        pipeline.settings.ocrResolutionIndex.toOcrResolution(),
      );
      var sizeChanged = false;
      runInAction(() {
        // this. 前缀：字段被同名参数遮蔽，操作的是 Observable 字段。
        sizeChanged =
            this.originalWidth.value != decoded.originalWidth ||
            this.originalHeight.value != decoded.originalHeight;
        this.originalWidth.value = decoded.originalWidth;
        this.originalHeight.value = decoded.originalHeight;
      });
      if (sizeChanged) onLayoutChanged?.call();

      state = TranslatedImageState.ocr;
      final request = await pipeline.buildRequest();
      final imageTranslator = await pipeline.imageTranslator;

      state = TranslatedImageState.translating;
      final result = await imageTranslator.translate(
        image: DecodedImage(
          width: decoded.decodedWidth,
          height: decoded.decodedHeight,
          bytes: decoded.bytes,
          format: DecodedImageFormat.png,
        ),
        originalWidth: decoded.originalWidth,
        originalHeight: decoded.originalHeight,
        request: request,
        // OCR 完成先挂占位块（译文 null）：后续 onBlockTranslated 才有
        // 目标可写，译文得以一段一段出现，而不是等整批译完一次性上屏。
        onBlocksReady: (ready) {
          runInAction(() {
            blocks.clear();
            for (final b in ready) {
              blocks.add(TranslatedBlockData(b, null));
            }
          });
        },
        onBlockTranslated: (index, text) {
          runInAction(() {
            if (text != null) _translatedCount.value++;
            if (index >= 0 && index < blocks.length) {
              blocks[index] = TranslatedBlockData(blocks[index].block, text);
            }
          });
        },
      );

      // 识别结果为空 → 提示「未识别到文字」（规格 R3）
      if (result.blocks.isEmpty) {
        runInAction(() => noTextFound.value = true);
        state = TranslatedImageState.done;
        return;
      }

      runInAction(() {
        // 逐段回调已填充过 blocks；这里仅兜底对齐，不清空重建以免上屏闪烁。
        if (blocks.length != result.blocks.length) {
          blocks.clear();
          for (var i = 0; i < result.blocks.length; i++) {
            blocks.add(
              TranslatedBlockData(result.blocks[i], result.translations[i]),
            );
          }
        } else {
          for (var i = 0; i < blocks.length; i++) {
            blocks[i] = TranslatedBlockData(
              result.blocks[i],
              result.translations[i],
            );
          }
        }
        _translatedCount.value = result.translations
            .where((t) => t != null)
            .length;
      });
      state = TranslatedImageState.done;
    } catch (e, st) {
      // 完整异常进 logcat（flutter tag）：toast 只显示固定文案，排障靠这里。
      LPrinter.i('translateImage failed: $e\n$st');
      setError(e.toString());
    }
  }
}

/// 依赖聚合（ImageTranslationStore 的注入面），由 TranslationService 提供实现。
mixin TranslationPipeline {
  ImageDecodeService get decodeService;
  TranslationSettings get settings;
  Future<TranslateRequest> buildRequest({List<String> currentPage});
  Future<ImageTranslator> get imageTranslator;
}
