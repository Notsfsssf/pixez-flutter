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

/// RectMapper 测试：四档解码后换算回原图坐标，误差 = 0（规格 §11 Phase 2）。
library;

import 'package:test/test.dart';
import 'package:translator/src/geometry/rect_mapper.dart';
import 'package:translator/src/model/ocr_resolution.dart';
import 'package:translator/src/model/text_block.dart';

void main() {
  const originalWidth = 4000;
  const originalHeight = 3000;

  const sampleBlock = TextBlock(
    text: 'テスト',
    polygon: [
      Offset2D(123.4, 567.8),
      Offset2D(234.5, 567.8),
      Offset2D(234.5, 678.9),
      Offset2D(123.4, 678.9),
    ],
    confidence: 0.97,
    orientation: TextOrientation.horizontal,
  );

  /// 模拟引擎按 targetWidth/targetHeight 等比解码（另一维由比例推导，四舍五入）。
  (int, int) decodedSize(OcrResolution resolution) {
    final (targetW, targetH) = resolution.decodeTarget(
      originalWidth,
      originalHeight,
    );
    if (targetW == null && targetH == null)
      return (originalWidth, originalHeight);
    if (targetW != null) {
      return (targetW, (originalHeight * targetW / originalWidth).round());
    }
    return ((originalWidth * targetH! / originalHeight).round(), targetH);
  }

  group('四档换算回原图后误差 = 0', () {
    for (final resolution in OcrResolution.values) {
      test('${resolution.name} 档', () {
        final (decodedW, decodedH) = decodedSize(resolution);
        final mapper = RectMapper.fromSizes(
          originalWidth: originalWidth,
          originalHeight: originalHeight,
          decodedWidth: decodedW,
          decodedHeight: decodedH,
        );

        // 模拟 OCR 输出在解码坐标系下的块：原图坐标 / 缩放比
        final decodedBlock = sampleBlock.scaled(
          1 / mapper.scaleX,
          1 / mapper.scaleY,
        );
        // 换算回原图
        final restored = mapper.toOriginalBlock(decodedBlock);

        expect(restored.polygon.length, sampleBlock.polygon.length);
        for (var i = 0; i < sampleBlock.polygon.length; i++) {
          expect(
            restored.polygon[i].x,
            closeTo(sampleBlock.polygon[i].x, 1e-6),
            reason: 'polygon[$i].x',
          );
          expect(
            restored.polygon[i].y,
            closeTo(sampleBlock.polygon[i].y, 1e-6),
            reason: 'polygon[$i].y',
          );
        }
        // 缩放比 x/y 分别计算（横图 4:3 下解码比例一致，但仍是两个独立值）
        expect(mapper.scaleX, originalWidth / decodedW);
        expect(mapper.scaleY, originalHeight / decodedH);
      });
    }
  });

  test('x / y 缩放比独立（非等比解码也能正确换算）', () {
    // 非等比场景：手动传入错位的解码尺寸
    final mapper = RectMapper.fromSizes(
      originalWidth: 4000,
      originalHeight: 3000,
      decodedWidth: 1000,
      decodedHeight: 1000,
    );
    expect(mapper.scaleX, 4.0);
    expect(mapper.scaleY, 3.0);

    final p = mapper.toOriginal(const Offset2D(10, 20));
    expect(p.x, 40);
    expect(p.y, 60);
  });

  test('非法尺寸抛 ArgumentError', () {
    expect(
      () => RectMapper.fromSizes(
        originalWidth: 0,
        originalHeight: 10,
        decodedWidth: 10,
        decodedHeight: 10,
      ),
      throwsArgumentError,
    );
    expect(
      () => RectMapper.fromSizes(
        originalWidth: 10,
        originalHeight: 10,
        decodedWidth: 0,
        decodedHeight: 10,
      ),
      throwsArgumentError,
    );
  });

  test('toOriginalBlocks 批量换算并保持不可变列表', () {
    final mapper = RectMapper.fromSizes(
      originalWidth: 2000,
      originalHeight: 2000,
      decodedWidth: 1000,
      decodedHeight: 1000,
    );
    final blocks = mapper.toOriginalBlocks([sampleBlock]);
    expect(blocks.length, 1);
    expect(blocks.first.boundingBox.left, closeTo(246.8, 1e-9));
    expect(identical(blocks, sampleBlock.polygon), isFalse);
  });

  test('TextBlock.scaled 单位缩放返回原实例', () {
    expect(identical(sampleBlock.scaled(1, 1), sampleBlock), isTrue);
  });
}
