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

import 'package:bot_toast/bot_toast.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:pixez/er/leader.dart';
import 'package:pixez/i18n.dart';
import 'package:pixez/main.dart';
import 'package:pixez/models/ban_illust_id.dart';
import 'package:pixez/models/ban_tag.dart';
import 'package:pixez/models/ban_user_id.dart';
import 'package:pixez/models/show_ai_response.dart';
import 'package:pixez/network/api_client.dart';
import 'package:pixez/page/shield/user_show_ai_setting.dart';

class ShieldPage extends StatefulWidget {
  @override
  _ShieldPageState createState() => _ShieldPageState();
}

class _ShieldPageState extends State<ShieldPage> {
  @override
  void initState() {
    muteStore.fetchBanAI();
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
                    ListTile(
                      title: Text(I18n.of(context).ai_work_display_settings),
                      onTap: () async {
                        try {
                          BotToast.showLoading();
                          Response response =
                              await apiClient.getUserAISettings();
                          var showAIResponse =
                              ShowAIResponse.fromJson(response.data);
                          Leader.push(context,
                              UserShowAISetting(showAI: showAIResponse.showAI));
                        } catch (e) {
                        } finally {
                          BotToast.closeAllLoading();
                        }
                      },
                    ),
                    ListTile(
                      title: Text(I18n.of(context)
                          .make_works_with_ai_generated_flags_invisible),
                      trailing: Switch(
                        value: muteStore.banAIIllust,
                        onChanged: (v) {
                          muteStore.changeBanAI(v);
                        },
                      ),
                    ),
                    Divider(),
                    Row(
                      children: [
                        Text(I18n.of(context).tag),
                        IconButton(
                            onPressed: () {
                              _showBanTagAddDialog(context);
                            },
                            icon: Icon(Icons.add))
                      ],
                    ),
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
                    Row(
                      children: [
                        Text(I18n.of(context).painter),
                        Opacity(
                          child: IconButton(
                              onPressed: () {}, icon: Icon(Icons.add)),
                          opacity: 0.0,
                        )
                      ],
                    ),
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
                    Row(
                      children: [
                        Text(I18n.of(context).illust),
                        Opacity(
                          child: IconButton(
                              onPressed: () {}, icon: Icon(Icons.add)),
                          opacity: 0.0,
                        )
                      ],
                    ),
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
          content: Text(I18n.of(context).delete_tag),
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

  _showBanTagAddDialog(BuildContext context) async {
    final controller = TextEditingController();
    final result = await showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(I18n.of(context).input),
            content: TextField(
              controller: controller,
              decoration: InputDecoration(
                  hintText: I18n.of(context).tag,
                  hintStyle: TextStyle(fontSize: 12)),
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.pop(context, controller.text);
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
        });
    if (result != null && result is String && result.isNotEmpty) {
      muteStore.insertBanTag(BanTagPersist(name: result, translateName: ""));
    }
  }

  Future _deleteIllust(BuildContext context, BanIllustIdPersist f) async {
    final result = await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(I18n.of(context).delete),
          content: Text(I18n.of(context).delete_tag),
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
          content: Text(I18n.of(context).delete_tag),
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
