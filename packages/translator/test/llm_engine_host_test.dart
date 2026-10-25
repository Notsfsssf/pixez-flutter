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

/// LlmEngineHost 测试：空闲卸载（可注入时钟）、touch 重置、Error 自愈、
/// 单实例复用。验收对齐规格 §11 Phase 3 与 §7.2。
library;

import 'dart:async';

import 'package:test/test.dart';
import 'package:translator/src/engine/llm_engine_host.dart';

import 'fake_engine.dart';

void main() {
  group('空闲卸载', () {
    test('默认超时为 5 分钟（IDLE_TIMEOUT_MS = 5 * 60 * 1000）', () {
      expect(LlmEngineHost.defaultIdleTimeout, const Duration(minutes: 5));
      expect(LlmEngineHost.defaultIdleTimeout.inMilliseconds, 5 * 60 * 1000);
    });

    test('空闲超时后触发一次 unload（可注入短超时验证逻辑）', () async {
      var fakeNow = 1000;
      final engine = FakeEngine()..defaultResponse = 'ok';
      final logs = <String>[];
      final host = LlmEngineHost(
        engineFactory: () => engine,
        modelPathProvider: () => '/models/test.gguf',
        idleTimeout: const Duration(milliseconds: 50),
        clockMs: () => fakeNow,
        onLog: logs.add,
      );

      await host.generate('你好', maxTokens: 8);
      expect(engine.loadCount, 1);
      expect(engine.cleanUpCount, 0);

      // 快进时钟并等待真实 Timer 到点
      fakeNow += 100;
      await Future<void>.delayed(const Duration(milliseconds: 120));
      expect(engine.cleanUpCount, 1, reason: '空闲 100ms >= 50ms 超时 → unload');
      expect(
        logs.any(
          (l) => l.contains('perf> llm idle') && l.contains('unloading'),
        ),
        isTrue,
        reason: '日志: perf> llm idle ... unloading',
      );
      expect(logs.contains('perf> llm unloaded'), isTrue);
      await host.shutdown();
    });

    test('touch 重置空闲计时，不误触发卸载', () async {
      var fakeNow = 1000;
      final engine = FakeEngine()..defaultResponse = 'ok';
      final host = LlmEngineHost(
        engineFactory: () => engine,
        modelPathProvider: () => '/models/test.gguf',
        idleTimeout: const Duration(milliseconds: 60),
        clockMs: () => fakeNow,
      );

      await host.generate('你好', maxTokens: 8);
      // 30ms 后 touch（重置计时），再过 30ms —— 距 touch 仅 30ms < 60ms
      fakeNow += 30;
      await host.touch();
      fakeNow += 30;
      await Future<void>.delayed(const Duration(milliseconds: 130));
      expect(engine.cleanUpCount, 0, reason: 'touch 重置后不应卸载');
      await host.shutdown();
    });

    test('unload 后再次请求会重新加载（只 cleanUp 不 destroy）', () async {
      var fakeNow = 1000;
      final engine = FakeEngine()..defaultResponse = '一';
      final host = LlmEngineHost(
        engineFactory: () => engine,
        modelPathProvider: () => '/models/test.gguf',
        idleTimeout: const Duration(milliseconds: 40),
        clockMs: () => fakeNow,
      );

      await host.generate('一', maxTokens: 4);
      fakeNow += 50;
      await Future<void>.delayed(const Duration(milliseconds: 100));
      expect(engine.cleanUpCount, 1);

      engine.enqueue('二');
      final result = await host.generate('二', maxTokens: 4);
      expect(result, '二');
      expect(engine.loadCount, 2, reason: '卸载后重新加载权重');
      expect(
        engine.cleanUpCount,
        1,
        reason: 'fast-path 复用 engine 实例，不额外 cleanUp',
      );
      await host.shutdown();
    });
  });

  group('加载与自愈', () {
    test('模型未安装时抛 LlmModelNotReadyException', () async {
      final host = LlmEngineHost(
        engineFactory: FakeEngine.new,
        modelPathProvider: () => null,
      );
      await expectLater(
        host.generate('x', maxTokens: 1),
        throwsA(isA<LlmModelNotReadyException>()),
      );
      await host.shutdown();
    });

    test('加载失败后进入 Error 态，下次先 cleanUp 自愈', () async {
      final engine = _FailingLoadEngine();
      final host = LlmEngineHost(
        engineFactory: () => engine,
        modelPathProvider: () => '/models/test.gguf',
      );
      await expectLater(
        host.generate('x', maxTokens: 1),
        throwsA(isA<LlmModelNotReadyException>()),
      );
      expect(engine.state, LlmEngineState.error);

      engine.failLoad = false;
      engine.enqueue('ok');
      final result = await host.generate('x', maxTokens: 1);
      expect(result, 'ok');
      expect(engine.cleanUpCount, 1, reason: 'Error 态先 cleanUp 自愈');
      // loadCount 只在 loadModel 成功路径计数（_FailingLoadEngine 失败时直接抛出）
      expect(engine.loadCount, 1);
      await host.shutdown();
    });

    test('并发请求排队串行执行（推理强制串行）', () async {
      final engine = FakeEngine();
      engine.defaultResponse = 'ok';
      final host = LlmEngineHost(
        engineFactory: () => engine,
        modelPathProvider: () => '/models/test.gguf',
      );

      final results = await Future.wait([
        for (var i = 0; i < 5; i++) host.generate('p$i', maxTokens: 2),
      ]);
      expect(results, List.filled(5, 'ok'));
      expect(engine.loadCount, 1, reason: '并发请求共享一次加载');
      expect(engine.prompts, [
        'p0',
        'p1',
        'p2',
        'p3',
        'p4',
      ], reason: '队列保持提交顺序');
      await host.shutdown();
    });

    test('状态流按序发射 loading / ready', () async {
      final engine = FakeEngine();
      final host = LlmEngineHost(
        engineFactory: () => engine,
        modelPathProvider: () => '/models/test.gguf',
      );
      final states = <LlmEngineState>[];
      final sub = host.state.listen(states.add);
      engine.enqueue('ok');
      await host.generate('x', maxTokens: 1);
      await Future<void>.delayed(Duration.zero);
      expect(states.contains(LlmEngineState.loading), isTrue);
      expect(states.contains(LlmEngineState.ready), isTrue);
      await sub.cancel();
      await host.shutdown();
    });
  });

  group('自动线程调优', () {
    test('threadsProvider 提供的线程数会透传给 loadModel', () async {
      final engine = FakeEngine()..defaultResponse = 'ok';
      final host = LlmEngineHost(
        engineFactory: () => engine,
        modelPathProvider: () => '/models/test.gguf',
        threadsProvider: () => 3,
      );
      await host.generate('x', maxTokens: 1);
      expect(engine.threadsSeen, [3]);
      await host.shutdown();
    });

    test('逐候选加载实测，选出最快线程数', () async {
      var fakeNow = 0;
      final engine = _TimedEngine()..defaultResponse = 'abcde';
      engine.fakeNowAdvance = (ms) => fakeNow += ms;
      final host = LlmEngineHost(
        engineFactory: () => engine,
        modelPathProvider: () => '/models/test.gguf',
        clockMs: () => fakeNow,
      );
      // 模拟 1/2/4 线程速度：5 token × 每 token 虚拟耗时
      // 100/50/40ms → 10 / 20 / 25 tok/s，最优 4 线程。
      engine.perTokenMs = () => switch (engine.threadsSeen.last) {
            1 => 100,
            2 => 50,
            _ => 40,
          };
      final started = <int>[];
      final report = await host.benchmarkThreads(
        candidates: [1, 2, 4],
        prompt: 'p',
        maxTokens: 5,
        onCandidateStart: (threads, _, __) => started.add(threads),
      );
      expect(engine.threadsSeen, [1, 2, 4],
          reason: '每个候选都用指定线程数重新加载');
      expect(started, [1, 2, 4], reason: 'onCandidateStart 按序回调');
      expect(report.points.map((p) => p.threads), [1, 2, 4]);
      expect(report.bestThreads, 4);
      expect(
        report.points.last.tokensPerSec,
        closeTo(25.0, 0.1),
        reason: '5 token / 200ms = 25 tok/s',
      );
      // benchmark 是重负载操作，结束释放权重（finally cleanUp）。
      expect(engine.cleanUpCount, greaterThanOrEqualTo(1));
      await host.shutdown();
    });

    test('速度相同（±2% 容差内）取线程数少者', () async {
      var fakeNow = 0;
      final engine = _TimedEngine()..defaultResponse = 'abcde';
      engine.fakeNowAdvance = (ms) => fakeNow += ms;
      final host = LlmEngineHost(
        engineFactory: () => engine,
        modelPathProvider: () => '/models/test.gguf',
        clockMs: () => fakeNow,
      );
      engine.perTokenMs = () => 50; // 所有候选同速
      final report = await host.benchmarkThreads(
        candidates: [2, 4, 8],
        prompt: 'p',
        maxTokens: 5,
      );
      expect(report.bestThreads, 2, reason: '同速选线程数少者（省电少发热）');
      await host.shutdown();
    });
  });
}

/// 按线程数差异化推进虚拟时钟的测试引擎（benchmark 测速用）。
class _TimedEngine extends FakeEngine {
  /// 每次 generateStream 调用时读取：每收到一个 token 推进多少虚拟毫秒。
  int Function()? perTokenMs;

  @override
  Stream<String> generateStream(
    String prompt, {
    required int maxTokens,
  }) async* {
    final cost = perTokenMs?.call() ?? 0;
    await for (final token in super.generateStream(prompt, maxTokens: maxTokens)) {
      fakeNowAdvance(cost);
      yield token;
    }
  }

  /// 由测试注入的时钟推进函数；默认空实现（不接时钟的用例）。
  void Function(int ms) fakeNowAdvance = (_) {};
}

class _FailingLoadEngine extends FakeEngine {
  bool failLoad = true;

  @override
  Future<void> loadModel(
    String modelPath, {
    required int contextSize,
    int? threads,
    bool flashAttn = false,
  }) async {
    if (failLoad) {
      state = LlmEngineState.error;
      throw StateError('GGUF 损坏');
    }
    await super.loadModel(
      modelPath,
      contextSize: contextSize,
      threads: threads,
      flashAttn: flashAttn,
    );
  }
}
