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

/// OpenAI 兼容云端翻译引擎。
///
/// - 同样使用 Hy-MT2 官方 prompt 模板与九类输出校验（含去背景重试一次），
///   保证云端 / 端侧输出语义一致；
/// - SSE 流式解析逐行对齐参考 OpenAiStreamEventTest.kt；
/// - 默认缓冲（校验通过后整体上屏），逐 token 上屏需显式开启 [emitRawStream]；
/// - 超时 / HTTP 错误映射为 [TranslationException]；
/// - API key 只经构造参数传入（app 侧从 SharedPreferences 读取），不落日志。
library;

import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';

import '../model/translate_request.dart';
import 'hy_mt2_output_gate.dart';
import 'hy_mt2_prompt_policy.dart';
import 'translation_cache.dart';
import 'translator.dart';

// ---- SSE 流事件（对齐参考 OpenAiStreamEvent） ----

sealed class OpenAiStreamEvent {
  const OpenAiStreamEvent();
}

class SseIgnore extends OpenAiStreamEvent {
  const SseIgnore();
}

class SseKeepAlive extends OpenAiStreamEvent {
  const SseKeepAlive();
}

class SseDone extends OpenAiStreamEvent {
  const SseDone();
}

class SseData extends OpenAiStreamEvent {
  final String content;
  final String? finishReason;
  final ChatUsage? usage;

  const SseData({required this.content, this.finishReason, this.usage});

  @override
  bool operator ==(Object other) =>
      other is SseData &&
      other.content == content &&
      other.finishReason == finishReason &&
      other.usage == usage;

  @override
  int get hashCode => Object.hash(content, finishReason, usage);
}

class SseMalformed extends OpenAiStreamEvent {
  final String raw;

  const SseMalformed(this.raw);

  @override
  bool operator ==(Object other) => other is SseMalformed && other.raw == raw;

  @override
  int get hashCode => raw.hashCode;
}

/// token 用量。
class ChatUsage {
  final int promptTokens;
  final int completionTokens;
  final int totalTokens;

  const ChatUsage({
    required this.promptTokens,
    required this.completionTokens,
    required this.totalTokens,
  });

  @override
  bool operator ==(Object other) =>
      other is ChatUsage &&
      other.promptTokens == promptTokens &&
      other.completionTokens == completionTokens &&
      other.totalTokens == totalTokens;

  @override
  int get hashCode => Object.hash(promptTokens, completionTokens, totalTokens);
}

/// 单行 SSE 解析（对齐参考 parseOpenAiStreamLine 的表驱动语义）。
OpenAiStreamEvent parseOpenAiStreamLine(String line) {
  if (line.isEmpty) return const SseIgnore();
  if (line.startsWith(':')) return const SseKeepAlive();
  if (line.startsWith('event:')) return const SseIgnore();
  const doneMarker = 'data: [DONE]';
  if (line == doneMarker) return const SseDone();
  if (line.startsWith('data:')) {
    final payload = line.substring('data:'.length).trim();
    try {
      final json = jsonDecode(payload);
      if (json is! Map<String, dynamic>) return SseMalformed(line);
      final choices = json['choices'];
      String content = '';
      String? finishReason;
      ChatUsage? usage;
      if (choices is List && choices.isNotEmpty) {
        final first = choices.first;
        if (first is Map<String, dynamic>) {
          final delta = first['delta'];
          if (delta is Map<String, dynamic>) {
            content = delta['content'] as String? ?? '';
          }
          // 非流式响应（stream=false 直接回包）兼容 message.content
          final message = first['message'];
          if (content.isEmpty && message is Map<String, dynamic>) {
            content = message['content'] as String? ?? '';
          }
          finishReason = first['finish_reason'] as String?;
        }
      }
      final usageJson = json['usage'];
      if (usageJson is Map<String, dynamic>) {
        usage = ChatUsage(
          promptTokens: (usageJson['prompt_tokens'] as num?)?.toInt() ?? 0,
          completionTokens:
              (usageJson['completion_tokens'] as num?)?.toInt() ?? 0,
          totalTokens: (usageJson['total_tokens'] as num?)?.toInt() ?? 0,
        );
      }
      return SseData(
        content: content,
        finishReason: finishReason,
        usage: usage,
      );
    } on FormatException {
      return SseMalformed(line);
    }
  }
  return const SseIgnore();
}

/// OpenAI 兼容引擎配置。
class OpenAiCompatibleConfig {
  /// 例如 `https://api.example.com/v1`（不含尾斜杠）。
  final String baseUrl;

  /// API key；仅由 app 侧从 SharedPreferences 读取后传入，不写日志。
  final String apiKey;

  final String model;

  final Duration connectTimeout;
  final Duration receiveTimeout;

  /// 发送流式请求（SSE）。
  final bool preferStream;

  const OpenAiCompatibleConfig({
    required this.baseUrl,
    required this.apiKey,
    required this.model,
    this.connectTimeout = const Duration(seconds: 15),
    this.receiveTimeout = const Duration(seconds: 120),
    this.preferStream = true,
  });
}

