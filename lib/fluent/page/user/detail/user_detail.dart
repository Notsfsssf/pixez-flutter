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
import 'package:flutter/services.dart';
import 'package:pixez/fluent/component/selectable_html.dart';
import 'package:pixez/er/leader.dart';
import 'package:pixez/i18n.dart';
import 'package:pixez/models/user_detail.dart';
import 'package:pixez/fluent/page/follow/follow_list.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class UserDetailPage extends StatefulWidget {
  final UserDetail userDetail;

  const UserDetailPage({Key? key, required this.userDetail}) : super(key: key);

  @override
  _UserDetailPageState createState() => _UserDetailPageState();
}

class _UserDetailPageState extends State<UserDetailPage> {
  @override
  Widget build(BuildContext context) {
    var detail = widget.userDetail;
    var profile = widget.userDetail.profile;
    var public = widget.userDetail.profile_publicity;
    return SelectionArea(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Card(
                child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: widget.userDetail.user.comment != null &&
                            widget.userDetail.user.comment!.isNotEmpty
                        ? SelectableHtml(data: widget.userDetail.user.comment!)
                        : SelectableHtml(
                            data: '~',
                          )),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Table(
                children: [
                  TableRow(children: [
                    Text(I18n.of(context).nickname),
                    Text(detail.user.name, textAlign: TextAlign.center)
                  ]),
                  TableRow(children: [
                    Text(I18n.of(context).painter_id),
                    HyperlinkButton(
                        child: Text(detail.user.id.toString()),
                        onPressed: () {
                          try {
                            Clipboard.setData(
                              ClipboardData(text: detail.user.id.toString()),
                            );
                          } catch (e) {}
                        }),
                  ]),
                  TableRow(children: [
                    Text(I18n.of(context).total_follow_users),
                    HyperlinkButton(
                        child:
                            Text(detail.profile.total_follow_users.toString()),
                        onPressed: () {
                          Leader.push(
                            context,
                            ScaffoldPage(
                              header: PageHeader(
                                title: Text(I18n.of(context).followed),
                              ),
                              content: FollowList(
                                id: widget.userDetail.user.id,
                              ),
                            ),
                            icon: Icon(FluentIcons.follow_user),
                            title: Text(I18n.of(context).followed),
                          );
                        }),
                  ]),
                  TableRow(children: [
                    Text(I18n.of(context).total_mypixiv_users),
                    HyperlinkButton(
                        child:
                            Text(detail.profile.total_mypixiv_users.toString()),
                        onPressed: () {
                          Leader.push(
                            context,
                            ScaffoldPage(
                              header: PageHeader(
                                title: Text(I18n.of(context).followed),
                              ),
                              content: FollowList(
                                id: widget.userDetail.user.id,
                                isFollowMe: true,
                              ),
                            ),
                            icon: Icon(FluentIcons.follow_user),
                            title: Text(I18n.of(context).followed),
                          );
                        }),
                  ]),
                  TableRow(children: [
                    Text(I18n.of(context).twitter_account),
                    HyperlinkButton(
                        child: Text(profile.twitter_account ?? ""),
                        onPressed: () async {
                          final url = profile.twitter_url;
                          if (url == null) return;

                          try {
                            await launchUrl(Uri.parse(url));
                          } catch (e) {
                            Share.share(url);
                          }
                        }),
                  ]),
                  TableRow(children: [
                    Text(I18n.of(context).gender),
                    Text(
                      detail.profile.gender ?? '',
                      textAlign: TextAlign.center,
                    ),
                  ]),
                  TableRow(children: [
                    Text(I18n.of(context).job),
                    Text(
                      detail.profile.job ?? '',
                      textAlign: TextAlign.center,
                    ),
                  ]),
                  TableRow(children: [
                    Text('Pawoo'),
                    HyperlinkButton(
                        child: Text(public.pawoo ? 'Link' : 'none'),
                        onPressed: () async {
                          if (!public.pawoo) return;
                          var url = detail.profile.pawoo_url;
                          if (url == null) return;
                          try {
                            await launchUrl(Uri.parse(url));
                          } catch (e) {}
                        }),
                  ]),
                ],
              ),
            ),
            Container(
              height: 200,
            )
          ],
        ),
      ),
    );
  }
}
