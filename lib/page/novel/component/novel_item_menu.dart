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
import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';
import 'package:pixez/i18n.dart';
import 'package:pixez/main.dart';
import 'package:pixez/models/ban_illust_id.dart';
import 'package:pixez/models/novel_recom_response.dart';
import 'package:pixez/utils/haptic_util.dart';

enum _NovelMenuAction { muteUser, muteNovel, copyTitle }

/// 小说条目的长按菜单：屏蔽作者 / 屏蔽作品 / 复制标题。
///
/// 推荐页（NovelRecomPage）以及排行 / 最新 / 搜索 / 收藏等共用
/// NovelLightingList 的页面都调用这里，避免同一段菜单逻辑到处复制。
Future<void> showNovelItemMenu(BuildContext context, Novel novel) async {
  HapticUtil.heavy();
  final i18n = I18n.of(context);
  final action = await showModalBottomSheet<_NovelMenuAction>(
    context: context,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (sheetContext) {
      return SafeArea(
        child: Container(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  novel.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(sheetContext).textTheme.titleMedium,
                ),
              ),
              ListTile(
                leading: const Icon(Icons.person_off_outlined),
                title: Text(I18n.of(sheetContext).block_user),
                subtitle: Text(novel.user.name),
                onTap: () =>
                    Navigator.of(sheetContext).pop(_NovelMenuAction.muteUser),
              ),
              ListTile(
                leading: const Icon(Icons.brightness_auto),
                title: Text(I18n.of(sheetContext).ban),
                subtitle: Text('#${novel.id}'),
                onTap: () =>
                    Navigator.of(sheetContext).pop(_NovelMenuAction.muteNovel),
              ),
              ListTile(
                leading: const Icon(Icons.copy),
                title: Text(I18n.of(sheetContext).copy),
                onTap: () =>
                    Navigator.of(sheetContext).pop(_NovelMenuAction.copyTitle),
              ),
            ],
          ),
        ),
      );
    },
  );
  if (action == null || !context.mounted) return;
  switch (action) {
    case _NovelMenuAction.muteUser:
      await _confirmAndMuteAuthor(context, novel);
      break;
    case _NovelMenuAction.muteNovel:
      await muteStore.insertBanIllusts(BanIllustIdPersist(
        illustId: novel.id.toString(),
        name: novel.title,
      ));
      BotToast.showText(text: i18n.shield_message(novel.title));
      break;
    case _NovelMenuAction.copyTitle:
      await Clipboard.setData(ClipboardData(text: novel.title));
      BotToast.showText(text: i18n.copied_to_clipboard);
      break;
  }
}

Future<void> _confirmAndMuteAuthor(BuildContext context, Novel novel) async {
  final i18n = I18n.of(context);
  final result = await showDialog(
    context: context,
    builder: (dialogContext) {
      return AlertDialog(
        title: Text(i18n.block_user),
        content: Text('${novel.user.name} (${novel.user.id})'),
        actions: <Widget>[
          TextButton(
            child: Text(I18n.of(dialogContext).cancel),
            onPressed: () => Navigator.of(dialogContext).pop(),
          ),
          TextButton(
            child: Text(I18n.of(dialogContext).ok),
            onPressed: () => Navigator.of(dialogContext).pop("OK"),
          ),
        ],
      );
    },
  );
  if (result != "OK") return;
  await muteStore.insertBanUserId(novel.user.id.toString(), novel.user.name);
  BotToast.showText(text: i18n.shield_message(novel.user.name));
}
