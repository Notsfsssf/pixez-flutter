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

/// 图片翻译管线：OCR → 坐标换算回原图 → 批量翻译（逐块上屏回调）。
///
/// 输出的文本块一律在**原图像素坐标系**（规格 §5.2 / §8.1），
/// 覆盖层据此直接定位，与本次 OCR 使用的分辨率解耦。
library;

import '../geometry/rect_mapper.dart';
import '../model/ocr_resolution.dart';
import '../model/text_block.dart';
import '../model/translate_request.dart';
import '../ocr/ocr_engine.dart';
import '../translate/translator.dart';

/// 一次图片翻译的完整结果。
class ImageTranslationResult {
  /// OCR 文本块（已换算到原图像素坐标系）。
  final List<TextBlock> blocks;

  /// 与 [blocks] 等长的译文列表；失败 / 空置 null。
  final List<String?> translations;

  const ImageTranslationResult(this.blocks, this.translations);
}

/// 图片翻译器。
class ImageTranslator {
  final OcrEngine ocrEngine;
  final Translator translator;

  ImageTranslator({required this.ocrEngine, required this.translator});

  /// 计算解码目标尺寸：长边受 [resolution] 限制，另一维等比推导（取整）。
  ///
  /// 返回 (targetWidth, targetHeight)；原图不超限时返回原尺寸。
  static (int, int) computeDecodeSize(
    OcrResolution resolution,
    int originalWidth,
    int originalHeight,
  ) {
    if (originalWidth <= 0 || originalHeight <= 0) {
      throw ArgumentError('image size must be positive');
    }
    final maxSide = resolution.maxLongSide;
    if (maxSide == null) return (originalWidth, originalHeight);
    final longSide = originalWidth >= originalHeight
        ? originalWidth
        : originalHeight;
    if (longSide <= maxSide) return (originalWidth, originalHeight);
    if (originalWidth >= originalHeight) {
      final h = (originalHeight * maxSide / originalWidth).round();
      return (maxSide, h < 1 ? 1 : h);
    } else {
      final w = (originalWidth * maxSide / originalHeight).round();
      return (w < 1 ? 1 : w, maxSide);
    }
  }

  /// 执行 OCR + 翻译。
  ///
  /// [image] 的坐标系即解码像素坐标系；[onBlocksReady] 在 OCR 完成后回调
  /// （译文未就绪，UI 可先挂占位块）；[onBlockTranslated] 在每段译文就绪时
  /// 回调（index 对应 [ImageTranslationResult.blocks]），实现逐段上屏。
  Future<ImageTranslationResult> translate({
    required DecodedImage image,
    required int originalWidth,
    required int originalHeight,
    required TranslateRequest request,
    OcrOptions? ocrOptions,
    void Function(List<TextBlock> blocks)? onBlocksReady,
    void Function(int index, String? text)? onBlockTranslated,
  }) async {
    final blocks = await ocrEngine.recognize(image, options: ocrOptions);
    if (blocks.isEmpty) {
      return const ImageTranslationResult([], []);
    }
    final mapper = RectMapper.fromSizes(
      originalWidth: originalWidth,
      originalHeight: originalHeight,
      decodedWidth: image.width,
      decodedHeight: image.height,
    );
    final originalBlocks = mapper.toOriginalBlocks(blocks);
    onBlocksReady?.call(originalBlocks);
    final sources = blocks.map((b) => b.text).toList(growable: false);
    final translations = await translator.translateBatchIncremental(
      sources,
      request,
      (index, text) => onBlockTranslated?.call(index, text),
    );
    return ImageTranslationResult(originalBlocks, translations);
  }
}
