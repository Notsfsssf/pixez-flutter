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

/// 信息流卡片上的译文覆盖层：把「原图像素坐标」的译文块缩放到卡片
/// 实际显示尺寸后贴上去。
///
/// 与 [TranslationOverlay] 的区别：那个用于 PhotoView（childSize 就是
/// 原图尺寸，坐标无需换算）；卡片是按宽度等比缩放的，必须按显示区域
/// 比例换算坐标与字号，否则译文会跑到图外或糊成一团。
library;

// 注意：本项目把 Material 库换成了 material_ui 包（fluent 版要求），
// 必须从 material_ui 导入。用 package:flutter/material.dart 会拿到 SDK 的
// 另一份 Material：Theme.of 找不到本项目主题（退回浅色 fallback），
// Scaffold/AppBar 还会因为找不到 MaterialLocalizations 直接报红。
import 'package:material_ui/material_ui.dart';
import 'package:pixez/translation/translation_store.dart';
import 'package:pixez/translation/widgets/translation_block_view.dart';

class InlineTranslationOverlay extends StatelessWidget {
  /// 已定位的译文块（坐标为原图像素）。
  final List<TranslatedBlockData> blocks;

  /// 原图像素尺寸（缩放基准）。
  final Size originalSize;

  /// 是否整体显示原文。
  final bool showOriginal;

  /// 单块点击（切换该块 译文 / 原文）；null = 不响应点击。
  final void Function(int index)? onBlockTap;

  const InlineTranslationOverlay({
    Key? key,
    required this.blocks,
    required this.originalSize,
    this.showOriginal = false,
    this.onBlockTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (blocks.isEmpty ||
        originalSize.width <= 0 ||
        originalSize.height <= 0) {
      return const SizedBox.shrink();
    }
    return LayoutBuilder(
      builder: (context, constraints) {
        if (!constraints.hasBoundedWidth || !constraints.hasBoundedHeight) {
          return const SizedBox.shrink();
        }
        final scaleX = constraints.maxWidth / originalSize.width;
        final scaleY = constraints.maxHeight / originalSize.height;
        return Stack(
          // 贴边的块允许超出一点点后裁掉，避免画到卡片外面。
          clipBehavior: Clip.hardEdge,
          children: [
            for (var i = 0; i < blocks.length; i++) _block(i, scaleX, scaleY),
          ],
        );
      },
    );
  }

  Widget _block(int index, double scaleX, double scaleY) {
    final data = blocks[index];
    // 坐标与字号一起缩放：TranslationBlockView 按块面积反解字号，
    // 传缩放后的块才能得到与卡片匹配的字号。
    final scaled = data.block.scaled(scaleX, scaleY);
    final box = scaled.boundingBox;
    if (box.width <= 0 || box.height <= 0) {
      return const SizedBox.shrink();
    }
    return Positioned(
      left: box.left,
      top: box.top,
      width: box.width,
      height: box.height,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onBlockTap == null ? null : () => onBlockTap!(index),
        child: TranslationBlockView(
          block: scaled,
          translated: data.translated,
          showOriginal: showOriginal,
        ),
      ),
    );
  }
}
