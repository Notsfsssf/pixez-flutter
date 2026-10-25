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

/// OcrResolution 四档测试：横竖图矩阵（规格 §5.1 / §11 Phase 2）。
library;

import 'package:test/test.dart';
import 'package:translator/src/model/ocr_resolution.dart';

void main() {
  group('maxLongSide / needsMemoryWarning', () {
    test('四档长边与内存警告', () {
      expect(OcrResolution.low.maxLongSide, 960);
      expect(OcrResolution.medium.maxLongSide, 1600);
      expect(OcrResolution.high.maxLongSide, 2400);
      expect(OcrResolution.original.maxLongSide, isNull);

      expect(OcrResolution.low.needsMemoryWarning, isFalse);
      expect(OcrResolution.medium.needsMemoryWarning, isFalse);
      expect(OcrResolution.high.needsMemoryWarning, isTrue);
      expect(OcrResolution.original.needsMemoryWarning, isTrue);
    });
  });

  group('decodeTarget 横竖图矩阵', () {
    test('横图（宽 >= 高）按宽缩放', () {
      expect(OcrResolution.low.decodeTarget(4000, 3000), (960, null));
      expect(OcrResolution.medium.decodeTarget(4000, 3000), (1600, null));
      expect(OcrResolution.high.decodeTarget(4000, 3000), (2400, null));
      expect(OcrResolution.original.decodeTarget(4000, 3000), (null, null));
    });

    test('竖图（高 > 宽）按高缩放', () {
      expect(OcrResolution.low.decodeTarget(3000, 4000), (null, 960));
      expect(OcrResolution.medium.decodeTarget(3000, 4000), (null, 1600));
      expect(OcrResolution.high.decodeTarget(3000, 4000), (null, 2400));
      expect(OcrResolution.original.decodeTarget(3000, 4000), (null, null));
    });

    test('未超上限的图不缩放（null, null）', () {
      // 横图宽 <= 长边
      expect(OcrResolution.low.decodeTarget(800, 600), (null, null));
      expect(OcrResolution.low.decodeTarget(960, 960), (null, null));
      // 竖图高 <= 长边
      expect(OcrResolution.low.decodeTarget(600, 800), (null, null));
      expect(OcrResolution.medium.decodeTarget(1200, 1600), (null, null));
      // 方图等于长边
      expect(OcrResolution.medium.decodeTarget(1600, 1600), (null, null));
    });

    test('仅长边超限才缩放（短边不触发）', () {
      // 横图 4000x200：宽超限 → (960, null)
      expect(OcrResolution.low.decodeTarget(4000, 200), (960, null));
      // 竖图 200x4000：高超限 → (null, 960)
      expect(OcrResolution.low.decodeTarget(200, 4000), (null, 960));
    });

    test('4000x4000 原图四档矩阵', () {
      expect(OcrResolution.low.decodeTarget(4000, 4000), (960, null));
      expect(OcrResolution.medium.decodeTarget(4000, 4000), (1600, null));
      expect(OcrResolution.high.decodeTarget(4000, 4000), (2400, null));
      expect(OcrResolution.original.decodeTarget(4000, 4000), (null, null));
    });
  });
}
