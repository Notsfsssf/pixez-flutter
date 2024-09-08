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

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:pixez/component/painter_avatar.dart';
import 'package:pixez/component/pixiv_image.dart';
import 'package:pixez/exts.dart';
import 'package:pixez/models/user_preview.dart';
import 'package:pixez/page/novel/user/novel_users_page.dart';
import 'package:pixez/page/user/user_store.dart';
import 'package:pixez/page/user/users_page.dart';

class PainterCard extends StatelessWidget {
  final UserPreviews user;
  final bool isNovel;

  const PainterCard({Key? key, required this.user, this.isNovel = false})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.of(context, rootNavigator: true)
            .push(MaterialPageRoute(builder: (BuildContext context) {
          if (isNovel) {
            return NovelUsersPage(
              id: user.user.id,
            );
          }
          return UsersPage(
            id: user.user.id,
            userStore: UserStore(user.user.id, null, user.user),
          );
        }));
      },
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: Container(
          child: Column(
            children: [_buildPreviewSlivers(context), buildPadding(context)],
          ),
        ),
      ),
    );
  }

  _buildPreviewSlivers(BuildContext context) {
    return (isNovel)
        ? Row(
            children: [
              for (var i = 0; i < 3; i++)
                Expanded(
                  child: i < user.novels.length
                      ? AspectRatio(
                          aspectRatio: 1.0,
                          child: Stack(
                            children: [
                              AspectRatio(
                                aspectRatio: 1.0,
                                child: PixivImage(
                                  user.novels[i].imageUrls.squareMedium,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              Align(
                                alignment: Alignment.bottomCenter,
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    user.novels[i].title,
                                    style:
                                        Theme.of(context).textTheme.titleSmall,
                                    maxLines: 3,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              )
                            ],
                          ),
                        )
                      : Container(),
                )
            ],
          )
        : Row(
            children: [
              for (var i = 0; i < 3; i++)
                Expanded(
                  child: i < user.illusts.length
                      ? AspectRatio(
                          aspectRatio: 1.0,
                          child: PixivImage(
                            user.illusts[i].imageUrls.squareMedium,
                            fit: BoxFit.cover,
                          ),
                        )
                      : Container(),
                )
            ],
          );
  }

  Widget buildPadding(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Hero(
            tag: user.user.profileImageUrls.medium + this.hashCode.toString(),
            child: PainterAvatar(
              url: user.user.profileImageUrls.medium,
              id: user.user.id,
              onTap: () {
                Navigator.of(context, rootNavigator: true)
                    .push(MaterialPageRoute(builder: (BuildContext context) {
                  if (isNovel) {
                    return NovelUsersPage(
                      id: user.user.id,
                    );
                  }
                  return UsersPage(
                    id: user.user.id,
                    userStore: UserStore(user.user.id, null, user.user),
                    heroTag: this.hashCode.toString(),
                  );
                }));
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Center(child: Text(user.user.name)),
          ),
        ],
      ),
    );
  }
}
