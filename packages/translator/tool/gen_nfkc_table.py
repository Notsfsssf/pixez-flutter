#!/usr/bin/env python3
"""Generate lib/src/translate/nfkc_table.dart.

Dart SDK 没有内置 NFKC 归一化，而 Hy-MT2 输出校验（对齐参考实现
HyMt2OutputPolicy.kt）需要在 NFKC 归一化后的文本上做 header / instruction /
shape 检测（全角字母数字、全角括号、CJK 兼容标点等）。

本脚本用 Python unicodedata 枚举所有 NFKC(c) != c 的码点，生成一张
「逐码点替换表」+ 查表函数。这是 NFKC 的逐码点近似：与完整实现的差异
仅在 combining mark 重排与跨字符重组，对本检测用途无影响（README 记录）。

用法： python tool/gen_nfkc_table.py > lib/src/translate/nfkc_table.dart
"""

import unicodedata


def main() -> None:
    entries = []
    for cp in range(0x110000):
        if 0xD800 <= cp <= 0xDFFF:
            continue
        ch = chr(cp)
        norm = unicodedata.normalize("NFKC", ch)
        if norm != ch:
            entries.append((cp, norm))

    # 转义 Dart 字符串里的特殊字符
    def dart_escape(s: str) -> str:
        out = []
        for c in s:
            o = ord(c)
            if c == "\\":
                out.append("\\\\")
            elif c == "'":
                out.append("\\'")
            elif c == "$":
                out.append("\\$")
            elif c == "\n":
                out.append("\\n")
            elif c == "\r":
                out.append("\\r")
            elif c == "\t":
                out.append("\\t")
            elif 0x20 <= o < 0x7F:
                out.append(c)
            else:
                out.append("\\u{%x}" % o)
        return "".join(out)

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
        "// GENERATED FILE — do not edit. Run `python tool/gen_nfkc_table.py` to regenerate.",
        "// 逐码点 NFKC 替换表（unicodedata Unicode %s），用途见 tool/gen_nfkc_table.py。"
        % unicodedata.unidata_version,
        "// ignore_for_file: constant_identifier_names",
        "",
        "library;",
        "",
        "const Map<int, String> nfkcOverrides = <int, String>{",
    ]
    for cp, norm in entries:
        lines.append("  0x%04X: '%s'," % (cp, dart_escape(norm)))
    lines.append("};")
    lines += [
        "",
        "/// NFKC 归一化（逐码点映射近似）。",
        "///",
        "/// Dart SDK 无内置 NFKC；此实现对每个码点查 [nfkcOverrides]（无则原样保留），",
        "/// 与完整 NFKC 的差异仅在 combining mark 重排 / 跨字符重组，",
        "/// 不影响输出校验的检测语义（header / instruction / item prefix / 码点长度）。",
        "String nfkcNormalize(String input) {",
        "  if (input.isEmpty) return input;",
        "  final buffer = StringBuffer();",
        "  for (final ch in input.runes) {",
        "    final replacement = nfkcOverrides[ch];",
        "    if (replacement != null) {",
        "      buffer.write(replacement);",
        "    } else {",
        "      buffer.writeCharCode(ch);",
        "    }",
        "  }",
        "  return buffer.toString();",
        "}",
        "",
    ]
    print("\n".join(lines))
    import sys

    print("// entries: %d" % len(entries), file=sys.stderr)


if __name__ == "__main__":
    main()
