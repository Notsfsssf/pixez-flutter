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

/// 翻译设置页（规格 §8.5）：引擎 / 语言 / OCR / 模型下载管理 / 云端 / 上下文 / 缓存。
///
/// - 设置读写走 [TranslationSettings]（手写 Observable，Observer 局部刷新）；
/// - 模型下载走 [ModelDownloadService]（断点续传 / 取消保留 `.tmp` / GGUF 校验），
///   所选下载源失败仅提示、由用户手动切换，不自动静默切换（规格 §9.2-5）；
/// - `high` / `original` 分辨率首次选择弹一次性内存警告
///   （`translation_ocr_high_res_warned`）；
/// - API key 输入框用密码遮蔽，且不写日志（规格 §12）。
library;

import 'dart:async';

import 'package:bot_toast/bot_toast.dart';
import 'dart:io' show Platform;

import 'package:file_picker/file_picker.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:material_ui/material_ui.dart';
import 'package:translator/translator.dart';
import 'package:url_launcher/url_launcher_string.dart';

import 'package:pixez/i18n.dart';
import 'package:pixez/page/hello/setting/setting_quality_page.dart';
import 'package:pixez/page/hello/setting/translate_bench_page.dart';
import 'package:pixez/src/generated/i18n/app_localizations.dart';
import 'package:pixez/translation/cloud_endpoint.dart';
import 'package:pixez/translation/local_network_permission.dart';
import 'package:pixez/translation/model_download_service.dart';
import 'package:pixez/translation/platform_support.dart';
import 'package:pixez/translation/translation_service.dart';
import 'package:pixez/translation/translation_settings.dart';

/// 端侧推理后端未编译启用时的提示
/// （`--dart-define=TRANSLATOR_LOCAL_LLM=1` 可开启，见 README 已知限制）。
const String _kLocalBackendDisabledHint =
    '端侧推理后端未编译启用（TRANSLATOR_LOCAL_LLM=1），建议改用云端引擎';

/// 模型已安装但端侧后端未编译时：安装与可用是两回事，提前告知用户。
const String _kLocalBackendDisabledWithModelHint =
    '模型已安装；端侧推理后端未编译启用（TRANSLATOR_LOCAL_LLM=1），'
    '本地翻译暂不可用，请改用云端引擎';

/// 端侧模型不可用时的原因。文案实体在 translation/platform_support：
/// 设置页副标题、点击弹窗、内核判定必须说同一件事，否则会出现
/// 「副标题说 32 位、弹窗说未适配」这种自相矛盾。
String _localAbiUnsupportedHint() => localTranslationUnsupportedReason();

/// PP-OCRv5 第二 OCR 引擎待接入（规格 D4：留接口）。
const String _kPaddleNotReadyHint = 'PP-OCRv5 引擎待接入，当前请使用 ML Kit';

/// 线程数下拉项：index 0 = 默认（llama.cpp 恒 4），index i = i 个线程。
const List<String> _kThreadChoices = ['默认', '1', '2', '3', '4', '5', '6', '7', '8'];

/// 批量大小下拉项：0 = 默认（4 段并行），其余为直选的段数。
/// 上限 8 与 llama_shim 的多序列上限一致。
const List<int> _kBatchChoices = [0, 1, 2, 4, 8];
const List<String> _kBatchLabels = ['默认', '1（串行）', '2', '4', '8'];

class SettingTranslatePage extends StatefulWidget {
  const SettingTranslatePage({Key? key}) : super(key: key);

  @override
  State<SettingTranslatePage> createState() => _SettingTranslatePageState();
}

class _SettingTranslatePageState extends State<SettingTranslatePage> {
  final ModelDownloadService _downloadService = ModelDownloadService();
  StreamSubscription<ModelDownloadState>? _downloadSub;

  TranslationSettings? _settings;
  bool _modelInstalled = false;
  bool _testing = false;
  ModelDownloadPhase _phase = ModelDownloadPhase.idle;
  int _downloaded = 0;
  int _total = ModelDownloadState.hyMt2SizeBytes;
  String? _downloadMessage;

