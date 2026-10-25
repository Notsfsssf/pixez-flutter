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

/// OCR 解码分辨率档位（规格 §5）。
///
/// 解码时只给长边一个维度，另一维交给解码器等比推导——
/// 禁止「先解全尺寸再缩小」（峰值内存 ≈ 目标尺寸 × 4B）。
library;

/// 用户可配置的四档 OCR 分辨率。
enum OcrResolution {
  low, // 长边 960  —— 默认
  medium, // 长边 1600
  high, // 长边 2400
  original, // 不缩放（null）
}

extension OcrResolutionX on OcrResolution {
  /// 长边上限；[OcrResolution.original] 返回 null 表示不缩放。
  int? get maxLongSide => switch (this) {
    OcrResolution.low => 960,
    OcrResolution.medium => 1600,
    OcrResolution.high => 2400,
    OcrResolution.original => null,
  };

  /// 高内存档位需要一次性内存警告（规格 §5.2 / §17 `translation_ocr_high_res_warned`）。
  bool get needsMemoryWarning =>
      this == OcrResolution.high || this == OcrResolution.original;

  /// 返回 (targetWidth, targetHeight)，只填长边，另一维交给解码器等比推导。
  ///
  /// 原图尺寸未超上限时返回 (null, null)，即按原尺寸解码。
  (int?, int?) decodeTarget(int originalWidth, int originalHeight) {
    final maxSide = maxLongSide;
    if (maxSide == null) return (null, null);
    if (originalWidth >= originalHeight) {
      return originalWidth <= maxSide ? (null, null) : (maxSide, null);
    }
    return originalHeight <= maxSide ? (null, null) : (null, maxSide);
  }
}
