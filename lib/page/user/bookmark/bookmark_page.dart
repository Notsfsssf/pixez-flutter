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
import 'package:pixez/constants.dart';
import 'package:pixez/lighting/lighting_page.dart';
import 'package:pixez/lighting/lighting_store.dart';
import 'package:pixez/main.dart';
import 'package:pixez/network/api_client.dart';
import 'package:pixez/page/user/bookmark/fluent_state.dart';
import 'package:pixez/page/user/bookmark/material_state.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class BookmarkPage extends StatefulWidget {
  final int id;
  final String restrict;
  final bool isNested;

  const BookmarkPage({
    Key? key,
    required this.id,
    this.restrict = "public",
    this.isNested = false,
  }) : super(key: key);

  @override
  BookmarkPageStateBase createState() {
    if (Constants.isFluentUI)
      return FluentBookmarkPageState();
    else
      return MaterialBookmarkPageState();
  }
}

abstract class BookmarkPageStateBase extends State<BookmarkPage> {
  late LightSource futureGet;
  String restrict = 'public';
  late RefreshController refreshController;
  late StreamSubscription<String> subscription;

  @override
  void initState() {
    refreshController = RefreshController();
    restrict = widget.restrict;
    futureGet = ApiForceSource(
        futureGet: (e) =>
            apiClient.getBookmarksIllust(widget.id, restrict, null));
    super.initState();
    subscription = topStore.topStream.listen((event) {
      if (event == "302") {
        refreshController.position?.jumpTo(0);
      }
    });
  }

  @override
  void dispose() {
    subscription.cancel();
    refreshController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (accountStore.now != null) {
      if (int.parse(accountStore.now!.userId) == widget.id) {
        return Stack(
          children: [
            LightingList(
              source: futureGet,
              refreshController: refreshController,
              header: Container(
                height: 45,
              ),
            ),
            buildTopChip(context)
          ],
        );
      }
      return LightingList(
        isNested: widget.isNested,
        source: futureGet,
      );
    } else {
      return Container();
    }
  }

  Widget buildTopChip(BuildContext context);
}
