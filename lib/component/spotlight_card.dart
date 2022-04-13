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

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pixez/component/spotlight_card/fluent.dart';
import 'package:pixez/component/spotlight_card/material.dart';
import 'package:pixez/constants.dart';
import 'package:pixez/models/spotlight_response.dart';

abstract class SpotlightCardBase extends StatelessWidget {
  final SpotlightArticle spotlight;
  static const platform = const MethodChannel('samples.flutter.dev/battery');

  const SpotlightCardBase({Key? key, required this.spotlight})
      : super(key: key);
}

class SpotlightCard extends SpotlightCardBase {
  SpotlightCard({required SpotlightArticle spotlight})
      : super(spotlight: spotlight);

  @override
  Widget build(BuildContext context) {
    if (Constants.isFluentUI)
      return FluentSpotlightCard(spotlight: spotlight);
    else
      return MaterialSpotlightCard(spotlight: spotlight);
  }
}
