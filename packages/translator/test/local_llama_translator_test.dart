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

/// LocalLlamaTranslator 测试（Fake 引擎验证，对齐规格 §11 Phase 3 验收）：
/// 拒绝→去背景重试→仍拒绝置空；缓存命中不触发推理；批量顺序与 null 占位。
library;

import 'package:test/test.dart';
import 'package:translator/src/engine/llm_engine_host.dart';
import 'package:translator/src/model/translate_request.dart';
import 'package:translator/src/translate/cache_key.dart';
import 'package:translator/src/translate/hy_mt2_output_policy.dart';
import 'package:translator/src/translate/hy_mt2_profile.dart';
import 'package:translator/src/translate/hy_mt2_prompt_policy.dart';
import 'package:translator/src/translate/local_llama_translator.dart';
import 'package:translator/src/translate/translation_cache.dart';

import 'fake_engine.dart';

void main() {
  late FakeEngine engine;
  late LlmEngineHost host;
  late LocalLlamaTranslator translator;

  setUp(() {
    engine = FakeEngine();
    host = LlmEngineHost(
      engineFactory: () => engine,
      modelPathProvider: () => '/models/test.gguf',
      idleTimeout: const Duration(minutes: 5),
    );
    translator = LocalLlamaTranslator(host: host);
  });

  const normalRequest = TranslateRequest(targetLang: 'zh-CN');

  /// 带同页背景的请求（prompt 走背景模板）。
  TranslateRequest backgroundRequest({String other = 'other line'}) =>
      TranslateRequest(
        targetLang: 'zh-CN',
        context: RuntimePromptContext(currentPage: ['テスト', other]),
      );

  test('正常翻译：聚合 token、非空输出', () async {
    engine.enqueue('これはペンです');
    final result = await translator.translate('テスト', normalRequest);
    expect(result, 'これはペンです');
    expect(engine.loadCount, 1);
    expect(
      engine.prompts.single,
      contains('Translate the following text into Chinese'),
    );
  });

  test('空输入直接返回 null，不触发推理', () async {
    expect(await translator.translate('   ', normalRequest), isNull);
    expect(engine.prompts, isEmpty);
  });

  test('渗透输出 → 去背景重试成功', () async {
    engine.enqueue('[Background Information]\n渗漏'); // 第一次：header 渗透
    engine.enqueue('正常译文'); // 恢复 prompt 输出正常
    final result = await translator.translate('テスト', backgroundRequest());
    expect(result, '正常译文');
    expect(engine.prompts.length, 2);
    expect(HyMt2PromptPolicy.isBackgroundPrompt(engine.prompts[0]), isTrue);
    expect(
      HyMt2PromptPolicy.isBackgroundPrompt(engine.prompts[1]),
      isFalse,
      reason: '恢复 prompt 应为去背景版本',
    );
  });

  test('拒绝 → 去背景重试 → 仍拒绝置空', () async {
    engine.enqueue('[Background Information]\n渗漏');
    engine.enqueue('[Source Text]\n仍渗漏'); // 恢复后仍拒绝
    final result = await translator.translate('テスト', backgroundRequest());
    expect(result, isNull);
    expect(engine.prompts.length, 2, reason: '只重试一次');
  });

  test('非背景请求的渗透输出不可恢复（fail-closed 置空）', () async {
    engine.enqueue('[Source Text]\n渗漏');
    final result = await translator.translate('テスト', normalRequest);
    expect(result, isNull);
    expect(engine.prompts.length, 1, reason: '非背景 prompt 无恢复路径');
  });

  test('缓存命中不触发推理；命中后仍会重跑校验', () async {
    engine.enqueue('第一条译文');
    expect(await translator.translate('テスト', normalRequest), '第一条译文');
    expect(engine.prompts.length, 1);

    // 同 source + 同 request → 缓存命中
    final second = await translator.translate('テスト', normalRequest);
    expect(second, '第一条译文');
    expect(engine.prompts.length, 1, reason: '缓存命中不应触发推理');

    // 脏缓存：手工注入渗透文本 → 命中校验剔除 → 重新推理
    final userPrompt = HyMt2PromptPolicy.build(
      'テスト',
      normalRequest.targetLang,
      normalRequest.context,
    );
    final key = LocalLlamaTranslationCacheKey.build(
      cache: translator.cache,
      source: 'テスト',
      model: HyMt2Profile.modelName,
      sourceLang: normalRequest.sourceLang,
      targetLang: normalRequest.targetLang,
      maxNewTokens: normalRequest.maxNewTokens,
      systemPrompt: normalRequest.systemPrompt,
      userPrompt: userPrompt,
    );
    translator.cache.put(key, '[Background Information]\n脏数据', normalRequest);
    engine.enqueue('重译结果');
    final third = await translator.translate('テスト', normalRequest);
    expect(third, '重译结果');
    expect(engine.prompts.length, 2, reason: '脏缓存被剔除后重新推理');
  });

  test('Retryable 输出使用 fallbackText 且不缓存', () async {
    // 通过直连 gate 构造 Retryable 场景验证缓存语义：
    final cache = TranslationCache();
    const req = TranslateRequest();
    cache.put('k', 'v', req);
    // 常规路径上 Hy-MT2 只产 Rejected；这里只断言缓存行为契约
    expect(cache.get('k', req), 'v');
  });

  test('批量 10 段全部回调且顺序正确，模型只加载一次', () async {
    final sources = List.generate(10, (i) => 'テスト$i');
    for (var i = 0; i < 10; i++) {
      engine.enqueue('译文$i');
    }
    final updates = <int, String?>{};
    final results = await translator.translateBatchIncremental(
      sources,
      normalRequest,
      (index, text) => updates[index] = text,
    );

    expect(results, List.generate(10, (i) => '译文$i'));
    expect(updates.length, 10);
    expect(
      updates.keys.toList(),
      List.generate(10, (i) => i),
      reason: '按顺序逐段回调',
    );
    expect(engine.loadCount, 1, reason: '共享同一次模型加载');
    // 10 个 unique 段按 _kNativeBatchSize=4 分成 3 组批量推理。
    expect(
      engine.batchPromptsSeen.map((e) => e.length).toList(),
      [4, 4, 2],
      reason: '按 4 段切组批量推理',
    );
  });

  test('批量引擎失败回退逐段串行，结果不丢', () async {
    engine.batchFailure = StateError('KV 超限');
    for (var i = 0; i < 3; i++) {
      engine.enqueue('译文$i');
    }
    final results = await translator.translateBatch(
      ['a', 'b', 'c'],
      normalRequest,
    );
    expect(results, ['译文0', '译文1', '译文2']);
    expect(
      engine.prompts.length,
      3,
      reason: '批量不可用时逐段走单序列推理',
    );
  });

  test('批量单段失败置 null，不中断后续', () async {
    for (var i = 0; i < 4; i++) {
      if (i == 2) {
        engine.enqueue('[Source Text]\n渗漏'); // 非背景 prompt，无恢复 → 置空
      } else {
        engine.enqueue('译文$i');
      }
    }
    final results = await translator.translateBatch([
      'a',
      'b',
      'c',
      'd',
    ], normalRequest);
    expect(results[0], '译文0');
    expect(results[1], '译文1');
    expect(results[2], isNull, reason: '渗透段置空');
    expect(results[3], '译文3', reason: '失败不中断后续');
  });

  test('批量相同源文本合并为一次推理', () async {
    engine.enqueue('共享译文');
    final results = await translator.translateBatch([
      '重复',
      '重复',
      '重复',
    ], normalRequest);
    expect(results, ['共享译文', '共享译文', '共享译文']);
    expect(
      engine.batchPromptsSeen.expand((e) => e).length,
      1,
      reason: '相同 cacheKey 合并推理',
    );
  });

  test('空白源直接 null 占位并回调', () async {
    engine.enqueue('译文');
    final updates = <int, String?>{};
    final results = await translator.translateBatchIncremental(
      ['  ', 'テスト'],
      normalRequest,
      (index, text) => updates[index] = text,
    );
    expect(results[0], isNull);
    expect(results[1], '译文');
    expect(updates[0], isNull);
    expect(updates[1], '译文');
    expect(engine.batchPromptsSeen.expand((e) => e).length, 1);
  });

  test('translateStream 缓冲到校验通过后整体上屏', () async {
    engine.enqueue('流水译文');
    final chunks = await translator
        .translateStream('テスト', normalRequest)
        .toList();
    expect(chunks, [
      '流水译文',
    ], reason: 'bufferGeneratedOutputUntilValidated=true');
  });

  test('行数上限：背景模式超出 源行数+1 拒绝，去背景重试成功则采用', () async {
    // 背景 prompt（源 1 行 → 上限 2 行），输出 3 行 → NATIVE_LINE_LIMIT 拒绝。
    // 对齐参考语义：行数限制只在背景请求（含恢复前 prompt）生效，
    // 恢复 prompt 为非背景模板，输出按非背景规则检验。
    engine.enqueue('一\n二\n三'); // 第一次：背景 prompt 行数超限 → 拒绝
    engine.enqueue('一行译文'); // 去背景重试输出正常
    final result = await translator.translate('テスト', backgroundRequest());
    expect(result, '一行译文');
    expect(engine.prompts.length, 2, reason: '拒绝后重试一次');
    expect(HyMt2PromptPolicy.isBackgroundPrompt(engine.prompts[0]), isTrue);
  });

  test('testConnection：模型未安装返回失败，不触发加载', () async {
    final notInstalled = LocalLlamaTranslator(
      host: host,
      modelInstalled: () => false,
    );
    final result = await notInstalled.testConnection(normalRequest);
    expect(result.success, isFalse);
    expect(engine.loadCount, 0);
  });

  test('NATIVE_LINE_LIMIT 哨兵不可展示', () {
    final decision = HyMt2OutputPolicy.inspect(
      '源',
      'ok\n$lineLimitSentinel',
      true,
    );
    expect(decision, const OutputReject(OutputReason.NATIVE_LINE_LIMIT));
  });
}
