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

/// OCR 引擎抽象。
///
/// 本包只定义接口；ML Kit / PP-OCRv5 等平台实现由 app 侧注入
/// （规格 §4 分层硬约束 3）。实现方必须保证不在 Dart 主 Isolate 上做重活。
library;

import 'dart:typed_data';

import '../model/text_block.dart';

/// 解码后的位图数据，交由 [OcrEngine] 识别。
class DecodedImage {
  final int width;
  final int height;

  /// 位图字节，格式见 [format]。
  final Uint8List bytes;

  /// 字节编码格式。
  final DecodedImageFormat format;

  const DecodedImage({
    required this.width,
    required this.height,
    required this.bytes,
    required this.format,
  });
}

enum DecodedImageFormat { png, rgba8888 }

/// OCR 选项。
class OcrOptions {
  /// 提示源语言（BCP-47，如 `ja`）；null = 引擎自动检测。
  final String? sourceLanguageHint;

  /// 是否尝试检测竖排文本（日文漫画常用）。
  final bool detectVertical;

  const OcrOptions({this.sourceLanguageHint, this.detectVertical = true});
}

/// OCR 引擎抽象（对齐参考 ocr/OcrEngine.kt + ocr/TextBlock.kt）。
abstract class OcrEngine {
  /// 在已解码的位图上识别文本。实现方必须保证不阻塞 Dart 主 Isolate。
  ///
  /// 返回的 TextBlock 坐标系 = [image] 的像素坐标系。
  Future<List<TextBlock>> recognize(DecodedImage image, {OcrOptions? options});

  /// 释放引擎持有的原生资源；之后实例不可再用。
  Future<void> close();
}
