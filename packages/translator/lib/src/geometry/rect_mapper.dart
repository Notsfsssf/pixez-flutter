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

/// 坐标系换算：解码坐标 ↔ 原图坐标（对齐参考 OverlayPresentationGeometry.kt
/// 的换算语义，规格 §5.2）。
///
/// 缩放比 **分别** 计算（`scaleX = originalWidth / decodedWidth`、
/// `scaleY = originalHeight / decodedHeight`），避免非整数比累积误差；
/// 覆盖层工作在原图像素坐标系，与本次 OCR 使用的分辨率完全解耦。
library;

import '../model/text_block.dart';

/// 解码坐标 → 原图坐标的线性映射。
class RectMapper {
  /// x 轴缩放比 = originalWidth / decodedWidth。
  final double scaleX;

  /// y 轴缩放比 = originalHeight / decodedHeight。
  final double scaleY;

  const RectMapper({required this.scaleX, required this.scaleY});

  /// 由原图尺寸与本次 OCR 解码尺寸构造。
  factory RectMapper.fromSizes({
    required int originalWidth,
    required int originalHeight,
    required int decodedWidth,
    required int decodedHeight,
  }) {
    if (originalWidth <= 0 || originalHeight <= 0) {
      throw ArgumentError('original size must be positive');
    }
    if (decodedWidth <= 0 || decodedHeight <= 0) {
      throw ArgumentError('decoded size must be positive');
    }
    return RectMapper(
      scaleX: originalWidth / decodedWidth,
      scaleY: originalHeight / decodedHeight,
    );
  }

  Offset2D toOriginal(Offset2D p) => Offset2D(p.x * scaleX, p.y * scaleY);

  /// 把解码坐标系下的文本块换算到原图像素坐标系。
  TextBlock toOriginalBlock(TextBlock block) => block.scaled(scaleX, scaleY);

  /// 批量换算。
  List<TextBlock> toOriginalBlocks(Iterable<TextBlock> blocks) =>
      blocks.map(toOriginalBlock).toList(growable: false);
}
