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

import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';

//分下层，以免以后尴尬
class LPrinter {
  static void i(i) {
    print(i);
  }

  static void d(i) {
    if (kDebugMode) print(i);
  }

  static void t(i) {
  }

  static var buffer = StringBuffer();

  static f(i) async {
    buffer.write(i.toString());
    String nowRecord = buffer.toString();
    if (nowRecord.length > 50) {
      var path = await getTemporaryDirectory();
      var filePath = join(path.path, "log.log");
      File file = File(filePath);
      file.writeAsStringSync(nowRecord, mode: FileMode.append);
      buffer.clear();
    }
  }

  static Future<File> savedLogFile() async {
    var path = await getTemporaryDirectory();
    var filePath = join(path.path, "log.log");
    File file = File(filePath);
    file.writeAsStringSync(buffer.toString());
    buffer.clear();
    return file;
  }
}
