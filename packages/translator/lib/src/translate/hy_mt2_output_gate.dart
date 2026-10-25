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

/// Hy-MT2 输出闸门：生成边界 + 输出校验 + 归一化 + 去背景恢复 prompt 的组合，
/// 供端侧（LocalLlamaTranslator）与云端（OpenAI 兼容引擎）共用。
library;

import '../model/translate_request.dart';
import 'hy_mt2_generation_boundary_policy.dart';
import 'hy_mt2_output_policy.dart';
import 'hy_mt2_prompt_policy.dart';

/// 单次生成的输出校验结论（对齐参考 GeneratedOutputValidation）。
sealed class GeneratedOutputValidation {
  const GeneratedOutputValidation();
}

class GeneratedAccepted extends GeneratedOutputValidation {
  const GeneratedAccepted();
}

class GeneratedRetryable extends GeneratedOutputValidation {
  final String reason;
  final String fallbackText;

  const GeneratedRetryable(this.reason, this.fallbackText);
}

class GeneratedRejected extends GeneratedOutputValidation {
  final String reason;

  const GeneratedRejected(this.reason);
}

/// 拒绝原因前缀（与参考 HyMt2Translator.outputValidation 一致）。
const String hyMt2RejectionPrefix = 'HY_MT2_CONTEXT_BLEED:';

/// Hy-MT2 生成输出的统一校验入口。
abstract final class HyMt2OutputGate {
  /// 生成边界（背景模式行数上限 → NATIVE_LINE_LIMIT）+ 九类渗透检测。
  static GeneratedOutputValidation validate(
    String source,
    String output,
    String userPrompt,
  ) {
    final requestHadBackground = HyMt2PromptPolicy.isBackgroundPrompt(
      userPrompt,
    );
    if (requestHadBackground) {
      final maxLines = HyMt2GenerationBoundaryPolicy.maxOutputLines(
        source,
        requestHadBackground,
      );
      final outputLines = HyMt2OutputPolicy.linesOf(output).length;
      if (maxLines > 0 && outputLines > maxLines) {
        return const GeneratedRejected(
          '${hyMt2RejectionPrefix}NATIVE_LINE_LIMIT',
        );
      }
    }
    final decision = HyMt2OutputPolicy.inspect(
      source,
      output,
      requestHadBackground,
    );
    if (decision is OutputAccept) return const GeneratedAccepted();
    return GeneratedRejected(
      '$hyMt2RejectionPrefix${(decision as OutputReject).reason.name}',
    );
  }

  /// 引擎侧清理：剥单个无害列表前缀（仅背景模式）。
  static String normalize(String source, String output, String userPrompt) =>
      HyMt2OutputPolicy.normalizeHarmlessSingleItemPrefix(
        source,
        output,
        HyMt2PromptPolicy.isBackgroundPrompt(userPrompt),
      );

  /// 恢复 prompt：仅背景模式拒绝后可用（去背景重试一次）。
  static String? recoveryPrompt(
    String source,
    String rejectedUserPrompt,
    TranslateRequest request,
  ) {
    if (!HyMt2PromptPolicy.isBackgroundPrompt(rejectedUserPrompt)) return null;
    return HyMt2PromptPolicy.buildWithoutBackground(
      source,
      request.targetLang,
      request.context,
    );
  }
}
