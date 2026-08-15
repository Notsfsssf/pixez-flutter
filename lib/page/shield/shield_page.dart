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
import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';
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
import 'package:pixez/utils/haptic_util.dart';

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
        final sortedBanTags = muteStore.banTags.toList()
          ..sort(
            (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
          );
        return Scaffold(
          appBar: AppBar(title: Text(I18n.of(context).shielding_settings)),
          body: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Card(
                  margin: const EdgeInsets.fromLTRB(8, 8, 8, 0),
                  child: Column(
                    children: [
                      ListTile(
                        leading: Icon(Icons.smart_toy_outlined),
                        title: Text(I18n.of(context).ai_work_display_settings),
                        trailing: Icon(Icons.chevron_right),
                        onTap: () async {
                          try {
                            BotToast.showLoading();
                            Response response = await apiClient
                                .getUserAISettings();
                            var showAIResponse = ShowAIResponse.fromJson(
                              response.data,
                            );
                            Leader.push(
                              context,
                              UserShowAISetting(showAI: showAIResponse.showAI),
                            );
                          } catch (e) {
                          } finally {
                            BotToast.closeAllLoading();
                          }
                        },
                      ),
                      SwitchListTile(
                        secondary: Icon(Icons.visibility_off_outlined),
                        title: Text(
                          I18n.of(
                            context,
                          ).make_works_with_ai_generated_flags_invisible,
                        ),
                        value: muteStore.banAIIllust,
                        onChanged: (v) {
                          HapticUtil.light();
                          muteStore.changeBanAI(v);
                        },
                      ),
                    ],
                  ),
                ),
                _buildBanSection(
                  context,
                  title: I18n.of(context).tag,
                  icon: Icons.label_outline,
                  onAdd: () => _showBanTagAddDialog(context),
                  children: sortedBanTags
                      .map(
                        (f) => GestureDetector(
                          onLongPress: () {
                            HapticUtil.heavy();
                            Clipboard.setData(ClipboardData(text: f.name));
                            BotToast.showText(
                              text: I18n.of(context).copied_to_clipboard,
                            );
                          },
                          child: ActionChip(
                            onPressed: () => deleteTag(context, f),
                            label: Text(f.name),
                          ),
                        ),
                      )
                      .toList(),
                ),
                _buildBanSection(
                  context,
                  title: I18n.of(context).painter,
                  icon: Icons.person_outline,
                  children: muteStore.banUserIds
                      .map(
                        (f) => ActionChip(
                          onPressed: () => _deleteUserIdTag(context, f),
                          label: Text(f.name ?? ""),
                        ),
                      )
                      .toList(),
                ),
                _buildBanSection(
                  context,
                  title: I18n.of(context).illust,
                  icon: Icons.image_outlined,
                  children: muteStore.banillusts
                      .map(
                        (f) => ActionChip(
                          onPressed: () => _deleteIllust(context, f),
                          label: Text(f.name),
                        ),
                      )
                      .toList(),
                ),
                Container(height: MediaQuery.of(context).padding.bottom + 20),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildBanSection(
    BuildContext context, {
    required String title,
    required IconData icon,
    required List<Widget> children,
    VoidCallback? onAdd,
  }) {
    return Card(
      margin: const EdgeInsets.fromLTRB(8, 16, 8, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ListTile(
            leading: Icon(icon),
            title: Text(title),
            trailing: onAdd == null
                ? null
                : IconButton(onPressed: onAdd, icon: Icon(Icons.add)),
          ),
          if (children.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Wrap(spacing: 8.0, runSpacing: 8.0, children: children),
            )
          else
            const SizedBox(height: 8),
        ],
      ),
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
              child: Text(I18n.of(context).cancel),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            TextButton(
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

  _showBanTagAddDialog(BuildContext context) async {
    final controller = TextEditingController();
    final result = await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(I18n.of(context).input),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('regex example:"r\'pattern\'"'),
              SizedBox(height: 8),
              TextField(
                controller: controller,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: I18n.of(context).input_regexp_hint,
                  hintStyle: TextStyle(fontSize: 12),
                ),
                onSubmitted: (value) {
                  Navigator.pop(context, value);
                },
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: Text(I18n.of(context).cancel),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context, controller.text);
              },
              child: Text(I18n.of(context).ok),
            ),
          ],
        );
      },
    );
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
              child: Text(I18n.of(context).cancel),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            TextButton(
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
      builder: (context) {
        return AlertDialog(
          title: Text(I18n.of(context).delete),
          content: Text(I18n.of(context).delete_tag),
          actions: <Widget>[
            TextButton(
              child: Text(I18n.of(context).cancel),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            TextButton(
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
