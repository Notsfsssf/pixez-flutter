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

/// 文本翻译管线：小说段落 / caption / 评论（无需 OCR）。
library;

import '../model/translate_request.dart';
import '../translate/text_splitter.dart';
import '../translate/translator.dart';

/// 文本翻译器（对 Translator 的轻封装）。
class TextTranslator {
  final Translator translator;

  TextTranslator({required this.translator});

  /// 单段翻译（caption / 评论）。空输入返回 null。
  Future<String?> translateText(String source, TranslateRequest request) =>
      translator.translate(source, request);

  /// 段落翻译：逐段上屏（长段落按块推进，每译完一块回调一次）；
  /// 整段失败的段落以 null 交给 [onParagraph]（UI 保留原文）。
  ///
  /// 返回与 [paragraphs] 等长的结果列表。上下文只注入**相邻段落**（见
  /// [_neighborContext]），逐段构建独立请求。
  Future<List<String?>> translateParagraphs(
    List<String> paragraphs,
    TranslateRequest baseRequest, {
    void Function(int index, String? text)? onParagraph,
    bool Function()? isCancelled,
  }) async {
    final results = List<String?>.filled(paragraphs.length, null);
    for (var index = 0; index < paragraphs.length; index++) {
      // 用户关掉翻译开关就停：整章几十段，没必跑完再丢。
      if (isCancelled?.call() ?? false) break;
      final paragraph = paragraphs[index];
      if (paragraph.trim().isEmpty) {
        onParagraph?.call(index, null);
        continue;
      }
      final others = _neighborContext(paragraphs, index);
      final request = TranslateRequest(
        sourceLang: baseRequest.sourceLang,
        targetLang: baseRequest.targetLang,
        maxNewTokens: baseRequest.maxNewTokens,
        systemPrompt: baseRequest.systemPrompt,
        retryFailedTranslation: baseRequest.retryFailedTranslation,
        useCache: baseRequest.useCache,
        context: RuntimePromptContext(
          currentApplication: baseRequest.context.currentApplication,
          glossary: baseRequest.context.glossary,
          currentPage: others,
        ),
      );
      // 长段落先切块：一段几千字时，要么 prompt 超上下文、要么输出被
      // maxNewTokens 截断后判不合格，两者都表现为「这一段没有译出内容」。
      final pieces = splitTextForModel(paragraph);
      if (pieces.isEmpty) {
        onParagraph?.call(index, null);
        continue;
      }
      final translatedPieces = <String>[];
      var failedPieces = 0;
      for (final piece in pieces) {
        if (isCancelled?.call() ?? false) break;
        String? translated;
        try {
          // 走非流式的 translate：段落级只需要「整块译完就上屏」，
          // 这条路径和简介/评论翻译完全一致（已在真机验证可用），
          // 不必依赖各家 OpenAI 兼容服务对 stream:true 的支持——
          // 自建 llama.cpp server / 旧版 vLLM 对 stream 直接 400。
          translated = await translator.translate(piece, request);
        } catch (_) {
          // 单块失败不能中断整段，更不能中断整章。
          translated = null;
        }
        if (translated == null || translated.isEmpty) {
          failedPieces++;
          // 失败块保留原文，避免整段凭空消失。
          translatedPieces.add(piece);
        } else {
          translatedPieces.add(translated);
        }
        // 逐块上屏：长段落的译文会一段段长出来，而不是等整段跑完。
        if (failedPieces < pieces.length) {
          onParagraph?.call(index, joinTranslatedPieces(translatedPieces));
        }
      }
      final value = failedPieces == pieces.length
          ? null
          : joinTranslatedPieces(translatedPieces);
      results[index] = value;
      onParagraph?.call(index, value);
    }
    return results;
  }

  /// 相邻段落数：前 2 段 + 后 2 段。
  static const int _kNeighborCount = 2;

  /// 单段上下文最多截取的字数（超出部分用省略号）。
  static const int _kNeighborChars = 120;

  /// 一次请求里上下文的总字数预算（含标题党长句时兜底）。
  static const int _kContextCharBudget = 360;

  /// 段落上下文：只取前后相邻段落，且限制单段长度与总字数。
  ///
  /// 为什么不能把整章塞进 `currentPage`：端侧上下文 4096，旧实现把本章
  /// 其余所有段落都当「同页文本」注入，一话 60~120 段时每段 prompt 都
  /// 接近整章长度，全部超限失败 → 小说翻译完全没反应。
  static List<String> _neighborContext(List<String> paragraphs, int index) {
    final result = <String>[];
    var budget = _kContextCharBudget;
    void take(int i) {
      if (i < 0 || i >= paragraphs.length || i == index) return;
      final text = paragraphs[i].trim();
      if (text.isEmpty) return;
      final piece = text.length <= _kNeighborChars
          ? text
          : '${text.substring(0, _kNeighborChars)}…';
      if (piece.length > budget) return;
      budget -= piece.length;
      result.add(piece);
    }

    // 先取前文（承接人称与语气更关键），再取后文。
    for (var d = _kNeighborCount; d >= 1; d--) {
      take(index - d);
    }
    for (var d = 1; d <= _kNeighborCount; d++) {
      take(index + d);
    }
    return result;
  }
}
