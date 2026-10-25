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

/// 翻译引擎抽象（对齐参考 translate/Translator.kt 接口族）。
library;

import '../model/translate_request.dart';

/// 翻译失败异常（规格 §4.1：失败抛 TranslationException）。
class TranslationException implements Exception {
  final String message;

  /// 引擎侧错误分类，可用于 UI 提示映射（如 HTTP 状态、模型未就绪）。
  final String? code;

  TranslationException(this.message, {this.code});

  @override
  String toString() => code == null
      ? 'TranslationException: $message'
      : 'TranslationException($code): $message';
}

/// 批量翻译的单项增量回调载荷。
class BatchTranslationUpdate {
  final int index;
  final String? text;
  final int elapsedMs;

  const BatchTranslationUpdate({
    required this.index,
    required this.text,
    required this.elapsedMs,
  });
}

/// 翻译引擎接口。
abstract class Translator {
  /// 非流式。空输入返回 null；失败抛 [TranslationException]。
  Future<String?> translate(String source, TranslateRequest request);

  /// 流式：每次发射「当前累计完整译文」（便于 UI 整体 setText）。
  ///
  /// 端侧引擎默认缓冲至校验通过后一次性发射（规格 §6.4）。
  Stream<String> translateStream(String source, TranslateRequest request);

  /// 批量：返回与 sources 等长列表，失败项用 null 占位，不影响其它项。
  Future<List<String?>> translateBatch(
    List<String> sources,
    TranslateRequest request,
  );

  /// 批量 + 完成即回调（用于图片翻译逐块上屏）。
  Future<List<String?>> translateBatchIncremental(
    List<String> sources,
    TranslateRequest request,
    void Function(int index, String? text) onUpdate,
  );

  /// 引擎可用性自检。
  Future<TestResult> testConnection(TranslateRequest request);

  /// 释放引擎资源；之后实例不可再用。
  Future<void> dispose();
}