/// OpenAI 兼容翻译引擎（/chat/completions）。
class OpenAiCompatibleTranslator implements Translator {
  final OpenAiCompatibleConfig config;
  final TranslationCache? cache;
  final Dio dio;

  /// 是否按 token 直接上屏（默认 false = 缓冲校验后整体上屏，规格 §6.4）。
  final bool emitRawStream;

  /// 单次输出的行数上限策略与端侧一致（背景模式）。
  final bool useHyMt2OutputGate;

  OpenAiCompatibleTranslator({
    required this.config,
    this.cache,
    Dio? dio,
    this.emitRawStream = false,
    this.useHyMt2OutputGate = true,
  }) : dio =
           dio ??
           Dio(
             BaseOptions(
               connectTimeout: config.connectTimeout,
               receiveTimeout: config.receiveTimeout,
               followRedirects: true,
               maxRedirects: 8,
             ),
           ) {
    if (this.dio.options.baseUrl.isEmpty) {
      this.dio.options.baseUrl = config.baseUrl;
    }
  }

  String buildUserPrompt(String source, TranslateRequest request) =>
      HyMt2PromptPolicy.build(source, request.targetLang, request.context);

  Map<String, String> _headers() => {
    'Authorization': 'Bearer ${config.apiKey}',
    'Content-Type': 'application/json',
  };

  Map<String, dynamic> _body(
    String userPrompt,
    TranslateRequest request, {
    required bool stream,
  }) => {
    'model': config.model,
    'messages': [
      if (request.systemPrompt != null && request.systemPrompt!.isNotEmpty)
        {'role': 'system', 'content': request.systemPrompt},
      {'role': 'user', 'content': userPrompt},
    ],
    'stream': stream,
    'max_tokens': request.maxNewTokens,
    'temperature': 0,
  };

