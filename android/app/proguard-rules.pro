# Copyright (C) 2020. by perol_notsf, All rights reserved
#
# This program is free software: you can redistribute it and/or modify it under
# the terms of the GNU General Public License as published by the Free Software
# Foundation, either version 3 of the License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful, but WITHOUT ANY
# WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
# FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along with
# this program. If not, see <http://www.gnu.org/licenses/>.

# 图片翻译（规格 §3）：google_mlkit_text_recognition 插件的 Kotlin 代码硬引用了全部
# 四种语言的 TextRecognizerOptions（compileOnly）。App 只按规格引入日/中两个模型库，
# 这里对未打包的天城文/韩文库做 dontwarn——运行时不会实例化对应语言，不触碰缺失类。
-dontwarn com.google.mlkit.vision.text.devanagari.DevanagariTextRecognizerOptions$Builder
-dontwarn com.google.mlkit.vision.text.devanagari.DevanagariTextRecognizerOptions
-dontwarn com.google.mlkit.vision.text.korean.KoreanTextRecognizerOptions$Builder
-dontwarn com.google.mlkit.vision.text.korean.KoreanTextRecognizerOptions

# R8 全量混淆曾把 ML Kit 内部类（pigeon/Exif 路径）混淆到 NPE
# 「Object.getClass() on a null object reference」（MethodChannel#google_mlkit_text_recognizer），
# OCR 识别必挂。整个 ML Kit 家族 + 插件保持原名，不做 shrink 优化。
-keep class com.google.mlkit.** { *; }
-keep class com.google_mlkit_commons.** { *; }
-keep class com.google_mlkit_text_recognition.** { *; }
-keep class com.google.android.gms.internal.mlkit_vision_common.** { *; }
-keep class com.google.android.gms.internal.mlkit_vision_text.** { *; }
-keep class com.google.android.gms.internal.mlkit_vision_text_bundled.** { *; }
-dontwarn com.google.android.gms.**
