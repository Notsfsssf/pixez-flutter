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

import 'dart:typed_data';

import 'package:flutter/services.dart';

class DocumentPlugin {
  static const platform = const MethodChannel('com.perol.dev/save');

  static Future<bool> save(Uint8List uint8list, String fileName,
      {bool clearOld}) async {
    return platform.invokeMethod<bool>(
        'save', {"data": uint8list, "name": fileName, "clear_old": clearOld});
  }

  static Future<bool> exist(String fileName) =>
      platform.invokeMethod<bool>("exist", {"name": fileName});

  static Future<String> getPath() => platform.invokeMethod<String>("get_path");

  static Future<bool> needChoice() =>
      platform.invokeMethod<bool>("need_choice");

  static Future<dynamic> choiceFolder() =>
      platform.invokeMethod("choice_folder");

  static Future<dynamic> isHelplessWay() =>
      platform.invokeMethod("ishelplessway");
  static Future<Uint8List> pickFile() => platform.invokeMethod("pick_file");
}
