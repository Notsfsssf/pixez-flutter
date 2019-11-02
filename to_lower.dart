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

import 'dart:convert';
import 'dart:io';

//给key转小写的工具
void main(args) {
  String fileName = 'en_US.arb';
  var file = File('./${fileName}');
  Map<String, dynamic> scores = jsonDecode(file.readAsStringSync());
  var keys = scores.keys.toList();
  for (var i = 0; i < keys.length; i++) {
    var key = keys[i];
    var resultKey = key.toLowerCase();
    if (resultKey == key) {
      continue;
    }
    scores[resultKey] = scores[key];
    scores.remove(key);
  }
  String out = "{\n";
  var outFile = File('./${fileName}.json');
  if (!outFile.existsSync()) {
    outFile.createSync();
  }
  for (var j in scores.keys.toList()..sort()) {
    out += "\"$j\":\"${scores[j]}\",\n";
  }
  out += "}";
  outFile.writeAsStringSync(out);
  print(scores.keys.length);
}
