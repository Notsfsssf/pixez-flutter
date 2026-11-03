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

import 'package:flutter/widgets.dart';
import 'package:pixez/utils/haptic_util.dart';
import 'package:pixez/utils/novel_quick_save.dart';

/// 小说条目「长按直接保存」。
///
/// 推荐 / 排行 / 最新 / 搜索 / 收藏 / 系列 / 历史等页面共用：
/// 长按抬手立刻拉正文并写成 txt（存到设置里的保存位置），
/// **不弹任何二次菜单**，也不需要再点一次。
///
/// 用 [_saving] 做防重入：连续长按不会重复发请求。
Future<void> novelLongPressSave(
  BuildContext context, {
  required int id,
  String? title,
}) async {
  HapticUtil.heavy();
  if (_saving) return;
  _saving = true;
  try {
    await NovelQuickSave.save(context, id, title: title);
  } finally {
    _saving = false;
  }
}

bool _saving = false;
