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

import 'dart:io';

class Constants {
  static String tagName = "0.9.49";
  static const isGooglePlay =
      bool.fromEnvironment("IS_GOOGLEPLAY", defaultValue: false);
  static int type = 0;
  static String? code_verifier = null;

  /// 为true表示使用FluentUI 否则为false,不应作为Desktop的判断
  static final bool isFluent = false;
}
