/*
 * Copyright (C) 2020. by perol_notsf, All rights reserved
 *
 * This program is free software: you can redistribute it and/or modify it under
 * the terms of the GNU General Public License as published by the Free Software
 * Foundation, either version 3 of the License, or (at your option) any later version.
 *
 *  This program is distributed in the hope that it will be useful, but WITHOUT ANY
 *  WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
 *  FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License along with
 *  this program. If not, see <http://www.gnu.org/licenses/>.
 */

import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:pixez/constants.dart';
import 'package:pixez/er/lprinter.dart';

//虽然官方有提供包能一键生成，但是少一个依赖更好 :)
class CryptoPlugin {
  static Future<String> getCodeVer() async {
    const String randomKeySet =
        'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-._~';
    final result = List.generate(128,
            (i) => randomKeySet[Random.secure().nextInt(randomKeySet.length)])
        .join();
    Constants.code_verifier = result;
    return Constants.code_verifier!;
  }

  static Future<String> getCodeChallenge() async {
    LPrinter.d(Constants.code_verifier);
    final codeChallenge = base64Url
        .encode(sha256.convert(ascii.encode(Constants.code_verifier!)).bytes)
        .replaceAll('=', '');
    return codeChallenge;
  }
}
