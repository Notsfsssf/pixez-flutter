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

import 'package:flutter/widgets.dart';
import 'package:pixez/constants.dart';
import 'package:pixez/page/splash/common_splash_state.dart';
import 'package:pixez/page/splash/fluent_splash_state.dart';
import 'package:pixez/page/splash/material_splash_state.dart';

class SplashPage extends StatefulWidget {
  @override
  SplashPageStateBase createState() {
    if (Constants.isFluentUI)
      return FluentSplashPageState();
    else
      return MaterialSplashPageState();
  }
}
