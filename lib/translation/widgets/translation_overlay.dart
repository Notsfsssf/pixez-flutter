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

/// 图片翻译覆盖层（规格 §8.1）：
/// 坐标 = 原图像素（childSize 固定原图尺寸），随 PhotoView 缩放平移；
/// `IgnorePointer` 不拦截手势；`RepaintBoundary` 隔离重绘（规格 R6）。
library;

// 注意：本项目把 Material 库换成了 material_ui 包（fluent 版要求），
// 必须从 material_ui 导入。用 package:flutter/material.dart 会拿到 SDK 的
// 另一份 Material：Theme.of 找不到本项目主题（退回浅色 fallback），
// Scaffold/AppBar 还会因为找不到 MaterialLocalizations 直接报红。
import 'package:material_ui/material_ui.dart';

import '../translation_store.dart';
import 'translation_block_view.dart';

/// 在原图上叠加译文块。由 PhotoView.customChild 的 child 使用。
class TranslationOverlay extends StatelessWidget {
  /// 原图内容（PixivProvider 的 Image）。
  final Widget image;

  /// 原图像素尺寸（childSize）。
  final Size originalSize;

  final List<TranslatedBlockData> blocks;

  final bool showAllOriginal;

  /// 单块当前是否显示原文（由 store 计算：全局 XOR 单块切换）。
  final bool Function(int index)? showsOriginalAt;

  /// 单块点击（切换该块 译文/原文）。
  final void Function(int index)? onBlockTap;

  /// 长按（临时显示原文）。
  final void Function(int index)? onBlockLongPress;

  const TranslationOverlay({
    Key? key,
    required this.image,
    required this.originalSize,
    required this.blocks,
    required this.showAllOriginal,
    this.showsOriginalAt,
    this.onBlockTap,
    this.onBlockLongPress,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: originalSize.width,
      height: originalSize.height,
      child: Stack(
        fit: StackFit.expand,
        children: [
          RepaintBoundary(child: image),
          for (var i = 0; i < blocks.length; i++)
            _buildBlock(context, i, blocks[i]),
        ],
      ),
    );
  }

  Widget _buildBlock(
    BuildContext context,
    int index,
    TranslatedBlockData data,
  ) {
    final box = data.block.boundingBox;
    return Positioned(
      left: box.left,
      top: box.top,
      width: box.width > 0 ? box.width : null,
      height: box.height > 0 ? box.height : null,
      child: GestureDetector(
        onTap: () => onBlockTap?.call(index),
        onLongPress: () => onBlockLongPress?.call(index),
        child: IgnorePointer(
          child: RepaintBoundary(
            child: TranslationBlockView(
              block: data.block,
              translated: data.translated,
              showOriginal: showsOriginalAt?.call(index) ?? showAllOriginal,
            ),
          ),
        ),
      ),
    );
  }
}
