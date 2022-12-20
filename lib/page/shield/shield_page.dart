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
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:pixez/i18n.dart';
import 'package:pixez/main.dart';
import 'package:pixez/models/ban_illust_id.dart';
import 'package:pixez/models/ban_tag.dart';
import 'package:pixez/models/ban_user_id.dart';

class ShieldPage extends StatefulWidget {
  @override
  _ShieldPageState createState() => _ShieldPageState();
}

class _ShieldPageState extends State<ShieldPage> {
  @override
  void initState() {
    muteStore.fetchBanUserIds();
    muteStore.fetchBanIllusts();
    muteStore.fetchBanUserIds();
    muteStore.fetchBanComments();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Observer(
      builder: (_) {
        return Scaffold(
            appBar: AppBar(
              title: Text(I18n.of(context).shielding_settings),
              actions: [
                // IconButton(
                //     onPressed: () {
                //       muteStore.export();
                //     },
                //     icon: Icon(Icons.expand_circle_down_outlined))
              ],
            ),
            body: Padding(
              padding: const EdgeInsets.all(8.0),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Text(I18n.of(context).tag),
                    Container(
                      child: Wrap(
                        spacing: 2.0,
                        runSpacing: 2.0,
                        direction: Axis.horizontal,
                        children: <Widget>[
                          ...muteStore.banTags
                              .map((f) => ActionChip(
                                    onPressed: () => deleteTag(context, f),
                                    label: Text(f.name),
                                  ))
                              .toList()
                        ],
                      ),
                    ),
                    Divider(),
                    Text(I18n.of(context).painter),
                    Container(
                      child: Wrap(
                        spacing: 2.0,
                        runSpacing: 2.0,
                        direction: Axis.horizontal,
                        children: muteStore.banUserIds
                            .map((f) => ActionChip(
                                  onPressed: () => _deleteUserIdTag(context, f),
                                  label: Text(f.name ?? ""),
                                ))
                            .toList(),
                      ),
                    ),
                    Divider(),
                    Text(I18n.of(context).illust),
                    Container(
                      child: Wrap(
                        spacing: 2.0,
                        runSpacing: 2.0,
                        direction: Axis.horizontal,
                        children: <Widget>[
                          ...muteStore.banillusts
                              .map((f) => ActionChip(
                                    onPressed: () => _deleteIllust(context, f),
                                    label: Text(f.name),
                                  ))
                              .toList()
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ));
      },
    );
  }

  Future deleteTag(BuildContext context, BanTagPersist f) async {
    final result = await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(I18n.of(context).delete),
          content: Text('Delete this tag?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.pop(context, "OK");
              },
              child: Text(I18n.of(context).ok),
            ),
            TextButton(
              child: Text(I18n.of(context).cancel),
              onPressed: () {
                Navigator.pop(context);
              },
            )
          ],
        );
      },
    );
    switch (result) {
      case "OK":
        {
          muteStore.deleteBanTag(f.id!);
        }
        break;
    }
  }

  Future _deleteIllust(BuildContext context, BanIllustIdPersist f) async {
    final result = await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(I18n.of(context).delete),
          content: Text('Delete this tag?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.pop(context, "OK");
              },
              child: Text(I18n.of(context).ok),
            ),
            TextButton(
              child: Text(I18n.of(context).cancel),
              onPressed: () {
                Navigator.pop(context);
              },
            )
          ],
        );
      },
    );
    switch (result) {
      case "OK":
        {
          muteStore.deleteBanIllusts(f.id!);
        }
        break;
    }
  }

  Future _deleteUserIdTag(BuildContext context, BanUserIdPersist f) async {
    final result = await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(I18n.of(context).delete),
          content: Text('Delete this tag?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.pop(context, "OK");
              },
              child: Text(I18n.of(context).ok),
            ),
            TextButton(
              child: Text(I18n.of(context).cancel),
              onPressed: () {
                Navigator.pop(context);
              },
            )
          ],
        );
      },
    );
    switch (result) {
      case "OK":
        {
          muteStore.deleteBanUserId(f.id!);
        }
        break;
    }
  }
}
