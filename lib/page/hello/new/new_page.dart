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

import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:pixez/component/md2_tab_indicator.dart';
import 'package:pixez/constants.dart';
import 'package:pixez/i18n.dart';
import 'package:pixez/main.dart';
import 'package:pixez/page/follow/follow_list.dart';
import 'package:pixez/page/hello/new/fluent_new_state.dart';
import 'package:pixez/page/hello/new/illust/new_illust_page.dart';
import 'package:pixez/page/hello/new/material_new_state.dart';
import 'package:pixez/page/preview/preview_page.dart';
import 'package:pixez/page/user/bookmark/bookmark_page.dart';
import 'package:pixez/page/user/users_page.dart';

class NewPage extends StatefulWidget {
  final String newRestrict, bookRestrict, painterRestrict;

  const NewPage(
      {Key? key,
      this.newRestrict = "public",
      this.bookRestrict = "public",
      this.painterRestrict = "public"})
      : super(key: key);

  @override
  NewPageStateBase createState() {
    if (Constants.isFluentUI)
      return FluentNewPageState();
    else
      return MaterialNewPageState();
  }
}

abstract class NewPageStateBase extends State<NewPage>
    with AutomaticKeepAliveClientMixin, TickerProviderStateMixin {
  late StreamSubscription<String> subscription;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    subscription.cancel();
    super.dispose();
  }

  @override
  bool get wantKeepAlive => true;
}
