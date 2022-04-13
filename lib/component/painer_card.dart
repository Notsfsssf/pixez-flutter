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
import 'package:pixez/component/painer_card/fluent.dart';
import 'package:pixez/component/painer_card/material.dart';
import 'package:pixez/constants.dart';
import 'package:pixez/models/user_preview.dart';

abstract class PainterCardBase extends StatelessWidget {
  final UserPreviews user;
  final bool isNovel;

  const PainterCardBase({Key? key, required this.user, this.isNovel = false})
      : super(key: key);
}

class PainterCard extends PainterCardBase {
  const PainterCard({
    Key? key,
    required UserPreviews user,
    bool isNovel = false,
  }) : super(key: key, user: user, isNovel: isNovel);

  @override
  Widget build(BuildContext context) {
    if (Constants.isFluentUI)
      return FluentPainterCard(user: user, isNovel: isNovel);
    else
      return MaterialPainterCard(user: user, isNovel: isNovel);
  }
}
