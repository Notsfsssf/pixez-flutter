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
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:pixez/er/leader.dart';
import 'package:pixez/i18n.dart';
import 'package:pixez/main.dart';
import 'package:pixez/page/fluent/follow/follow_list.dart';
import 'package:pixez/page/fluent/hello/new/illust/new_illust_page.dart';
import 'package:pixez/page/fluent/preview/preview_page.dart';
import 'package:pixez/page/fluent/user/bookmark/bookmark_page.dart';
import 'package:pixez/page/fluent/user/users_page.dart';

class NewPage extends StatefulWidget {
  final String newRestrict, bookRestrict, painterRestrict;
  final BookmarkPageMethodRelay relay;

  const NewPage(
      {Key? key,
      this.newRestrict = "public",
      this.bookRestrict = "public",
      this.painterRestrict = "public",
      required this.relay})
      : super(key: key);

  @override
  _NewPageState createState() => _NewPageState();
}

class _NewPageState extends State<NewPage>
    with AutomaticKeepAliveClientMixin, TickerProviderStateMixin {
  int _curentPage = 0;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Observer(builder: (context) {
      if (accountStore.now != null)
        return NavigationView(
          pane: NavigationPane(
            displayMode: PaneDisplayMode.top,
            selected: _curentPage,
            onChanged: (index) {
              setState(() => _curentPage = index);
            },
            items: [
              PaneItem(
                icon: Icon(FluentIcons.news),
                title: Text(I18n.of(context).news),
                body: NewIllustPage(),
              ),
              PaneItem(
                icon: Icon(FluentIcons.bookmarks),
                title: Text(I18n.of(context).bookmark),
                body: BookmarkPage(
                    isNested: false,
                    id: int.parse(accountStore.now!.userId),
                    relay: widget.relay),
              ),
              PaneItem(
                icon: Icon(FluentIcons.follow_user),
                title: Text(I18n.of(context).followed),
                body: FollowList(
                  id: int.parse(accountStore.now!.userId),
                ),
              ),
            ],
            footerItems: [
              if (_curentPage == 1)
                PaneItemAction(
                  onTap: () async {
                    await widget.relay.sort();
                  },
                  icon: Icon(FluentIcons.sort),
                ),
              PaneItemAction(
                icon: const Icon(FluentIcons.account_management),
                onTap: () {
                  Leader.push(context,
                      UsersPage(id: int.parse(accountStore.now!.userId)),
                      icon: const Icon(FluentIcons.account_management),
                      title: Text(I18n.of(context).my));
                },
              )
            ],
          ),
        );

      return NavigationView(
        pane: NavigationPane(
          displayMode: PaneDisplayMode.top,
          selected: _curentPage,
          onChanged: (index) {
            setState(() => _curentPage = index);
          },
          items: [
            PaneItem(
              icon: Icon(FluentIcons.news),
              title: Text(
                '${I18n.of(context).follow}${I18n.of(context).news}',
              ),
              body: LoginInFirst(),
            ),
            PaneItem(
              icon: Icon(FluentIcons.bookmarks),
              title: Text(
                '${I18n.of(context).personal}${I18n.of(context).bookmark}',
              ),
              body: LoginInFirst(),
            ),
            PaneItem(
              icon: Icon(FluentIcons.follow_user),
              title: Text(
                '${I18n.of(context).follow}${I18n.of(context).painter}',
              ),
              body: LoginInFirst(),
            ),
          ],
        ),
      );
    });
  }

  @override
  bool get wantKeepAlive => true;
}
