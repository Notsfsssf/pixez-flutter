#!/usr/bin/env python3
"""Generate lib/src/translate/letter_ranges.dart.

HyMt2OutputPolicy 的 PUNCTUATION_SOURCE_EXPANSION 检测需要
`Char.isLetterOrDigit`（Kotlin → Java Character.isLetterOrDigit = Unicode
类别 L* ∪ Nd）。Dart SDK 没有对应 API，本脚本用 Python unicodedata
生成精确区段表（合并相邻区段），运行时二分查找。

用法： python tool/gen_letter_ranges.py > lib/src/translate/letter_ranges.dart
"""

import unicodedata


def main() -> None:
    ranges = []

    def add(cp: int) -> None:
        if ranges and ranges[-1][1] == cp - 1:
            ranges[-1][1] = cp
        else:
            ranges.append([cp, cp])

    for cp in range(0x110000):
        if 0xD800 <= cp <= 0xDFFF:
            continue
        cat = unicodedata.category(chr(cp))
        if cat.startswith("L") or cat == "Nd":
            add(cp)

    lines = [
        "/*",
        " * Copyright (C) 2020. by perol_notsf, All rights reserved",
        " *",
        " * This program is free software: you can redistribute it and/or modify it under",
        " * the terms of the GNU General Public License as published by the Free Software",
        " * Foundation, either version 3 of the License, or (at your option) any later version.",
        " *",
        " * This program is distributed in the hope that it will be useful, but WITHOUT ANY",
        " * WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS",
        " * FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.",
        " *",
        " * You should have received a copy of the GNU General Public License along with",
        " * this program. If not, see <http://www.gnu.org/licenses/>.",
        " *",
        " */",
        "",
        "// GENERATED FILE — do not edit. Run `python tool/gen_letter_ranges.py` to regenerate.",
        "// Unicode %s 类别 L* ∪ Nd 区段表（%d 段），对齐 Java Character.isLetterOrDigit。"
        % (unicodedata.unidata_version, len(ranges)),
        "",
        "library;",
        "",
        "/// 区段表 [start, end]，升序、互不重叠。",
        "const List<int> _letterOrDigitRanges = <int>[",
    ]
    for start, end in ranges:
        lines.append("  0x%04X, 0x%04X," % (start, end))
    lines += [
        "];",
        "",
        "/// 判断码点是否为 Unicode 字母（L*）或十进制数字（Nd），",
        "/// 语义对齐 Java `Character.isLetterOrDigit`。",
        "bool isLetterOrDigitCodePoint(int codePoint) {",
        "  var low = 0;",
        "  var high = _letterOrDigitRanges.length ~/ 2 - 1;",
        "  while (low <= high) {",
        "    final mid = (low + high) >> 1;",
        "    final start = _letterOrDigitRanges[mid * 2];",
        "    final end = _letterOrDigitRanges[mid * 2 + 1];",
        "    if (codePoint < start) {",
        "      high = mid - 1;",
        "    } else if (codePoint > end) {",
        "      low = mid + 1;",
        "    } else {",
        "      return true;",
        "    }",
        "  }",
        "  return false;",
        "}",
        "",
    ]
    import sys

    print("\n".join(lines))
    print("// ranges: %d" % len(ranges), file=sys.stderr)


if __name__ == "__main__":
    main()
