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
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:pixez/component/selectable_html.dart';
import 'package:pixez/i18n.dart';
import 'package:pixez/models/user_detail.dart';
import 'package:pixez/page/follow/follow_list.dart';
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
    if (widget.userDetail == null) {
      return Container();
    }
    var detail = widget.userDetail;
    var profile = widget.userDetail.profile;
    var public = widget.userDetail.profile_publicity;
    return widget.userDetail != null
        ? SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Card(
                    child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: widget.userDetail.user.comment.isNotEmpty
                            ? SelectableHtml(
                                data: widget.userDetail.user.comment)
                            : SelectableHtml(
                                data: '~',
                              )),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: DataTable(
                    columns: <DataColumn>[
                      DataColumn(label: Text(I18n.of(context).nickname)),
                      DataColumn(
                          label: Expanded(
                              child: SelectableText(detail.user.name))),
                    ],
                    rows: <DataRow>[
                      DataRow(cells: [
                        DataCell(Text(I18n.of(context).painter_id)),
                        DataCell(SelectableText(detail.user.id.toString()),
                            onTap: () {
                          try {
                            Clipboard.setData(
                                ClipboardData(text: detail.user.id.toString()));
                          } catch (e) {}
                        }),
                      ]),
                      DataRow(cells: [
                        DataCell(Text(I18n.of(context).total_follow_users)),
                        DataCell(
                            Text(detail.profile.total_follow_users.toString()),
                            onTap: () {
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (BuildContext context) {
                            return Scaffold(
                              appBar: AppBar(
                                title: Text(I18n.of(context).followed),
                              ),
                              body: FollowList(id: widget.userDetail.user.id),
                            );
                          }));
                        }),
                      ]),
                      DataRow(cells: [
                        DataCell(Text(I18n.of(context).total_mypixiv_users)),
                        DataCell(Text(
                            detail.profile.total_mypixiv_users.toString())),
                      ]),
                      DataRow(cells: [
                        DataCell(Text(I18n.of(context).twitter_account)),
                        DataCell(Text(profile.twitter_account),
                            onTap: () async {
                          final url = profile.twitter_url;
                          try {
                            await launch(url);
                          } catch (e) {}
                        }),
                      ]),
                      DataRow(cells: [
                        DataCell(Text(I18n.of(context).gender)),
                        DataCell(Text(detail.profile.gender)),
                      ]),
                      DataRow(cells: [
                        DataCell(Text(I18n.of(context).job)),
                        DataCell(Text(detail.profile.job)),
                      ]),
                      DataRow(cells: [
                        DataCell(Text('Pawoo')),
                        DataCell(Text(public.pawoo ? 'Link' : 'none'),
                            onTap: () async {
                          if (!public.pawoo) return;
                          var url = detail.profile.pawoo_url;
                          try {
                            await launch(url);
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
          )
        : Container();
  }
}
