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

/// 单段文本翻译入口（caption / 评论共用，规格 §8.3 / §8.4）：
/// 翻译图标 → 原地展开译文区（只读），再点折叠；译文区带「原文」小按钮切回。
library;


import 'package:bot_toast/bot_toast.dart';
// 注意：本项目把 Material 库换成了 material_ui 包（fluent 版要求），
// 必须从 material_ui 导入。用 package:flutter/material.dart 会拿到 SDK 的
// 另一份 Material：Theme.of 找不到本项目主题（退回浅色 fallback），
// Scaffold/AppBar 还会因为找不到 MaterialLocalizations 直接报红。
import 'package:material_ui/material_ui.dart';
import 'package:pixez/i18n.dart';
import 'package:translator/translator.dart';

import '../html_text.dart';
import '../translation_service.dart';

class TextTranslationEntry extends StatefulWidget {
  final String source;
  final String? cacheKey;

  /// 原文内容（由调用方渲染）。显示译文时本组件会把它从树上摘掉：
  /// 之前译文和原文是两棵独立的树，点了翻译变成「译文 + 原文」同时铺在
  /// 简介区，看起来像没切换成功。
  final Widget? original;

  /// 译文颜色。默认用 `colorScheme.inverseSurface`（简介框的配对色）；
  /// 放到普通 Card 上（小说阅读器的简介区）时底色不是 inverse 系，
  /// 由调用方传入与背景对比的正文色。
  final Color? textColor;

  const TextTranslationEntry({
    Key? key,
    required this.source,
    this.cacheKey,
    this.original,
    this.textColor,
  }) : super(key: key);

  @override
  State<TextTranslationEntry> createState() => _TextTranslationEntryState();
}

class _TextTranslationEntryState extends State<TextTranslationEntry> {
  /// 单块字数上限。端侧 Hy-MT2 的上下文是 4096 token，整段简介（常上千字）
  /// 直接塞进去必然超限——`llama_shim_start` 返回 -2、上层抛「prompt too
  /// long」，界面表现就是简介翻译一按就报错。按 280 字切块，留足生成空间。
  static const int _kMaxPieceChars = 280;

  String? _translated;
  bool _showTranslation = false;
  bool _showOriginal = false;
  bool _loading = false;

  @override
  void didUpdateWidget(covariant TextTranslationEntry oldWidget) {
    super.didUpdateWidget(oldWidget);
    // 详情页切作品时 State 会被复用：源变了必须丢掉旧译文，
    // 否则新作品下面挂着上一张的翻译。
    if (oldWidget.source != widget.source) {
      setState(() {
        _translated = null;
        _showTranslation = false;
        _showOriginal = false;
        _loading = false;
      });
    }
  }

  Future<void> _toggle() async {
    if (_showTranslation && !_showOriginal) {
      // 已在显示译文 → 折叠
      setState(() {
        _showTranslation = false;
        _showOriginal = false;
      });
      return;
    }
    if (_translated == null && !_loading) {
      await _translateInPieces();
      return;
    }
    setState(() {
      _showTranslation = true;
      _showOriginal = false;
    });
  }

