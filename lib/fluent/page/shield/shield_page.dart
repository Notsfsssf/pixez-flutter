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
        return ContentDialog(
          title: Text(I18n.of(context).shielding_settings),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(I18n.of(context).tag),
                Container(
                  child: Wrap(
                    spacing: 2.0,
                    runSpacing: 2.0,
                    direction: Axis.horizontal,
                    children: muteStore.banTags
                        .map(
                          (f) => Button(
                            onPressed: () => deleteTag(context, f),
                            child: Text(f.name),
                          ),
                        )
                        .toList(),
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
                        .map(
                          (f) => Button(
                            onPressed: () => _deleteUserIdTag(context, f),
                            child: Text(f.name ?? ""),
                          ),
                        )
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
                    children: muteStore.banillusts
                        .map(
                          (f) => Button(
                            onPressed: () => _deleteIllust(context, f),
                            child: Text(f.name),
                          ),
                        )
                        .toList(),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            FilledButton(
              child: Text(I18n.of(context).ok),
              onPressed: Navigator.of(context).pop,
            ),
          ],
        );
      },
    );
  }

  Future deleteTag(BuildContext context, BanTagPersist f) async {
    final result = await showDialog(
      context: context,
      useRootNavigator: false,
      builder: (context) {
        return ContentDialog(
          title: Text(I18n.of(context).delete),
          content: Text(I18n.of(context).delete_tag),
          actions: [
            Button(
              child: Text(I18n.of(context).cancel),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(context, "OK");
              },
              child: Text(I18n.of(context).ok),
            ),
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
      useRootNavigator: false,
      builder: (context) {
        return ContentDialog(
          title: Text(I18n.of(context).delete),
          content: Text(I18n.of(context).delete_tag),
          actions: [
            Button(
              child: Text(I18n.of(context).cancel),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(context, "OK");
              },
              child: Text(I18n.of(context).ok),
            ),
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
      useRootNavigator: false,
      builder: (context) {
        return ContentDialog(
          title: Text(I18n.of(context).delete),
          content: Text(I18n.of(context).delete_tag),
          actions: [
            Button(
              child: Text(I18n.of(context).cancel),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(context, "OK");
              },
              child: Text(I18n.of(context).ok),
            ),
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
