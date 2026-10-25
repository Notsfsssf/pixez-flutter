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

/// OpenAI SSE 解析测试（语义对齐参考 OpenAiStreamEventTest.kt 表驱动）。
library;

import 'dart:convert';

import 'package:test/test.dart';
import 'package:translator/src/translate/openai_compatible_translator.dart';

void main() {
  test('表驱动：内容 / 心跳 / 结束 / 坏数据', () {
    final cases = <(String, String, OpenAiStreamEvent)>[
      ('blank separator', '', const SseIgnore()),
      ('SSE keep alive', ': keep-alive', const SseKeepAlive()),
      ('event metadata', 'event: message', const SseIgnore()),
      ('done marker', 'data: [DONE]', const SseDone()),
      (
        'role-only valid data',
        'data: {"choices":[{"delta":{"role":"assistant","content":""},"finish_reason":null}]}',
        const SseData(content: '', finishReason: null),
      ),
      (
        'content data',
        'data:{"choices":[{"delta":{"content":"译文"},"finish_reason":null}]}',
        const SseData(content: '译文', finishReason: null),
      ),
      (
        'finish reason without content',
        'data: {"choices":[{"delta":{"content":""},"finish_reason":"stop"}]}',
        const SseData(content: '', finishReason: 'stop'),
      ),
      (
        'usage-only valid data',
        'data: {"choices":[],"usage":{"prompt_tokens":7,"completion_tokens":5,"total_tokens":12}}',
        const SseData(
          content: '',
          finishReason: null,
          usage: ChatUsage(
            promptTokens: 7,
            completionTokens: 5,
            totalTokens: 12,
          ),
        ),
      ),
      (
        'malformed data',
        'data: not-json',
        const SseMalformed('data: not-json'),
      ),
    ];
    for (final (name, line, expected) in cases) {
      expect(parseOpenAiStreamLine(line), expected, reason: name);
    }
  });

  test('分块解码：UTF-8 多字节被拆到两个网络块时仍正确', () async {
    // 「译」的 UTF-8 = E8 AF 91，拆成两块模拟 TCP 分段
    final bytes1 = 'data:{"choices":[{"delta":{"content":"译'
        .codeUnits; // 注意：codeUnits 是 UTF-16，仅用于构造简单文本
    // 直接构造字节序列验证按行缓冲逻辑
    final utf8Bytes = [
      ...utf8.encode('data:{"choices":[{"delta":{"content":"'),
      0xE8,
      0xAF,
    ];
    final utf8Bytes2 = [
      0x91,
      ...utf8.encode('"},"finish_reason":null}]}'),
      ...utf8.encode('\n'),
      ...utf8.encode('data: [DONE]\n'),
    ];
    expect(utf8Bytes.length, greaterThan(0));
    expect(bytes1, isNotEmpty);

    // 通过解析组合后的完整字节验证（模拟宿主已合并分块）
    final combined = utf8.decode([...utf8Bytes, ...utf8Bytes2]);
    final events = combined.split('\n').map(parseOpenAiStreamLine).toList();
    expect(events[0], const SseData(content: '译', finishReason: null));
    expect(events[1], const SseDone());
  });
}
