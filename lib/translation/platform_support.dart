/*
 * Copyright (C) 2020. by perol_notsf, All rights reserved
 *
 * This program is free software: you can redistribute it and/or modify it under
 * the terms of the GNU General Public License as published by the Free Software
 * Foundation, either version 3 of the License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General
 * Public License for more details.
 *
 * You should have received a copy of the GNU General Public License along with
 * this program.  If not, see <http://www.gnu.org/licenses/>.
 */

/// 端侧翻译的平台适配判定 + 统一「尚未适配」弹窗。
///
/// 端侧模型依赖 `libllamashim` 原生库，目前只为 Android（64 位）编译并
/// 随 APK 打包（android/app/src/main/cpp + AGP externalNativeBuild）。
/// iOS / macOS / Windows / Linux 既没有原生产物，也没接进各自的构建流程，
/// 所以这些平台上端侧引擎必然起不来。
///
/// 注意边界：**只拦端侧**。云端引擎是纯 HTTP（OpenAiCompatibleTranslator），
/// 任何平台都能用，不要在平台层把整条翻译功能一起关掉——那会把真能用的
/// 能力也砍了。
library;

import 'dart:ffi' show Abi;
import 'dart:io' show Platform;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:material_ui/material_ui.dart';

/// 当前设备是否已适配端侧翻译（原生库 + 构建链路都齐）。
///
/// 与 [kLocalLlmAbiSupported] 同一份事实：那个名字现在只是这里的别名，
/// 保留是为了不动已有的调用点。
bool get isLocalTranslationAdapted {
  if (kIsWeb) return false;
  if (!Platform.isAndroid) return false;
  final abi = Abi.current();
  return abi == Abi.androidArm64 || abi == Abi.androidX64;
}

/// 当前运行平台的人类可读名。
///
/// 弹窗要给用户看，不能再出现「windowsX64 尚未适配」这种把 ABI 名当平台名
/// 的文案——那会让人以为是自己的机器装错了版本。
String get currentPlatformLabel {
  if (kIsWeb) return 'Web';
  if (Platform.isAndroid) return 'Android（${Abi.current()}）';
  if (Platform.isIOS) return 'iOS';
  if (Platform.isMacOS) return 'macOS';
  if (Platform.isWindows) return 'Windows';
  if (Platform.isLinux) return 'Linux';
  if (Platform.isFuchsia) return 'Fuchsia';
  return Platform.operatingSystem;
}

/// 「这台设备为什么用不了端侧模型」——设置页副标题与弹窗正文共用。
///
/// Android 上唯一原因是 32 位包（设备或安装包），文案要指向解决办法；
/// 其他平台是确实还没适配，说明清楚并给出替代路径。
String localTranslationUnsupportedReason() {
  if (kIsWeb) {
    return 'Web 端无法加载端侧推理库（dart:ffi 不可用），请改用云端引擎。';
  }
  if (Platform.isAndroid) {
    return 'app 正以 32 位模式运行（${Abi.current()}），端侧模型需要 64 位。'
        '请安装 arm64-v8a / universal 版 APK，或改用云端引擎。';
  }
  return '端侧模型目前只为 Android（64 位）编译，${currentPlatformLabel} 还没有适配。'
      '云端接口（OpenAI 兼容）不受影响，填好地址即可在本机使用。';
}

/// 统一的「当前设备尚未适配」弹窗。
///
/// [onOpenCloudSettings] 由调用方提供：本文件属于翻译内核层，不反向依赖
/// 设置页，否则以后桌面版复用这套逻辑时还得再抽一次。
Future<void> showDeviceNotAdaptedDialog(
  BuildContext context, {
  VoidCallback? onOpenCloudSettings,
}) {
  return showDialog<void>(
    context: context,
    builder: (dialogContext) {
      final theme = Theme.of(dialogContext);
      return AlertDialog(
        title: Row(
          children: [
            Icon(Icons.devices_other, size: 20, color: theme.colorScheme.primary),
            const SizedBox(width: 8),
            const Text('当前设备尚未适配'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(localTranslationUnsupportedReason()),
            const SizedBox(height: 12),
            Text(
              '当前运行平台：$currentPlatformLabel',
              style: theme.textTheme.bodySmall,
            ),
          ],
        ),
        actions: [
          if (onOpenCloudSettings != null)
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                onOpenCloudSettings();
              },
              child: const Text('配置云端接口'),
            ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('知道了'),
          ),
        ],
      );
    },
  );
}
