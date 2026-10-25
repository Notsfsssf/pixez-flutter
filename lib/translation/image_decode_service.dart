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

/// 图片解码服务：按用户设定分辨率「解码即缩放」（规格 §5）。
///
/// 禁止「先解全尺寸再缩小」——用 `instantiateImageCodecWithSize` 在解析阶段
/// 就拿到原图尺寸并指定目标尺寸（峰值内存 ≈ 目标尺寸 × 4B）。
/// 位图取完字节后立即 dispose，不与 OCR / LLM 争大位图。
library;

import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:pixez/component/pixiv_image.dart';
import 'package:pixez/er/hoster.dart';
import 'package:translator/translator.dart';

/// 解码结果：字节 + 解码尺寸 + 原图尺寸。
class DecodedImageResult {
  final Uint8List bytes;
  final int decodedWidth;
  final int decodedHeight;
  final int originalWidth;
  final int originalHeight;
  final OcrResolution resolution;

  const DecodedImageResult({
    required this.bytes,
    required this.decodedWidth,
    required this.decodedHeight,
    required this.originalWidth,
    required this.originalHeight,
    required this.resolution,
  });
}

class ImageDecodeService {
  /// 下载 + 按档解码。
  ///
  /// 缩放比换算（scaleX = originalWidth / decodedWidth 等）由调用方用
  /// [DecodedImageResult] 的尺寸与 RectMapper 完成。
  Future<DecodedImageResult> decode(
    String url,
    OcrResolution resolution,
  ) async {
    // 复用图片缓存管道（用法对齐 lib/clipboard_plugin.dart 的 _downloadImage）
    final file =
        await pixivCacheManager!.getFileFromCache(url) ??
        await pixivCacheManager!.downloadFile(
          url,
          authHeaders: Hoster.header(url: url),
        );
    // readAsBytes 返回的是定长 Uint8List（本 SDK），对其 clear() 会抛
    // 「Cannot remove from a fixed-length list」——曾让翻译在解码第一步
    // 就失败。局部变量出作用域即由 GC 回收，无需手动清空。
    final bytes = await file.file.readAsBytes();
    return decodeBytes(bytes, resolution);
  }

  /// 从字节按档解码。
  Future<DecodedImageResult> decodeBytes(
    Uint8List bytes,
    OcrResolution resolution,
  ) async {
    // 用 ImageDescriptor 链（buffer → descriptor → codec → frame）代替
    // instantiateImageCodecWithSize：各原生对象的生命周期边界明确，
    // 且原图尺寸直接来自 descriptor（不再依赖 getTargetSize 回调顺带记录）。
    int originalWidth = 0;
    int originalHeight = 0;
    final buffer = await ui.ImmutableBuffer.fromUint8List(bytes);
    ui.ImageDescriptor? descriptor;
    ui.Codec? codec;
    try {
      descriptor = await ui.ImageDescriptor.encoded(buffer);
      originalWidth = descriptor.width;
      originalHeight = descriptor.height;
      final size = ImageTranslator.computeDecodeSize(
        resolution,
        originalWidth,
        originalHeight,
      );
      codec = await descriptor.instantiateCodec(
        targetWidth: size.$1,
        targetHeight: size.$2,
      );
      final frame = await codec.getNextFrame();
      final image = frame.image;
      try {
        final decodedWidth = image.width;
        final decodedHeight = image.height;
        final png = await image.toByteData(format: ui.ImageByteFormat.png);
        if (png == null) {
          throw StateError('image decode failed: toByteData returned null');
        }
        return DecodedImageResult(
          bytes: png.buffer.asUint8List(),
          decodedWidth: decodedWidth,
          decodedHeight: decodedHeight,
          originalWidth: originalWidth,
          originalHeight: originalHeight,
          resolution: resolution,
        );
      } finally {
        // 取完 PNG 立刻释放，不与 OCR / LLM 争大位图
        image.dispose();
      }
    } finally {
      codec?.dispose();
      descriptor?.dispose();
      // descriptor 持有 buffer 的引用，最后释放 buffer 才安全
      buffer.dispose();
    }
  }
}
