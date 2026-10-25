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

/// 每段生成的最大输出行数（移植自参考 HyMt2GenerationBoundaryPolicy.kt）。
library;

import 'hy_mt2_output_policy.dart';

/// Hy-MT2 单条翻译的原生行数上限：仅背景模式生效。
abstract final class HyMt2GenerationBoundaryPolicy {
  static const int _outputLineAllowance = 1;

  /// 返回最大输出行数；`0` 表示不限行。
  ///
  /// 有背景时 = 源行数 + 1（行数按 [HyMt2OutputPolicy.linesOf] 语义，
  /// 至少按 1 行计）。超限输出以 NATIVE_LINE_LIMIT 拒绝。
  static int maxOutputLines(String source, bool requestHadBackground) {
    if (!requestHadBackground) return 0;
    final sourceLines = HyMt2OutputPolicy.linesOf(source).length;
    return (sourceLines < 1 ? 1 : sourceLines) + _outputLineAllowance;
  }
}
