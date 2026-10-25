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

/// Android 17（API 37）本地网络权限。
///
/// Android 17 起，targetSdk ≥ 37 的应用默认被系统拦截一切局域网访问
/// （TCP / UDP / 组播 / `.local` 解析），必须持有 `ACCESS_LOCAL_NETWORK`
/// 运行时权限。表现就是：云端接口填 `http://192.168.x.x:port/v1` 时，
/// 请求直接失败（连接被系统拒绝，既不是 404 也不是超时）。
///
/// 旧系统上该权限恒为已授予，这里的调用是空操作。
library;

import 'dart:io';

import 'package:permission_handler/permission_handler.dart';

/// 是否已有本地网络权限（非 Android / 旧系统恒 true）。
Future<bool> hasLocalNetworkPermission() async {
  if (!Platform.isAndroid) return true;
  return Permission.accessLocalNetwork.isGranted;
}

/// 确保拥有本地网络权限；必要时弹系统授权框。
///
/// 返回 false 表示用户拒绝或系统限制，调用方应给出可操作的提示。
Future<bool> ensureLocalNetworkPermission() async {
  if (!Platform.isAndroid) return true;
  final status = await Permission.accessLocalNetwork.status;
  if (status.isGranted) return true;
  // 被永久拒绝时再 request 不会弹框，直接返回失败让 UI 引导去设置。
  if (status.isPermanentlyDenied || status.isRestricted) return false;
  final result = await Permission.accessLocalNetwork.request();
  return result.isGranted;
}

/// 打开本应用的系统权限设置页。
Future<bool> openLocalNetworkSettings() => openAppSettings();
