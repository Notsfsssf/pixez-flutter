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

/// 翻译请求与上下文模型。
///
/// 对齐参考实现（overlay-translator）中 `Settings` 里驱动翻译的字段子集：
/// `RuntimeTranslationPromptContext`（背景三段 + 术语表）、
/// `sourceLang` / `targetLang` / `localLlmMaxNewTokens` / `retryFailedTranslation`。
library;

/// 同页其它文本块的翻译对（参考：RuntimeDialogueTurn）。
class RuntimeDialogueTurn {
  final String source;
  final String? translation;

  const RuntimeDialogueTurn(this.source, this.translation);
}

/// 一条术语（参考：RuntimeGlossaryTerm）。
class RuntimeGlossaryTerm {
  final String source;
  final String target;

  const RuntimeGlossaryTerm(this.source, this.target);
}

/// 运行时 prompt 上下文（参考：RuntimeTranslationPromptContext）。
///
/// 结构对齐参考实现：`Current application` / `Previous dialogue` /
/// `Other text on the current page` 三段背景 + 术语表。
class RuntimePromptContext {
  /// 当前应用名（背景第一段；null / 空则省略该段）。
  final String? currentApplication;

  /// 前文对话轮次（背景第二段）。
  final List<RuntimeDialogueTurn> previousFrame;

  /// 同页其它原文（背景第三段；构建时会移除与当前 source 相同的第一项）。
  final List<String> currentPage;

  /// 术语表，行格式 `{源} translates to {译}`。
  final List<RuntimeGlossaryTerm> glossary;

  const RuntimePromptContext({
    this.currentApplication,
    this.previousFrame = const [],
    this.currentPage = const [],
    this.glossary = const [],
  });

  /// 置空全部背景字段后返回副本（术语表保留）——
  /// 即 Hy-MT2 拒绝后的「去背景重试」上下文。
  RuntimePromptContext withoutBackground() => RuntimePromptContext(
    currentApplication: null,
    previousFrame: const [],
    currentPage: const [],
    glossary: glossary,
  );

  bool get hasBackground =>
      (currentApplication != null && currentApplication!.trim().isNotEmpty) ||
      previousFrame.any((t) => t.source.trim().isNotEmpty) ||
      currentPage.any((s) => s.trim().isNotEmpty);
}

/// 一次翻译请求的参数。
class TranslateRequest {
  /// 源语言（`auto` 或 BCP-47 风格代码，如 `ja`）。
  final String sourceLang;

  /// 目标语言（`auto` 或语言代码；构建 prompt 时按 Hy-MT2 规则归一化）。
  final String targetLang;

  /// 端侧引擎单段最大新 token 数（参考：localLlmMaxNewTokens）。
  final int maxNewTokens;

  /// 引擎 system prompt；Hy-MT2 为 null（纯 user prompt）。
  final String? systemPrompt;

  /// 背景三段 + 术语表。
  final RuntimePromptContext context;

  /// 失败后是否允许「去背景重试一次」（参考：retryFailedTranslation）。
  final bool retryFailedTranslation;

  /// 是否启用译文缓存（开发者选项可禁用，规格 §6.5）。
  final bool useCache;

  const TranslateRequest({
    this.sourceLang = 'auto',
    this.targetLang = 'auto',
    this.maxNewTokens = 512,
    this.systemPrompt,
    this.context = const RuntimePromptContext(),
    this.retryFailedTranslation = true,
    this.useCache = true,
  });
}

/// 连接 / 引擎可用性自检结果。
class TestResult {
  final bool success;
  final String message;

  const TestResult({required this.success, required this.message});

  @override
  String toString() => 'TestResult(success: $success, message: $message)';
}
