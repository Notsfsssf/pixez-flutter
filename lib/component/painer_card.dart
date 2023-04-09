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
import 'package:pixez/component/painter_avatar.dart';
import 'package:pixez/component/pixiv_image.dart';
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
            userStore: UserStore(user.user.id, user: user.user),
          );
        }));
      },
      child: Card(
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(8.0))),
        clipBehavior: Clip.antiAlias,
        child: Container(
          height: (MediaQuery.of(context).size.width - 4) / 3 + 80,
          child: CustomScrollView(
            physics: NeverScrollableScrollPhysics(),
            slivers: [
              _buildPreviewSlivers(context),
              SliverToBoxAdapter(child: buildPadding(context))
            ],
          ),
        ),
      ),
    );
  }

  _buildPreviewSlivers(BuildContext context) {
    final needBlankSliver =
        (isNovel && user.novels.isEmpty) || (!isNovel && user.illusts.isEmpty);
    if (needBlankSliver)
      return SliverToBoxAdapter(
        child: Container(
          height: (MediaQuery.of(context).size.width) / 3,
        ),
      );
    return (isNovel)
        ? SliverGrid(
            gridDelegate:
                SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3),
            delegate: SliverChildBuilderDelegate((context, index) {
              if (index >= user.novels.length) return Container();
              final novel = user.novels[index];
              return Stack(
                children: [
                  PixivImage(
                    novel.imageUrls.squareMedium,
                    fit: BoxFit.cover,
                  ),
                  Align(
                    alignment: Alignment.topCenter,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        novel.title,
                        style: Theme.of(context).textTheme.titleSmall,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  )
                ],
              );
            }, childCount: user.illusts.length))
        : SliverGrid(
            gridDelegate:
                SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3),
            delegate: SliverChildBuilderDelegate((context, index) {
              if (index >= user.illusts.length) return Container();
              return PixivImage(
                user.illusts[index].imageUrls.squareMedium,
                fit: BoxFit.cover,
              );
            }, childCount: user.illusts.length));
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
                    userStore: UserStore(user.user.id, user: user.user),
                    heroTag: this.hashCode.toString(),
                  );
                }));
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(user.user.name),
          ),
        ],
      ),
    );
  }
}