  TranslationException _mapError(Object error) {
    if (error is TranslationException) return error;
    if (error is DioException) {
      final status = error.response?.statusCode;
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          return TranslationException('连接超时，请检查网络或代理设置', code: 'TIMEOUT');
        case DioExceptionType.badResponse:
          final body = error.response?.data?.toString() ?? '';
          return TranslationException(
            '云端接口返回错误（HTTP $status）：${_truncate(body)}',
            code: 'HTTP_${status ?? "UNKNOWN"}',
          );
        case DioExceptionType.cancel:
          return TranslationException('请求已取消', code: 'CANCELLED');
        default:
          return TranslationException('网络错误：${error.message}', code: 'NETWORK');
      }
    }
    return TranslationException('$error');
  }

  String _truncate(String s, [int max = 200]) =>
      s.length <= max ? s : '${s.substring(0, max)}…';

  /// 对单条输出做 Hy-MT2 校验（与端侧一致）。
  String? _validatedOrNull(String source, String rawOutput, String userPrompt) {
    final normalized = HyMt2OutputGate.normalize(source, rawOutput, userPrompt);
    final validation = HyMt2OutputGate.validate(source, normalized, userPrompt);
    if (validation is GeneratedAccepted) return normalized;
    if (validation is GeneratedRetryable) return validation.fallbackText;
    return null; // Rejected：置空（保留原文显示）
  }

  @override
  Future<String?> translate(String source, TranslateRequest request) async {
    if (source.trim().isEmpty) return null;
    final userPrompt = buildUserPrompt(source, request);
    try {
      final text = await _requestOnce(source, userPrompt, request);
      if (text == null) return null;
      final validated = _validatedOrNull(source, text, userPrompt);
      if (validated != null) return validated;
      // 拒绝 → 去背景重试一次
      final recoveryPrompt = HyMt2OutputGate.recoveryPrompt(
        source,
        userPrompt,
        request,
      );
      if (recoveryPrompt == null) return null;
      final retried = await _requestOnce(source, recoveryPrompt, request);
      return retried == null
          ? null
          : _validatedOrNull(source, retried, recoveryPrompt);
    } catch (e) {
      throw _mapError(e);
    }
  }

  Future<String?> _requestOnce(
    String source,
    String userPrompt,
    TranslateRequest request,
  ) async {
    final response = await dio.post<Map<String, dynamic>>(
      '/chat/completions',
      data: _body(userPrompt, request, stream: false),
      options: Options(headers: _headers(), responseType: ResponseType.json),
    );
    final data = response.data;
    if (data == null) return null;
    final choices = data['choices'];
    if (choices is! List || choices.isEmpty) return null;
    final first = choices.first;
    if (first is! Map<String, dynamic>) return null;
    final message = first['message'];
    if (message is! Map<String, dynamic>) return null;
    final content = message['content'];
    if (content is! String) return null;
    final trimmed = content.trim();
    return trimmed.isEmpty ? null : trimmed;
  }

  @override
  Stream<String> translateStream(
    String source,
    TranslateRequest request,
  ) async* {
    if (source.trim().isEmpty) return;
    final userPrompt = buildUserPrompt(source, request);

    final buffer = StringBuffer();
    try {
      final response = await dio.post<ResponseBody>(
        '/chat/completions',
        data: _body(userPrompt, request, stream: true),
        options: Options(
          headers: _headers(),
          responseType: ResponseType.stream,
        ),
      );
      final body = response.data;
      if (body == null) return;
      String pending = '';
      bool done = false;
      await for (final chunk in body.stream) {
        pending += utf8.decode(chunk, allowMalformed: true);
        final lines = pending.split('\n');
        pending = lines.removeLast(); // 最后一段可能不完整，留到下一块
        for (final rawLine in lines) {
          final line = rawLine.trimRight();
          final event = parseOpenAiStreamLine(line);
          if (event is SseData) {
            if (event.content.isNotEmpty) buffer.write(event.content);
            if (event.finishReason != null) done = true;
          } else if (event is SseDone) {
            done = true;
          } else if (event is SseMalformed) {
            throw TranslationException(
              '云端返回了无法解析的流数据：${_truncate(event.raw)}',
              code: 'SSE_MALFORMED',
            );
          }
          if (emitRawStream && buffer.isNotEmpty) {
            // streamValidated = false：逐 token 发射「当前累计完整译文」，
            // 渗透内容由调用方自行承担（默认关闭，规格 §6.4）。
            yield buffer.toString();
          }
          if (done) break;
        }
        if (done) break;
      }

      final generated = buffer.toString().trim();
      if (generated.isEmpty) return;
      final validated = _validatedOrNull(source, generated, userPrompt);
      if (validated != null) {
        yield emitRawStream ? generated : validated;
        return;
      }
      // 拒绝 → 去背景重试一次（缓冲）
      final recoveryPrompt = HyMt2OutputGate.recoveryPrompt(
        source,
        userPrompt,
        request,
      );
      if (recoveryPrompt == null) return;
      final retryBuffer = StringBuffer();
      await for (final piece in _streamOnce(
        retryBuffer,
        recoveryPrompt,
        request,
      )) {
        retryBuffer.write(piece);
      }
      final retried = retryBuffer.toString().trim();
      if (retried.isEmpty) return;
      final retryValidated = _validatedOrNull(source, retried, recoveryPrompt);
      if (retryValidated != null) yield retryValidated;
    } catch (e) {
      throw _mapError(e);
    }
  }

  Stream<String> _streamOnce(
    StringBuffer sink,
    String userPrompt,
    TranslateRequest request,
  ) async* {
    final response = await dio.post<ResponseBody>(
      '/chat/completions',
      data: _body(userPrompt, request, stream: true),
      options: Options(headers: _headers(), responseType: ResponseType.stream),
    );
    final body = response.data;
    if (body == null) return;
    String pending = '';
    bool done = false;
    await for (final chunk in body.stream) {
      pending += utf8.decode(chunk, allowMalformed: true);
      final lines = pending.split('\n');
      pending = lines.removeLast();
      for (final rawLine in lines) {
        final event = parseOpenAiStreamLine(rawLine.trimRight());
        if (event is SseData && event.content.isNotEmpty) {
          sink.write(event.content);
          yield event.content;
        } else if (event is SseDone) {
          done = true;
        }
        if (done) break;
      }
      if (done) break;
    }
  }

  @override
  Future<List<String?>> translateBatch(
    List<String> sources,
    TranslateRequest request,
  ) => translateBatchIncremental(sources, request, (_, __) {});

  @override
  Future<List<String?>> translateBatchIncremental(
    List<String> sources,
    TranslateRequest request,
    void Function(int index, String? text) onUpdate,
  ) async {
    final results = List<String?>.filled(sources.length, null);
    for (var index = 0; index < sources.length; index++) {
      final source = sources[index];
      if (source.trim().isEmpty) {
        onUpdate(index, null);
        continue;
      }
      try {
        results[index] = await translate(source, request);
      } on TranslationException {
        results[index] = null; // 单段失败不中断后续（规格 §4.1）
      }
      onUpdate(index, results[index]);
    }
    return results;
  }

  @override
  Future<TestResult> testConnection(TranslateRequest request) async {
    try {
      final response = await dio.post<Map<String, dynamic>>(
        '/chat/completions',
        data: {
          'model': config.model,
          'messages': [
            {'role': 'user', 'content': 'hi'},
          ],
          'max_tokens': 1,
          'stream': false,
        },
        options: Options(headers: _headers()),
      );
      final status = response.statusCode ?? 0;
      if (status >= 200 && status < 300) {
        return TestResult(
          success: true,
          message: '连接成功（HTTP $status, model=${config.model}）',
        );
      }
      return TestResult(success: false, message: 'HTTP $status');
    } catch (e) {
      final mapped = _mapError(e);
      return TestResult(success: false, message: mapped.message);
    }
  }

  @override
  Future<void> dispose() async {
    dio.close(force: true);
  }
}
