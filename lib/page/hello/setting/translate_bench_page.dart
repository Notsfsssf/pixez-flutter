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
 * this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 */

/// 端侧性能实验台。
///
/// 参考「自动调优」界面的思路，但只测一个线程数是不够的：端侧翻译的
/// 实际效率由四个维度共同决定——
///   批宽（一次并行推几段）、线程数、上下文容量、flash-attn。
/// 各维度的最优点因机型而异（大中小核拓扑、内存带宽、量化格式都影响），
/// 只能在**本机实测**，所以这里把四个维度都做成可测项：逐维扫描
/// （坐标下降），把每一点的耗时摆在同一张表里，最后给出实测最优组合。
library;

import 'package:bot_toast/bot_toast.dart';
// 注意：本项目把 Material 库换成了 material_ui 包（fluent 版要求），
// 必须从 material_ui 导入。用 package:flutter/material.dart 会拿到 SDK 的
// 另一份 Material：Theme.of 找不到本项目主题（退回浅色 fallback），
// Scaffold/AppBar 还会因为找不到 MaterialLocalizations 直接报红。
import 'package:material_ui/material_ui.dart';
import 'package:pixez/i18n.dart';
import 'package:translator/translator.dart';

import '../../../translation/translation_service.dart';

class TranslateBenchPage extends StatefulWidget {
  const TranslateBenchPage({Key? key}) : super(key: key);

  @override
  State<TranslateBenchPage> createState() => _TranslateBenchPageState();
}

class _TranslateBenchPageState extends State<TranslateBenchPage> {
  final List<LlmBenchPoint> _points = [];

