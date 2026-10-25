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

/// Hy-MT2 引擎画像：策略绑定常量（移植自参考 HyMt2Translator.kt 的绑定面）。
library;

/// Tencent Hy-MT2-1.8B Q4_K_M 端侧翻译器的策略绑定。
abstract final class HyMt2Profile {
  /// 缓存键用的模型名（对齐参考 LlmModelKind.HY_MT2_1_8B_Q4_K_M.name）。
  static const String modelName = 'HY_MT2_1_8B_Q4_K_M';

  /// GGUF 文件名 / 下载标识。
  static const String modelFile = 'Hy-MT2-1.8B-Q4_K_M.gguf';

  /// Hy-MT2 无 system prompt（纯 user prompt，参考 `systemPrompt: String? = null`）。
  static const String? systemPrompt = null;

  /// 端侧引擎不暴露未校验的部分生成：token 全部缓冲，校验通过后一次性上屏
  /// （规格 §6.4）。
  static const bool bufferGeneratedOutputUntilValidated = true;

  /// 拒绝后允许「去背景 prompt 重试一次」。
  static const bool retryFailedTranslation = true;

  /// 端侧单段最大新 token 默认值。
  static const int defaultMaxNewTokens = 512;

  /// 预热短句与预测长度（参考 LocalLlamaTranslator 的 PREWARM_*）。
  static const String prewarmSource = 'こんにちは';
  static const int prewarmPredictLength = 1;
}
