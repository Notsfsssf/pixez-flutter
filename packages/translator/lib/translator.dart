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

/// PixEz 翻译功能的纯 Dart 层。
///
/// - 策略层：Hy-MT2 prompt / 输出校验 / 生成边界 / 缓存
/// - 几何层：OCR 分辨率四档、文本块坐标换算
/// - 引擎层：端侧 llama.cpp（经 Isolate 宿主注入）与 OpenAI 兼容云端引擎
/// - 管线层：图片翻译（OCR → 坐标换算 → 批量翻译）与文本翻译
///
/// 平台能力（ML Kit、FFI、文件路径）一律接口注入（规格 §4）。
library;

// 模型层
export 'src/model/model_installer.dart';
export 'src/model/ocr_resolution.dart';
export 'src/model/text_block.dart';
export 'src/model/translate_request.dart';
// OCR 层
export 'src/ocr/ocr_engine.dart';
// 翻译层
export 'src/translate/translator.dart';
export 'src/translate/translation_cache.dart';
export 'src/translate/text_splitter.dart';
export 'src/translate/hy_mt2_prompt_policy.dart';
export 'src/translate/hy_mt2_output_policy.dart';
export 'src/translate/hy_mt2_generation_boundary_policy.dart';
export 'src/translate/hy_mt2_output_gate.dart';
export 'src/translate/hy_mt2_profile.dart';
export 'src/translate/cache_key.dart';
export 'src/translate/local_llama_translator.dart';
export 'src/translate/openai_compatible_translator.dart';
// 引擎层
export 'src/engine/llm_engine_host.dart';
export 'src/engine/inference_queue.dart';
export 'src/engine/prewarm_policy.dart';
// 几何层
export 'src/geometry/rect_mapper.dart';
// 管线层
export 'src/pipeline/image_translator.dart';
export 'src/pipeline/text_translator.dart';
