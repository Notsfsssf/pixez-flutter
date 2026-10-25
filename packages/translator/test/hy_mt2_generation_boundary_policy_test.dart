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

/// HyMt2GenerationBoundaryPolicy 测试（语义对齐参考同名测试）。
library;

import 'package:test/test.dart';
import 'package:translator/src/translate/hy_mt2_generation_boundary_policy.dart';

void main() {
  test('表驱动：仅背景请求限制行数，且留一行余量', () {
    final cases = <(String, String, bool, int)>[
      ('quick translation stays unlimited', '一行', false, 0),
      ('single source line allows two output lines', '一行', true, 2),
      ('two source lines allow three output lines', '一行\n二行', true, 3),
      ('CRLF is one line boundary', '一行\r\n二行', true, 3),
      ('blank source line is preserved in the allowance', '一行\n\n二行', true, 4),
      ('empty defensive input still has a safe limit', '', true, 2),
    ];
    for (final (name, source, hadBackground, expected) in cases) {
      expect(
        HyMt2GenerationBoundaryPolicy.maxOutputLines(source, hadBackground),
        expected,
        reason: name,
      );
    }
  });
}