  bool _running = false;
  String _stage = '';
  int _done = 0;
  int _total = 0;
  LlmTuning? _pending;
  LlmTuningScan? _result;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('性能实验台')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        children: [
          _buildIntro(scheme),
          const SizedBox(height: 12),
          _buildRunCard(scheme),
          // 「应用此配置」放在明细之上：测完最想点的就是它，十几行数据
          // 不该挡在按钮前面。
          if (_result?.best != null) ...[
            const SizedBox(height: 16),
            _buildBestCard(scheme, _result!.best!),
          ],
          if (_points.isNotEmpty) ...[
            const SizedBox(height: 16),
            _buildResultTable(scheme),
          ],
          const SizedBox(height: 24),
          Text(
            '提示：实测期间会反复重载 1GB 权重，设备明显发热、电量消耗快，'
            '建议接电源并保持亮屏。每个维度只测一次，结果有 ±5% 抖动，'
            '并列时优先选更省电（线程更少）的组合。',
            style: TextStyle(
              fontSize: 12,
              height: 1.5,
              color: scheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIntro(ColorScheme scheme) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.science_outlined, size: 18, color: scheme.primary),
              const SizedBox(width: 8),
              Text(
                '测什么',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: scheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '四个维度逐项实测，共 $_kPointCount 次加载 + 推理：\n'
            '· 批宽 1 / 2 / 4 / 8 段并行（影响总吞吐与首屏等待）\n'
            '· 线程 1 ~ 物理核数（超过大核数会被小核拖慢）\n'
            '· 上下文 4096 / 2048（省内存，但长页面可能超限）\n'
            '· flash-attn 开 / 关（CPU 实现，短文本通常更快的是关）',
            style: TextStyle(
              fontSize: 12.5,
              height: 1.6,
              color: scheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRunCard(ColorScheme scheme) {
    final progress = _total > 0 ? _done / _total : 0.0;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  _running
                      ? (_pending == null
                            ? '$_stage：$_done/$_total'
                            : '$_stage：$_done/$_total · ${_pending!.label}')
                      : '准备就绪',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: scheme.onSurface,
                  ),
                ),
              ),
              if (_running)
                Text(
                  '${(progress * 100).toStringAsFixed(0)}%',
                  style: TextStyle(
                    fontSize: 12,
                    color: scheme.onSurfaceVariant,
                  ),
                ),
            ],
          ),
          if (_running) ...[
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(3),
              child: LinearProgressIndicator(
                value: progress == 0 ? null : progress,
                minHeight: 6,
              ),
            ),
          ],
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  onPressed: _running ? null : _run,
                  icon: const Icon(Icons.play_arrow, size: 18),
                  label: Text(_result == null ? '开始实测' : '重新实测'),
                ),
              ),
              const SizedBox(width: 10),
              if (_points.isNotEmpty && !_running)
                OutlinedButton(
                  onPressed: _reset,
                  child: const Text('清空'),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildResultTable(ColorScheme scheme) {
    // 按「维度」分组展示：坐标下降的每组对应一个维度，这样用户能直接
    // 看出哪个参数真的有用，而不是面对 15 行无结构的数据。
    final best = _result?.best;
    return Container(
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(14),
      ),
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 6, 14, 8),
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Text(
                    '配置',
                    style: TextStyle(
                      fontSize: 11.5,
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    '段/分钟',
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      fontSize: 11.5,
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    '每段耗时',
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      fontSize: 11.5,
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
          ),
          for (final p in _points) _buildRow(scheme, p, best),
        ],
      ),
    );
  }

  Widget _buildRow(ColorScheme scheme, LlmBenchPoint p, LlmBenchPoint? best) {
    final isBest = identical(p, best);
    final failed = !p.isUsable;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
      color: isBest
          ? scheme.primary.withValues(alpha: 0.10)
          : Colors.transparent,
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Row(
              children: [
                if (isBest)
                  Padding(
                    padding: const EdgeInsets.only(right: 4),
                    child: Icon(
                      Icons.star_rounded,
                      size: 14,
                      color: scheme.primary,
                    ),
                  ),
                Expanded(
                  child: Text(
                    p.tuning.label,
                    style: TextStyle(
                      fontSize: 12,
                      color: failed ? scheme.error : scheme.onSurface,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              failed
                  ? '不可用'
                  : p.segmentsPerMin.toStringAsFixed(1),
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isBest ? FontWeight.w700 : FontWeight.w400,
                color: failed ? scheme.error : scheme.onSurface,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              failed ? '—' : '${p.msPerSegment.toStringAsFixed(0)}ms',
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: 12,
                color: scheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBestCard(ColorScheme scheme, LlmBenchPoint best) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: scheme.primaryContainer,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '实测最快组合',
            style: TextStyle(
              fontSize: 11.5,
              color: scheme.onPrimaryContainer.withValues(alpha: 0.75),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            best.tuning.label,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: scheme.onPrimaryContainer,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${best.segmentsPerMin.toStringAsFixed(1)} 段/分钟 · '
            '每段约 ${best.msPerSegment.toStringAsFixed(0)}ms · '
            '加载 ${best.loadMs}ms',
            style: TextStyle(
              fontSize: 12,
              color: scheme.onPrimaryContainer.withValues(alpha: 0.85),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: _running ? null : () => _apply(best),
              child: const Text('应用此配置'),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _run() async {
    if (_running) return;
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('开始实测'),
        content: const Text(
          '将依次测试批宽、线程、上下文、flash-attn 四个维度，'
          '共约 15 次模型重载与推理（3~6 分钟）。\n\n'
          '期间请勿切到其它页面翻译，设备会明显发热。',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(I18n.of(context).cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('开始'),
          ),
        ],
      ),
    );
    if (ok != true) return;

    setState(() {
      _running = true;
      _points.clear();
      _result = null;
      _done = 0;
      _total = 0;
      _stage = '准备';
      _pending = null;
    });
    try {
      final scan = await TranslationService.instance.benchmarkTunings(
        onPointStart: (done, total, stage, tuning) {
          if (!mounted) return;
          setState(() {
            _stage = stage;
            _done = done - 1; // 进度按「已完成」算，启动时不多算一格
            _total = total;
            _pending = tuning;
          });
        },
        onPointDone: (point) {
          if (!mounted) return;
          setState(() {
            _points.add(point);
            _done = _points.length;
            _pending = null;
          });
        },
      );
      if (!mounted) return;
      setState(() {
        _result = scan;
        _running = false;
        _pending = null;
      });
      await TranslationService.instance.settings.setLlmBenchSummary(
        scan.best == null
            ? '实测：无可用组合'
            : '实测 ${scan.best!.segmentsPerMin.toStringAsFixed(1)} 段/分钟'
                  '（${scan.best!.tuning.label}）',
      );
      if (scan.best == null) {
        BotToast.showText(text: '全部组合都失败了，请检查模型文件是否完整');
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _running = false;
        _pending = null;
      });
      BotToast.showText(text: '实测失败：$e');
    }
  }

  Future<void> _apply(LlmBenchPoint best) async {
    try {
      await TranslationService.instance.applyTuning(best.tuning);
      if (!mounted) return;
      BotToast.showText(
        text: '已应用：${best.tuning.label}',
      );
      Navigator.of(context).pop();
    } catch (e) {
      BotToast.showText(text: '应用失败：$e');
    }
  }

  void _reset() {
    setState(() {
      _points.clear();
      _result = null;
      _done = 0;
      _total = 0;
      _stage = '';
    });
  }
}

/// 一次完整扫描的点位数（4 批宽 + 4~6 线程 + 2 上下文 + 2 FA + 1 确认）。
/// 实际线程候选随核数变化，这里给设置页的提示文案用保守值。
const int _kPointCount = 15;
