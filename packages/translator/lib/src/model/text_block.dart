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

/// OCR 文本块的几何与数据模型。
///
/// 坐标一律使用「传入 OcrEngine 的 DecodedImage 像素坐标系」，
/// 跨坐标系换算交给 [TextBlock.scaled] 与 geometry/rect_mapper.dart。
library;

import 'dart:math' as math;

/// 二维点（原图 / 解码图像素坐标系）。
class Offset2D {
  final double x;
  final double y;

  const Offset2D(this.x, this.y);

  @override
  bool operator ==(Object other) =>
      other is Offset2D && other.x == x && other.y == y;

  @override
  int get hashCode => Object.hash(x, y);

  @override
  String toString() => 'Offset2D($x, $y)';
}

/// 轴对齐矩形。
class Rect2D {
  final double left;
  final double top;
  final double width;
  final double height;

  const Rect2D({
    required this.left,
    required this.top,
    required this.width,
    required this.height,
  });

  double get right => left + width;
  double get bottom => top + height;

  /// 由两个对角点构造归一化矩形（left/top 取较小值）。
  factory Rect2D.fromPoints(Offset2D a, Offset2D b) {
    final left = math.min(a.x, b.x);
    final top = math.min(a.y, b.y);
    return Rect2D(
      left: left,
      top: top,
      width: math.max(a.x, b.x) - left,
      height: math.max(a.y, b.y) - top,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is Rect2D &&
      other.left == left &&
      other.top == top &&
      other.width == width &&
      other.height == height;

  @override
  int get hashCode => Object.hash(left, top, width, height);

  @override
  String toString() => 'Rect2D($left, $top, $width, $height)';
}

/// 文本朝向。日文漫画常见竖排（从上到下）。
enum TextOrientation { horizontal, vertical }

/// 一块被识别出的文本。
///
/// [polygon] 按阅读顺序给出 4 个顶点；[boundingBox] 是它的轴对齐外接矩形。
class TextBlock {
  /// 识别出的原文（可能含换行，行序按阅读顺序）。
  final String text;

  /// 多边形，坐标系 = 传入 DecodedImage 的像素坐标系，按阅读顺序给出 4 点。
  final List<Offset2D> polygon;

  /// 识别置信度 0..1。
  final double confidence;

  /// 文本朝向。
  final TextOrientation orientation;

  const TextBlock({
    required this.text,
    required this.polygon,
    required this.confidence,
    required this.orientation,
  });

  /// polygon 的轴对齐外接矩形。
  Rect2D get boundingBox {
    final xs = polygon.map((p) => p.x);
    final ys = polygon.map((p) => p.y);
    final left = xs.reduce(math.min);
    final top = ys.reduce(math.min);
    final right = xs.reduce(math.max);
    final bottom = ys.reduce(math.max);
    return Rect2D(
      left: left,
      top: top,
      width: right - left,
      height: bottom - top,
    );
  }

  /// 换算到另一坐标系：out = in * scale（x / y 分别缩放，见规格 §5.2）。
  TextBlock scaled(double scaleX, double scaleY) {
    if (scaleX == 1 && scaleY == 1) return this;
    return TextBlock(
      text: text,
      confidence: confidence,
      orientation: orientation,
      polygon: polygon
          .map((p) => Offset2D(p.x * scaleX, p.y * scaleY))
          .toList(growable: false),
    );
  }

  @override
  String toString() =>
      'TextBlock(${text.length} chars, conf=${confidence.toStringAsFixed(2)}, '
      'orient=$orientation, bbox=$boundingBox)';
}
