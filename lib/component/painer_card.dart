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

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:pixez/component/painter_avatar.dart';
import 'package:pixez/component/pixiv_image.dart';
import 'package:pixez/models/user_preview.dart';
import 'package:pixez/page/user/users_page.dart';

class PainterCard extends StatelessWidget {
  final UserPreviews user;

  const PainterCard({Key key, this.user}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.of(context, rootNavigator: true)
            .push(MaterialPageRoute(builder: (BuildContext context) {
          return UsersPage(
            id: user.user.id,
          );
        }));
      },
      child: Card(
                shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(8.0))),
        clipBehavior: Clip.antiAlias,
        child: StaggeredGridView.countBuilder(
          padding: EdgeInsets.all(0.0),
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          crossAxisCount: 3,
          itemBuilder: (BuildContext context, int index) {
            if (index != 3) {
              if (index < user.illusts.length) {
                return PixivImage(user.illusts[index].imageUrls.squareMedium);
              }
              return Container();
            }
            return buildPadding();
          },
          itemCount: 4,
          staggeredTileBuilder: (int index) =>
              StaggeredTile.fit(index != 3 ? 1 : 3),
        ),
      ),
    );
  }

  Padding buildPadding() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          PainterAvatar(
              url: user.user.profileImageUrls.medium, id: user.user.id),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(user.user.name),
          )
        ],
      ),
    );
  }
}
