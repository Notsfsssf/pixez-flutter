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

/// 预热决策（对齐参考 LocalLlmPrewarmPolicy.kt）。
library;

enum PrewarmDecision {
  /// 路由到端侧且模型已安装 → 执行预热。
  prewarm,

  /// 路由不在端侧（云端引擎 / 降级）→ 跳过。
  skipNonLocalOrFallback,

  /// 模型未安装 → 跳过。
  skipModelNotInstalled,
}

/// 仅当「路由到端侧」且「模型已安装」才预热。
PrewarmDecision decidePrewarm({
  required bool routedToLocalModel,
  required bool modelInstalled,
}) {
  if (!routedToLocalModel) return PrewarmDecision.skipNonLocalOrFallback;
  if (!modelInstalled) return PrewarmDecision.skipModelNotInstalled;
  return PrewarmDecision.prewarm;
}
