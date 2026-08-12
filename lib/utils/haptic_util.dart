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
  static int _lastTriggerTime = 0;

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

  /// 检查是否满足节流间隔，避免高频并发震动导致马达粘滞或手部疲劳
  /// [force] 为 true 时跳过开关检查，仅用于触感反馈开关开启时的即时确认
  static bool _canTrigger([int minIntervalMs = 60, bool force = false]) {
    if (!force && !_isEnabled) return false;
    final now = DateTime.now().millisecondsSinceEpoch;
    if (now - _lastTriggerTime < minIntervalMs) {
      return false;
    }
    _lastTriggerTime = now;
    return true;
  }

  static void _trigger(Future<void> Function() action, int minIntervalMs,
      {bool force = false}) {
    if (_canTrigger(minIntervalMs, force)) {
      try {
        action();
      } catch (_) {}
    }
  }

  /// 轻微刻度/齿轮反馈（用于作品点击、Tab 切换、底部栏选择、列表滑动等）
  static void selectionClick({int minIntervalMs = 50}) => _trigger(HapticFeedback.selectionClick, minIntervalMs);

  /// 轻度触感反馈（用于轻量操作确认、取消关注/收藏等）
  /// [force] 为 true 时跳过开关检查，仅用于触感反馈开关开启时的即时确认
  static void light({int minIntervalMs = 80, bool force = false}) =>
      _trigger(HapticFeedback.lightImpact, minIntervalMs, force: force);

  /// 中度触感反馈（用于点赞/收藏、关注等核心操作）
  static void medium({int minIntervalMs = 100}) => _trigger(HapticFeedback.mediumImpact, minIntervalMs);

  /// 重度触感反馈（用于长按快捷保存、长按弹窗菜单等手势识别）
  static void heavy({int minIntervalMs = 120}) => _trigger(HapticFeedback.heavyImpact, minIntervalMs);

  /// 成功类状态反馈（用于下载完成、操作达成等）
  static void success({int minIntervalMs = 120}) => _trigger(HapticFeedback.mediumImpact, minIntervalMs);

  /// 警告类状态反馈（用于二次确认弹窗等敏感操作）
  static void warning({int minIntervalMs = 150}) => _trigger(HapticFeedback.heavyImpact, minIntervalMs);

  /// 失败/错误类状态反馈（用于下载失败、网络异常等）
  static void error({int minIntervalMs = 150}) => _trigger(HapticFeedback.heavyImpact, minIntervalMs);

  /// 常规震动
  static void vibrate({int minIntervalMs = 150}) => _trigger(HapticFeedback.vibrate, minIntervalMs);
}
