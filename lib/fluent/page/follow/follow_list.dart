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
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:pixez/fluent/component/sort_group.dart';
import 'package:pixez/i18n.dart';
import 'package:pixez/lighting/lighting_store.dart';
import 'package:pixez/main.dart';
import 'package:pixez/network/api_client.dart';
import 'package:pixez/fluent/page/painter/painter_list.dart';

class FollowList extends StatefulWidget {
  final int id;
  final bool isNovel;
  final bool isFollowMe;

  FollowList(
      {Key? key,
      required this.id,
      this.isNovel = false,
      this.isFollowMe = false})
      : super(key: key);

  @override
  _FollowListState createState() => _FollowListState();
}

class _FollowListState extends State<FollowList>
    with AutomaticKeepAliveClientMixin {
  late FutureGet futureGet;
  String restrict = 'public';

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void initState() {
    futureGet = widget.isFollowMe
        ? () => apiClient.getFollowUser(widget.id, restrict)
        : () => apiClient.getUserFollowing(widget.id, restrict);
    super.initState();
  }

  Widget buildHeader() {
    return Observer(builder: (_) {
      return Visibility(
        visible: int.parse(accountStore.now!.userId) == widget.id,
        child: Align(
          alignment: Alignment.topCenter,
          child: SortGroup(
            children: [I18n.of(context).public, I18n.of(context).private],
            onChange: (index) {
              setState(() {
                restrict = index == 0 ? 'public' : 'private';
                futureGet =
                    () => apiClient.getUserFollowing(widget.id, restrict);
              });
            },
          ),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Stack(
      children: <Widget>[
        PainterList(
          futureGet: futureGet,
          isNovel: widget.isNovel,
          header: Container(
            height: widget.isFollowMe ? 0 : 45,
          ),
        ),
        if (!widget.isFollowMe) buildHeader(),
      ],
    );
  }

  @override
  bool get wantKeepAlive => true;
}
