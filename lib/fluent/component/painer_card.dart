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

import 'package:fluent_ui/fluent_ui.dart';
import 'package:pixez/er/leader.dart';
import 'package:pixez/fluent/component/painter_avatar.dart';
import 'package:pixez/fluent/component/pixez_button.dart';
import 'package:pixez/fluent/component/pixiv_image.dart';
import 'package:pixez/i18n.dart';
import 'package:pixez/models/user_preview.dart';
import 'package:pixez/page/novel/user/novel_users_page.dart';
import 'package:pixez/page/user/user_store.dart';
import 'package:pixez/fluent/page/user/users_page.dart';

class PainterCard extends StatelessWidget {
  final UserPreviews user;
  final bool isNovel;

  const PainterCard({Key? key, required this.user, this.isNovel = false})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PixEzButton(
      child: CustomScrollView(
        physics: NeverScrollableScrollPhysics(),
        slivers: [
          SliverGrid(
              gridDelegate:
                  SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3),
              delegate: SliverChildBuilderDelegate((context, index) {
                if (index >= user.illusts.length) return Container();
                return PixivImage(
                  user.illusts[index].imageUrls.squareMedium,
                  fit: BoxFit.cover,
                );
              }, childCount: user.illusts.length)),
          SliverToBoxAdapter(child: buildPadding(context))
        ],
      ),
      onPressed: () {
        Widget widget;
        if (isNovel) {
          widget = NovelUsersPage(
            id: user.user.id,
          );
        } else {
          widget = UsersPage(
            id: user.user.id,
            userStore: UserStore(user.user.id, null, user.user),
          );
        }
        Leader.push(context, widget,
            title: Text(I18n.of(context).painter_id + ': ${user.user.id}'),
            icon: Icon(FluentIcons.account_browser));
      },
    );
  }

  Padding buildPadding(BuildContext context) {
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
                Widget widget;
                if (isNovel) {
                  widget = NovelUsersPage(
                    id: user.user.id,
                  );
                } else {
                  widget = UsersPage(
                    id: user.user.id,
                    userStore: UserStore(user.user.id, null, user.user),
                    heroTag: this.hashCode.toString(),
                  );
                }
                Leader.push(context, widget,
                    title:
                        Text(I18n.of(context).painter_id + ': ${user.user.id}'),
                    icon: Icon(FluentIcons.account_browser));
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
