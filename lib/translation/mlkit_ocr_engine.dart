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

/// ML Kit 端侧 OCR 引擎（OcrEngine 接口的 app 侧实现，规格 §3 / §8.5）。
///
/// 默认日文识别（漫画场景）；通过 OcrOptions.sourceLanguageHint 可切换
/// 中文 / 韩文。ML Kit 的输入不接受 PNG 字节，这里把解码 PNG 写入临时文件
/// 走 InputImage.fromFilePath，识别后立即删除临时文件。
library;

import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart'
    as mlkit;
import 'package:path_provider/path_provider.dart';
import 'package:translator/translator.dart';

class MlkitOcrEngine implements OcrEngine {
  mlkit.TextRecognizer? _recognizer;
  mlkit.TextRecognitionScript? _script;

  mlkit.TextRecognizer _recognizerFor(OcrOptions? options) {
    final hint = options?.sourceLanguageHint ?? 'ja';
    final script = switch (hint) {
      'zh' || 'zh-cn' || 'zh-hans' => mlkit.TextRecognitionScript.chinese,
      'ko' => mlkit.TextRecognitionScript.korean,
      _ => mlkit.TextRecognitionScript.japanese,
    };
    if (_recognizer == null || _script != script) {
      _recognizer?.close();
      _script = script;
      _recognizer = mlkit.TextRecognizer(script: script);
    }
    return _recognizer!;
  }

  @override
  Future<List<TextBlock>> recognize(
    DecodedImage image, {
    OcrOptions? options,
  }) async {
    // ML Kit 识别在原生线程执行，不阻塞 Dart 主 Isolate。
    final dir = await getTemporaryDirectory();
    final tmpFile = File(
      '${dir.path}/pixez_ocr_${DateTime.now().millisecondsSinceEpoch}.png',
    );
    await tmpFile.writeAsBytes(image.bytes, flush: true);
    try {
      final inputImage = mlkit.InputImage.fromFilePath(tmpFile.path);
      final result = await _recognizerFor(options).processImage(inputImage);
      return _convert(result);
    } finally {
      if (tmpFile.existsSync()) {
        try {
          tmpFile.deleteSync();
        } catch (e) {
          debugPrint('mlkit tmp file delete failed: $e');
        }
      }
    }
  }

  /// ML Kit 结果 → TextBlock（多边形 / 置信度 / 朝向）。
  List<TextBlock> _convert(mlkit.RecognizedText result) {
    final blocks = <TextBlock>[];
    for (final block in result.blocks) {
      final lines = block.lines;
      if (lines.isEmpty) continue;
      final text = lines.map((l) => l.text).join('\n');
      // ML Kit 给出按顺时针排列的四角点，天然覆盖旋转文本块。
      final polygon =
          block.cornerPoints
              .map((p) => Offset2D(p.x.toDouble(), p.y.toDouble()))
              .toList();
      if (polygon.length < 4) continue;
      final avgConfidence =
          lines
              .map((l) => l.confidence)
              .whereType<double>()
              .fold<double>(0.0, (a, b) => a + b) /
          lines.length;
      blocks.add(
        TextBlock(
          text: text,
          polygon: polygon,
          confidence: avgConfidence,
          orientation: TextOrientation.horizontal,
        ),
      );
    }
    return blocks;
  }

  @override
  Future<void> close() async {
    await _recognizer?.close();
    _recognizer = null;
  }
}
