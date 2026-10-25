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

/// 单块译文视图（规格 §8.1）：
/// 圆角 6、背景 black 68%、白字；字号按「块面积反解」自动放大到框内可读的
/// 最大值（6~96），再乘用户在设置里选的倍率；超出块高的行裁剪。
library;

import 'dart:math' as math;

// 注意：本项目把 Material 库换成了 material_ui 包（fluent 版要求），
// 必须从 material_ui 导入。用 package:flutter/material.dart 会拿到 SDK 的
// 另一份 Material：Theme.of 找不到本项目主题（退回浅色 fallback），
// Scaffold/AppBar 还会因为找不到 MaterialLocalizations 直接报红。
import 'package:material_ui/material_ui.dart';
import 'package:pixez/translation/translation_service.dart';
import 'package:translator/translator.dart';

class TranslationBlockView extends StatelessWidget {
  final TextBlock block;

  /// 译文（null = 失败，显示原文）。
  final String? translated;

  final bool showOriginal;

  const TranslationBlockView({
    Key? key,
    required this.block,
    required this.translated,
    required this.showOriginal,
  }) : super(key: key);

  /// 按块面积反解字号，让译文尽量完整落进 OCR 框内。
  ///
  /// 旧实现取 `height * 0.62`、行数 = `height / (字号*1.25)`，算出来恒为
  /// 1 行：译文比原文长时直接被 `clip` 裁掉尾部，真机表现就是「译文没
  /// 显示」或只看到半句。这里改成面积约束：文本视觉宽度 × 字号² × 行高
  /// 不超过块面积，再受块高上限约束。
  static double _fitFontSize(String text, double maxWidth, double maxHeight) {
    if (maxWidth <= 0 || maxHeight <= 0) return 8;
    final visual = _visualLength(text);
    if (visual <= 0) return 8;
    // 单行上限：字号不超过块高（留 8% 余量）。
    final byHeight = maxHeight * 0.92;
    // 面积约束：visual * fs² * 1.15 ≤ maxWidth * maxHeight。
    final byArea = math.sqrt(maxWidth * maxHeight / (visual * 1.15));
    return math.min(byHeight, byArea).clamp(6.0, 64.0);
  }

  /// 文本视觉宽度，以 1em 为基准：全角字符 1.0、ASCII 0.55、其余 0.9。
  static double _visualLength(String text) {
    var sum = 0.0;
    for (final rune in text.runes) {
      if (rune == 0x0A || rune == 0x0D) continue;
      sum += rune < 0x80 ? 0.55 : 1.0;
    }
    return sum;
  }

  @override
  Widget build(BuildContext context) {
    // 字号设置改完要立刻重排：监听 service 的 notifier，而不是把倍率当
    // 构造参数一层层透传——覆盖层在卡片、长图、PhotoView 三处复用。
    return ValueListenableBuilder<double>(
      valueListenable: TranslationService.instance.translationTextScale,
      builder: (context, scale, _) => _buildScaled(scale),
    );
  }

  Widget _buildScaled(double scale) {
    final box = block.boundingBox;
    final text = (showOriginal || translated == null || translated!.isEmpty)
        ? block.text
        : translated!;
    final maxWidth = box.width > 8 ? box.width - 8 : box.width;
    final maxHeight = box.height > 4 ? box.height - 4 : box.height;
    // 自适应字号（框大自动放大），再叠加用户档位倍率。
    final fontSize = (_fitFontSize(text, maxWidth, maxHeight) * scale).clamp(
      6.0,
      96.0,
    );
    // 行数留给 Text 自动换行；估算字号已按面积收敛，超出部分才裁剪。
    final maxLines = (maxHeight / (fontSize * 1.15)).floor().clamp(1, 24);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 1),
      decoration: BoxDecoration(
        // 0.55 在浅色画面上白字发虚，提到 0.68 保证可读性。
        color: Colors.black.withValues(alpha: 0.68),
        borderRadius: BorderRadius.circular(6),
      ),
      alignment: Alignment.center,
      child: Text(
        text,
        style: TextStyle(
          color: Colors.white,
          fontSize: fontSize,
          height: 1.15,
          fontWeight: FontWeight.w500,
          shadows: const [
            Shadow(color: Colors.black45, blurRadius: 2, offset: Offset(0, 1)),
          ],
        ),
        textAlign: TextAlign.center,
        maxLines: maxLines,
        overflow: TextOverflow.clip,
      ),
    );
  }
}
