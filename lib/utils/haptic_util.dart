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

import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:pixez/main.dart';

/// 触感反馈工具类
class HapticUtil {
  /// 是否支持触感反馈且用户设置开启
  static bool get _isEnabled {
    if (kIsWeb) return false;
    if (!Platform.isAndroid && !Platform.isIOS) return false;
    try {
      return userSetting.hapticFeedback;
    } catch (_) {
      return true;
    }
  }

  /// 轻微刻度/齿轮反馈（用于 Tab 切换、底部栏选择、列表滑动等）
  static void selectionClick() {
    if (_isEnabled) {
      HapticFeedback.selectionClick();
    }
  }

  /// 轻度触感反馈（用于轻量操作确认、下载完成等）
  static void light() {
    if (_isEnabled) {
      HapticFeedback.lightImpact();
    }
  }

  /// 中度触感反馈（用于点赞/收藏、关注/取消关注等核心操作）
  static void medium() {
    if (_isEnabled) {
      HapticFeedback.mediumImpact();
    }
  }

  /// 重度触感反馈（用于长按快捷保存、长按弹窗菜单等手势识别）
  static void heavy() {
    if (_isEnabled) {
      HapticFeedback.heavyImpact();
    }
  }

  /// 常规震动
  static void vibrate() {
    if (_isEnabled) {
      HapticFeedback.vibrate();
    }
  }
}