  /// 本次会话是否已经提示过「设备未适配」。
  /// 每进一次设置页都弹会烦；完全不弹又会让用户对着灰掉的模型区块乱猜。
  static bool _adaptationNoticeShown = false;

  @override
  void initState() {
    super.initState();
    TranslationService.instance.ensureInitialized().then((_) {
      if (!mounted) return;
      setState(() {
        _settings = TranslationService.instance.settings;
      });
      _maybeShowAdaptationNotice();
    });
    _refreshInstalled();
  }

  /// 非 Android 客户端（iOS / macOS / Windows / Linux / Web）目前没有端侧
  /// 推理后端：进页面时说明一次，别让用户以为是自己没下模型。
  void _maybeShowAdaptationNotice() {
    if (_adaptationNoticeShown || Platform.isAndroid) return;
    _adaptationNoticeShown = true;
    // 等首帧：initState 阶段还没有可用的 Navigator/MaterialLocalizations。
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) showDeviceNotAdaptedDialog(context);
    });
  }

  @override
  void dispose() {
    _downloadSub?.cancel();
    super.dispose();
  }

  Future<void> _refreshInstalled() async {
    final installed = await _downloadService.isInstalled();
    if (!mounted) return;
    setState(() => _modelInstalled = installed);
  }

  /// 本地引擎副标题：32 位设备 > 未编译 > 已装/未装，按优先级取提示。
  String _localEngineSubtitle(AppLocalizations i18n) {
    if (!kLocalLlmAbiSupported) return _localAbiUnsupportedHint();
    if (_modelInstalled) {
      return kTranslatorLocalLlmEnabled
          ? i18n.translation_model_installed
          : _kLocalBackendDisabledWithModelHint;
    }
    return kTranslatorLocalLlmEnabled
        ? i18n.translation_model_missing
        : _kLocalBackendDisabledHint;
  }

  @override
  Widget build(BuildContext context) {
    final i18n = I18n.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(i18n.translation)),
      body: _settings == null
          ? const Center(child: CircularProgressIndicator())
          : Observer(
              builder: (context) =>
                  ListView(children: _buildItems(context, _settings!)),
            ),
    );
  }

  List<Widget> _buildItems(BuildContext context, TranslationSettings s) {
    final i18n = I18n.of(context);
    // 端侧模型只为 Android 64 位编译（原生库 + 构建链路都在 android/ 下）。
    // 不可用时整块「模型」设置禁用：放行只会让用户下完 1GB 权重才发现跑不起来。
    final localUsable = isLocalTranslationAdapted;
    return [
      // ── 引擎 ──
      ListTile(
        leading: const Icon(Icons.swap_horiz),
        title: Text(i18n.translation_engine),
        // 没有本地后端时只剩云端，下拉留着会点出一个空菜单，改成静态文本。
        trailing: localUsable
            ? SettingSelectMenu(
                index: s.engine.index,
                items: [
                  i18n.translation_engine_local,
                  i18n.translation_engine_cloud,
                ],
                onChange: (index) =>
                    s.setEngine(TranslationEngineType.values[index]),
              )
            : Text(
                i18n.translation_engine_cloud,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
      ),
      ListTile(
        leading: const Icon(Icons.memory),
        title: Text(i18n.translation_engine_local),
        subtitle: Text(_localEngineSubtitle(i18n)),
        enabled: localUsable,
      ),
      if (!localUsable) _buildLocalUnavailableBanner(context),
      _buildModelDownloadTile(context, i18n, enabled: localUsable),
      ListTile(
        leading: const Icon(Icons.upload_file),
        title: Text(i18n.translation_model_import),
        enabled: localUsable,
        onTap: localUsable ? _importModel : null,
      ),
      // ── 端侧性能 ──
      ListTile(
        leading: const Icon(Icons.speed),
        title: const Text('推理线程数'),
        subtitle: Text(_threadsSubtitle(s)),
        enabled: localUsable,
        trailing: _disableWhen(
          !localUsable,
          SettingSelectMenu(
            index: s.llmThreads.clamp(0, 8),
            items: _kThreadChoices,
            onChange: (index) => s.setLlmThreads(index),
          ),
        ),
      ),
      ListTile(
        leading: const Icon(Icons.grid_view_rounded),
        title: const Text('批量大小'),
        subtitle: Text(_batchSubtitle(s)),
        enabled: localUsable,
        trailing: _disableWhen(
          !localUsable,
          SettingSelectMenu(
            index: _kBatchChoices.indexWhere((e) => e == s.llmBatch).clamp(0, 4),
            items: _kBatchLabels,
            onChange: (index) => s.setLlmBatch(_kBatchChoices[index]),
          ),
        ),
      ),
      ListTile(
        leading: const Icon(Icons.science_outlined),
        title: const Text('性能实验台'),
        subtitle: Text(
          s.llmBenchSummary.isEmpty
              ? '本机实测批宽 / 线程 / 上下文 / flash-attn，自动选出最快组合'
              : s.llmBenchSummary,
        ),
        enabled: localUsable,
        trailing: const Icon(Icons.chevron_right, size: 18),
        onTap: localUsable ? _openBench : null,
      ),
      ListTile(
        leading: const Icon(Icons.dns),
        title: Text(i18n.translation_model_mirror),
        enabled: localUsable,
        trailing: _disableWhen(
          !localUsable,
          SettingSelectMenu(
            index: s.modelMirror.index,
            items: [
              'huggingface.co',
              'hf-mirror.com',
              'modelscope.cn',
              'hf-mirror.net',
              i18n.translation_model_mirror_custom,
            ],
            onChange: (index) => _onMirrorChanged(ModelMirror.values[index]),
          ),
        ),
      ),
      SwitchListTile(
        secondary: const Icon(Icons.bolt),
        title: Text(i18n.translation_model_direct),
        subtitle: Text(i18n.translation_model_direct_desc),
        value: s.modelDirectDownload,
        // null = 禁用（SwitchListTile 没有 enabled 参数）
        onChanged: localUsable ? (v) => s.setModelDirectDownload(v) : null,
      ),
      const Divider(),
      // ── 语言 ──
      _buildLanguageTile(
        context,
        icon: Icons.translate,
        title: i18n.translation_target_language,
        value: s.targetLang,
        onChanged: (code) => s.setTargetLang(code),
      ),
      _buildLanguageTile(
        context,
        icon: Icons.notes,
        title: i18n.translation_source_language,
        value: s.sourceLang,
        onChanged: (code) => s.setSourceLang(code),
      ),
      const Divider(),
      // ── OCR ──
      ListTile(
        leading: const Icon(Icons.photo_size_select_large),
        title: Text(i18n.translation_ocr_resolution),
        trailing: SettingSelectMenu(
          index: s.ocrResolutionIndex,
          items: [
            i18n.translation_ocr_low,
            i18n.translation_ocr_medium,
            i18n.translation_ocr_high,
            i18n.translation_ocr_original,
          ],
          onChange: _onOcrResolutionChanged,
        ),
      ),
      ListTile(
        leading: const Icon(Icons.document_scanner),
        title: Text(i18n.translation_ocr_engine),
        trailing: SettingSelectMenu(
          index: s.ocrEngine.index,
          items: const ['ML Kit', 'Paddle'],
          onChange: (index) async {
            await s.setOcrEngine(OcrEngineType.values[index]);
            if (index == OcrEngineType.paddle.index) {
              BotToast.showText(text: _kPaddleNotReadyHint);
            }
          },
        ),
      ),
      const Divider(),
      // ── 云端 ──
      ListTile(
        leading: const Icon(Icons.link),
        title: Text(i18n.translation_cloud_base_url),
        subtitle: s.cloudBaseUrl.isEmpty
            ? null
            : Text(_shorten(s.cloudBaseUrl)),
        onTap: () => _editCloudField(context, _CloudField.baseUrl),
      ),
      ListTile(
        leading: const Icon(Icons.key),
        title: Text(i18n.translation_cloud_api_key),
        // key 永不明文展示，也不写日志（规格 §12）
        subtitle: s.cloudApiKey.isEmpty ? null : const Text('••••••••'),
        onTap: () => _editCloudField(context, _CloudField.apiKey),
      ),
      ListTile(
        leading: const Icon(Icons.smart_toy_outlined),
        title: Text(i18n.translation_cloud_model),
        subtitle: s.cloudModel.isEmpty ? null : Text(_shorten(s.cloudModel)),
        onTap: () => _editCloudField(context, _CloudField.model),
      ),
      ListTile(
        leading: const Icon(Icons.network_ping),
        title: Text(i18n.translation_test_connection),
        trailing: _testing
            ? const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : null,
        onTap: _testConnection,
      ),
      const Divider(),
      // ── 上下文 ──
      SwitchListTile(
        secondary: const Icon(Icons.format_align_left),
        value: s.contextEnabled,
        title: Text(i18n.translation_context_enabled),
        onChanged: (v) => s.setContextEnabled(v),
      ),
      ListTile(
        leading: const Icon(Icons.menu_book),
        title: Text(i18n.translation_glossary),
        subtitle: Text(
          s.parseGlossary().isEmpty ? '-' : '${s.parseGlossary().length}',
        ),
        onTap: _editGlossary,
      ),
      const Divider(),
      // ── 显示 ──
      ListTile(
        leading: const Icon(Icons.format_size),
        title: const Text('译文文字大小'),
        subtitle: Text(_textSizeSubtitle(s)),
        trailing: SettingSelectMenu(
          index: s.textSize.index,
          items: [for (final v in TranslationTextSize.values) v.label],
          onChange: (i) => TranslationService.instance.setTranslationTextSize(
            TranslationTextSize.values[i],
          ),
        ),
      ),
      const Divider(),
      // ── 缓存 ──
      SwitchListTile(
        secondary: const Icon(Icons.cached),
        value: s.cacheEnable,
        title: Text(i18n.translation_cache_enable),
        onChanged: (v) => s.setCacheEnable(v),
      ),
      ListTile(
        leading: const Icon(Icons.clear_all),
        title: Text(i18n.translation_cache_clear),
        onTap: () {
          TranslationService.instance.clearCache();
          BotToast.showText(text: '${i18n.translation_cache_clear} ✓');
        },
      ),
      const Divider(),
    ];
  }

  // ── 模型下载管理 ──

  /// 模型区块顶部的说明条：整块被禁用时必须解释原因，否则用户只会看到
  /// 一片点不动的灰色控件。
  Widget _buildLocalUnavailableBanner(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 4, 16, 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: scheme.secondaryContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.info_outline,
            size: 18,
            color: scheme.onSecondaryContainer,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              localTranslationUnsupportedReason(),
              style: TextStyle(
                fontSize: 12,
                height: 1.4,
                color: scheme.onSecondaryContainer,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 只读态：变灰 + 吃掉点击。
  ///
  /// `ListTile.enabled` 管不到 trailing（那是独立子树），下拉/按钮仍能点，
  /// 所以要在外层兜一层 IgnorePointer。
  Widget _disableWhen(bool disabled, Widget child) {
    if (!disabled) return child;
    return IgnorePointer(child: Opacity(opacity: 0.4, child: child));
  }

  Widget _buildModelDownloadTile(
    BuildContext context,
    AppLocalizations i18n, {
    bool enabled = true,
  }) {
    final subtitleText = switch (_phase) {
      ModelDownloadPhase.downloading || ModelDownloadPhase.verifying =>
        '${i18n.translation_model_downloading} '
            '${_downloaded / 1048576 ~/ 1} / ${_total / 1048576 ~/ 1} MB',
      ModelDownloadPhase.done => i18n.translation_model_installed,
      ModelDownloadPhase.failed || ModelDownloadPhase.cancelled =>
        _downloadMessage ?? i18n.translation_failed,
      ModelDownloadPhase.idle => ModelSpec.hyMt2.repo,
    };
    return ListTile(
      leading: const Icon(Icons.download),
      title: Text(i18n.translation_model_download),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(subtitleText),
          if (_phase == ModelDownloadPhase.downloading)
            Padding(
              padding: const EdgeInsets.only(top: 4.0),
              child: LinearProgressIndicator(
                value: _total > 0 ? (_downloaded / _total).clamp(0.0, 1.0) : 0,
              ),
            ),
        ],
      ),
      // 点击打开模型仓库主页，展示来源与许可（规格 §9.1）
      enabled: enabled,
      onTap: enabled
          ? () => launchUrlString(
              'https://huggingface.co/${ModelSpec.hyMt2.repo}',
              mode: LaunchMode.externalApplication,
            )
          : null,
      trailing: enabled
          ? _buildModelDownloadTrailing(i18n)
          : _disableWhen(
              true,
              _buildModelDownloadTrailing(i18n) ?? const SizedBox.shrink(),
            ),
    );
  }

  Widget? _buildModelDownloadTrailing(AppLocalizations i18n) {
    switch (_phase) {
      case ModelDownloadPhase.downloading:
        return IconButton(
          icon: const Icon(Icons.pause),
          tooltip: i18n.cancel,
          onPressed: _cancelDownload,
        );
      case ModelDownloadPhase.idle:
      case ModelDownloadPhase.failed:
      case ModelDownloadPhase.cancelled:
        return _modelInstalled
            ? TextButton(
                onPressed: _deleteModel,
                child: Text(i18n.translation_model_delete),
              )
            : TextButton(
                onPressed: _startDownload,
                child: Text(i18n.translation_model_download),
              );
      case ModelDownloadPhase.verifying:
      case ModelDownloadPhase.done:
        return null;
    }
  }

  Future<void> _startDownload() async {
    final i18n = I18n.of(context);
    final s = _settings!;
    String url;
    switch (s.modelMirror) {
      case ModelMirror.huggingface:
        url = ModelSpec.hyMt2.hfUrl;
        break;
      case ModelMirror.hfMirror:
        url = ModelSpec.hyMt2.mirrorUrl;
        break;
      case ModelMirror.hfMirrorNet:
        url = ModelSpec.hyMt2.mirrorNetUrl;
        break;
      case ModelMirror.modelScope:
        url = ModelSpec.hyMt2.modelScopeUrl;
        break;
      case ModelMirror.custom:
        url = s.modelMirrorUrl.trim();
        if (url.isEmpty) {
          BotToast.showText(text: i18n.translation_model_mirror_custom);
          return;
        }
        break;
    }
    final savePath = await TranslationService.instance.modelSavePath;
    setState(() {
      _phase = ModelDownloadPhase.downloading;
      _downloadMessage = null;
      _downloaded = 0;
      _total = ModelDownloadState.hyMt2SizeBytes;
    });
    await _downloadSub?.cancel();
    _downloadSub = _downloadService
        .download(url, savePath, directConnect: s.modelDirectDownload)
        .listen((state) {
      if (!mounted) return;
      setState(() {
        _phase = state.phase;
        _downloaded = state.downloaded;
        _total = state.total;
        _downloadMessage = state.message;
      });
      if (state.phase == ModelDownloadPhase.done) {
        BotToast.showText(text: I18n.of(context).translation_model_installed);
        _refreshInstalled();
      } else if (state.phase == ModelDownloadPhase.failed) {
        // 所选源失败：仅提示，由用户决定是否切换下载源（规格 §9.2-5）
        BotToast.showText(text: state.message ?? I18n.of(context).failed);
      }
    });
  }

  void _cancelDownload() => _downloadService.cancel();

  Future<void> _deleteModel() async {
    final i18n = I18n.of(context);
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(i18n.translation_model_delete),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(i18n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(i18n.ok),
          ),
        ],
      ),
    );
    if (ok != true) return;
    await _downloadService.delete();
    await _refreshInstalled();
  }

  Future<void> _importModel() async {
    final i18n = I18n.of(context);
    try {
      final file = await FilePicker.pickFile();
      final path = file?.path;
      if (path == null) return;
      final ok = await _downloadService.importLocal(path);
      BotToast.showText(
        text: ok ? i18n.translation_model_installed : i18n.failed,
      );
    } catch (e) {
      BotToast.showText(text: '$e');
    }
    await _refreshInstalled();
  }

  // ── 端侧性能 ──

  /// 线程数 tile 副标题：当前值 + 上次调优实测速度（未测过则不显示）。
  String _threadsSubtitle(TranslationSettings s) {
    final threads = s.llmThreads;
    final label = threads <= 0 ? '默认（llama.cpp 恒 4 线程）' : '$threads 线程';
    final bench = s.llmThreadsBench;
    return bench > 0 ? '$label · 实测 ${bench.toStringAsFixed(1)} tok/s' : label;
  }

  /// 译文文字大小副标题：自适应档说明「框大就放大」，其余标出倍率。
  String _textSizeSubtitle(TranslationSettings s) {
    final size = s.textSize;
    if (size == TranslationTextSize.auto) {
      return '按识别框自适应放大（框大则字大），长句优先完整显示';
    }
    final percent = (size.scale * 100).round();
    return '在自适应基础上 ×${percent / 100}'
        '（更易读，长句可能被框裁切）';
  }

  /// 批宽 tile 副标题：0 = 默认 4。
  String _batchSubtitle(TranslationSettings s) {
    final b = s.llmBatch;
    if (b <= 0) return '默认 4 段并行';
    return b == 1 ? '逐段串行（最省内存）' : '$b 段并行';
  }

  /// 性能实验台入口：端侧引擎不可用 / 模型未装时先拦一下并给出原因。
  Future<void> _openBench() async {
    if (!kTranslatorLocalLlmEnabled || !kLocalLlmAbiSupported) {
      BotToast.showText(text: '端侧引擎不可用，无法实测');
      return;
    }
    if (!_modelInstalled) {
      BotToast.showText(text: '请先下载或导入端侧模型');
      return;
    }
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const TranslateBenchPage()),
    );
    if (!mounted) return;
    // 实验台可能改了设置，副标题要跟着刷新。
    setState(() {});
  }

  /// 下拉选择下载源（SettingSelectMenu 回调）。
  /// custom 需补输 URL；取消输入则不切换镜像。
  Future<void> _onMirrorChanged(ModelMirror mirror) async {
    final i18n = I18n.of(context);
    final s = _settings!;
    final previous = s.modelMirror;
    if (mirror == ModelMirror.custom) {
      final url = await _promptText(
        context: context,
        title: i18n.translation_model_mirror,
        initial: s.modelMirrorUrl,
      );
      if (url == null || url.trim().isEmpty) {
        // 放弃输入：先写入选中值再还原，强制 Observable 通知以刷新下拉回显
        await s.setModelMirror(mirror);
        await s.setModelMirror(previous);
        return;
      }
      await s.setModelMirrorUrl(url.trim());
    }
    await s.setModelMirror(mirror);
  }

  // ── 语言 ──

  Widget _buildLanguageTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String value,
    required ValueChanged<String> onChanged,
  }) {
    final i18n = I18n.of(context);
    // Hy-MT2 官方 38 语言名表（规格 §6.1），首项为「自动」
    final codes = ['auto', ...HyMt2PromptPolicy.officialLanguageNames.keys];
    final names = [
      i18n.translation_auto,
      ...HyMt2PromptPolicy.officialLanguageNames.values,
    ];
    var index = codes.indexOf(value.trim().toLowerCase());
    if (index == -1) index = 0;
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      trailing: SettingSelectMenu(
        index: index,
        items: names,
        onChange: (i) => onChanged(codes[i]),
      ),
    );
  }

  // ── OCR ──

  /// 下拉选择 OCR 分辨率（SettingSelectMenu 回调）。
  /// high / original 首次选择弹一次性内存警告（规格 §8.5）。
  Future<void> _onOcrResolutionChanged(int selected) async {
    final i18n = I18n.of(context);
    final s = _settings!;
    if (selected >= 2 && !s.ocrHighResWarned) {
      final ok = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          content: Text(I18n.of(context).translation_ocr_high_warning),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(i18n.cancel),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(i18n.ok),
            ),
          ],
        ),
      );
      if (ok != true) {
        // 放弃更改：先写入选中值再还原，强制 Observable 通知以刷新下拉回显
        final previous = s.ocrResolutionIndex;
        await s.setOcrResolutionIndex(selected);
        await s.setOcrResolutionIndex(previous);
        return;
      }
      await s.setOcrHighResWarned(true);
    }
    await s.setOcrResolutionIndex(selected);
  }

  // ── 云端 ──

  Future<void> _editCloudField(BuildContext context, _CloudField field) async {
    final i18n = I18n.of(context);
    final s = _settings!;
    final (title, initial, obscure) = switch (field) {
      _CloudField.baseUrl => (
        i18n.translation_cloud_base_url,
        s.cloudBaseUrl,
        false,
      ),
      _CloudField.apiKey => (
        i18n.translation_cloud_api_key,
        s.cloudApiKey,
        true,
      ),
      _CloudField.model => (i18n.translation_cloud_model, s.cloudModel, false),
    };
    final value = await _promptText(
      context: context,
      title: title,
      initial: initial,
      obscure: obscure,
    );
    if (value == null) return;
    switch (field) {
      case _CloudField.baseUrl:
        final trimmed = value.trim();
        if (trimmed.isEmpty) {
          await s.setCloudBaseUrl('');
          break;
        }
        // 统一规范化：补协议头、去尾斜杠、去掉误粘的 /chat/completions。
        final normalized = normalizeCloudBaseUrl(trimmed);
        if (normalized == null) {
          BotToast.showText(
            text: '地址无效，只支持 http / https，例如 http://192.168.1.5:8080/v1',
          );
          return;
        }
        await s.setCloudBaseUrl(normalized);
        // Android 17 访问局域网要运行时权限：保存时顺手申请，避免等到
        // 翻译失败才看到一句无头无尾的「网络错误」。
        if (isLocalNetworkHost(Uri.tryParse(normalized)?.host ?? '')) {
          final granted = await ensureLocalNetworkPermission();
          if (!granted && mounted) {
            BotToast.showText(
              text: '未授予「本地网络」权限：Android 17 会拦截局域网接口，'
                  '请到系统设置 → 应用 → PixEz → 权限 中开启',
            );
          }
        }
        break;
      case _CloudField.apiKey:
        await s.setCloudApiKey(value.trim());
        break;
      case _CloudField.model:
        await s.setCloudModel(value.trim());
        break;
    }
  }

  Future<void> _testConnection() async {
    if (_testing) return;
    setState(() => _testing = true);
    try {
      final result = await TranslationService.instance.testCloudConnection();
      BotToast.showText(text: result.message);
    } catch (e) {
      BotToast.showText(text: '$e');
    } finally {
      if (mounted) setState(() => _testing = false);
    }
  }

  // ── 上下文 / 术语表 ──

  Future<void> _editGlossary() async {
    final i18n = I18n.of(context);
    final s = _settings!;
    final value = await _promptText(
      context: context,
      title: i18n.translation_glossary,
      initial: s.glossary,
      maxLines: 8,
    );
    if (value == null) return;
    await s.setGlossary(value);
  }

  // ── 通用组件 ──

  Future<String?> _promptText({
    required BuildContext context,
    required String title,
    String initial = '',
    bool obscure = false,
    int maxLines = 1,
  }) {
    final controller = TextEditingController(text: initial);
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: TextField(
          controller: controller,
          obscureText: obscure,
          maxLines: obscure ? 1 : maxLines,
          keyboardType: maxLines > 1
              ? TextInputType.multiline
              : TextInputType.text,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(I18n.of(context).cancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(controller.text),
            child: Text(I18n.of(context).ok),
          ),
        ],
      ),
    );
  }

  String _shorten(String value) {
    if (value.length <= 32) return value;
    return '${value.substring(0, 32)}…';
  }
}

/// 云端三项可编辑字段。
enum _CloudField { baseUrl, apiKey, model }