  /// 分段翻译：逐块请求、逐块上屏，失败块保留原文。
  Future<void> _translateInPieces() async {
    setState(() {
      _loading = true;
      _showTranslation = true;
      _showOriginal = false;
      _translated = '';
    });
    final pieces = splitForModel(stripHtml(widget.source));
    if (pieces.isEmpty) {
      setState(() {
        _loading = false;
        _translated = null;
        _showTranslation = false;
      });
      return;
    }
    try {
      final translator = await TranslationService.instance
          .getTextTranslator();
      final request = await TranslationService.instance.buildRequest();
      final buffer = StringBuffer();
      var failed = 0;
      for (var i = 0; i < pieces.length; i++) {
        final piece = await translator.translateText(pieces[i], request);
        if (piece == null) {
          failed++;
          // 失败块保留原文，避免整段简介凭空消失。
          buffer.write(pieces[i]);
        } else {
          buffer.write(piece);
        }
        if (i < pieces.length - 1) buffer.write('\n');
        if (!mounted) return;
        setState(() {
          _translated = buffer.toString();
          _loading = i < pieces.length - 1;
        });
      }
      if (failed == pieces.length && mounted) {
        BotToast.showText(text: I18n.of(context).translation_failed);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      BotToast.showText(text: _friendlyError(e));
    }
  }

  /// 把底层异常翻成用户能看懂的一句话（原始 SDK 错误太长了）。
  String _friendlyError(Object e) {
    final text = '$e';
    if (text.contains('too long') ||
        text.contains('n_ctx') ||
        text.contains('context')) {
      return '这段文字超出端侧模型上下文长度，请分段后再翻译';
    }
    return text;
  }

  /// 简介是 HTML（Pixiv caption 带 `<br />` / `<a>` / `<img>`）：
  /// 直接塞给模型既浪费上下文，又把标签译进译文。这里做一次轻量纯文本化。
  ///
  /// 实现在 `../html_text.dart`——推荐卡片翻译走同一套规则，避免两处正则漂移。
  @visibleForTesting
  static String stripHtml(String input) => stripHtmlToText(input);

  /// 按空行 / 换行 / 句末标点切块，单块不超过 [maxChars] 个字符。
  ///
  /// 实现在 translator 包里（[splitTextForModel]）：小说长段落也要切块，
  /// 两边共用同一套规则，避免一个切 280、一个切 320 的漂移。
  @visibleForTesting
  static List<String> splitForModel(
    String text, {
    int maxChars = _kMaxPieceChars,
  }) => splitTextForModel(text, maxChars: maxChars);

  @override
  Widget build(BuildContext context) {
    final hasTranslation = (_translated?.isNotEmpty ?? false);
    // 译文为空（尚未翻出第一段）时继续显示原文，避免点下翻译后整块空白。
    final showTranslation = _showTranslation && !_showOriginal && hasTranslation;
    // 简介区嵌在 IllustDetailContent 的 Container / DecoratedBox 里，
    // 整条祖先链没有 Material，直接放 InkWell 会抛
    // 「No Material widget found」。这里补一层透明 Material 作为墨水层，
    // 不改变背景、不影响外层圆角与内边距。
    return Material(
      type: MaterialType.transparency,
      child: _buildColumn(context, showTranslation, hasTranslation),
    );
  }

  Widget _buildColumn(
    BuildContext context,
    bool showTranslation,
    bool hasTranslation,
  ) {
    final scheme = Theme.of(context).colorScheme;
    // 简介框底色是 colorScheme.onInverseSurface（深色主题下是深灰），
    // 所以正文必须用与它配对的 inverseSurface，而不是 textTheme.bodyMedium
    // ——后者在这套主题里会落成近黑色，深色底上几乎看不见。
    // 外层的普通 Card（小说阅读器简介区）由调用方传入正文色。
    final onCaption = widget.textColor ?? scheme.inverseSurface;
    // 正文字号带上用户设置的倍率（设置页「译文文字大小」），与图片上的
    // 译文覆盖层共用同一个设置。
    final baseText = Theme.of(context).textTheme.bodyMedium;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        // 入口固定在右上角；用 stretch + end 让它在整行里靠右，
        // 而不是跟着译文块的宽度漂移。
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            if (_loading)
              const SizedBox(
                width: 14,
                height: 14,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            else
              InkWell(
                onTap: _toggle,
                child: Icon(
                  Icons.translate,
                  size: 16,
                  color: onCaption.withValues(
                    alpha: hasTranslation ? 0.9 : 0.6,
                  ),
                ),
              ),
            if (hasTranslation) ...[
              const SizedBox(width: 8),
              // 「显示原文 / 显示译文」双向切换：原来的按钮只在显示译文时
              // 出现，切回原文后就只剩一个翻译图标，不好发现。
              InkWell(
                onTap: () => setState(() {
                  final toTranslation = !showTranslation;
                  _showTranslation = toTranslation;
                  _showOriginal = !toTranslation;
                }),
                child: Text(
                  showTranslation
                      ? I18n.of(context).translation_show_source
                      : I18n.of(context).translation_show_translation,
                  style: TextStyle(
                    fontSize: 11,
                    color: onCaption.withValues(alpha: 0.8),
                  ),
                ),
              ),
            ],
          ],
        ),
        if (showTranslation)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: ValueListenableBuilder<double>(
              valueListenable: TranslationService.instance.translationTextScale,
              builder: (context, scale, _) => Text(
                _translated ?? '',
                style: baseText?.copyWith(
                  color: onCaption,
                  fontSize: (baseText.fontSize ?? 14) * scale,
                  height: 1.45,
                ),
              ),
            ),
          )
        else if (widget.original != null)
          widget.original!,
      ],
    );
  }
}
