import 'dart:ffi';
import 'dart:io';

import 'package:ffi/ffi.dart';
import 'package:flutter/foundation.dart';
import 'package:win32/winrt.dart';
import 'package:win32_registry/win32_registry.dart';

registerProtocol(String scheme, String desc, String template) {
  // 向操作系统注册协议
  // 仅在调试时使用这个, 发布时使用msix 已经自动注册了所以不需要手动修改了
  if (!kDebugMode) return;

  String appPath = Platform.resolvedExecutable;

  String protocolRegKey = 'Software\\Classes\\$scheme';
  const protocolCmdRegKey = 'shell\\open\\command';

  final regKey = Registry.currentUser.createKey(protocolRegKey);
  regKey.createValue(RegistryValue('', RegistryValueType.string, desc));
  regKey.createValue(
      const RegistryValue('URL Protocol', RegistryValueType.string, ''));
  regKey.createKey(protocolCmdRegKey).createValue(
      RegistryValue('', RegistryValueType.string, '$appPath $template'));
}

int getAccentColor() {
  final settings = UISettings();
  final color = settings.getColorValue(UIColorType.accent);
  var c = color.A;
  c <<= 8;
  c += color.R;
  c <<= 8;
  c += color.G;
  c <<= 8;
  c += color.B;
  return c;
}

bool isDarkMode() {
  final settings = UISettings();
  final color = settings.getColorValue(UIColorType.foreground);
  final isDark = (((5 * color.G) + (2 * color.R) + color.B) > (8 * 128));
  return isDark;
}

bool isBuildOrGreater(int build) {
  final lpVersionInformation = calloc<OSVERSIONINFOEX>()
    ..ref.dwBuildNumber = build;

  final dwlConditionMask = VerSetConditionMask(
    0,
    VER_BUILDNUMBER,
    VER_GREATER_EQUAL,
  );
  try {
    return VerifyVersionInfo(
          lpVersionInformation,
          VER_BUILDNUMBER,
          dwlConditionMask,
        ) ==
        TRUE;
  } finally {
    free(lpVersionInformation);
  }
}

String? getAppDataFolderPath() {
  var path = UserDataPaths.getDefault()?.roamingAppData;
  if (path == null) return null;

  path += '\\PixEz';
  return path;
}

String? getPicturesFolderPath() {
  var path = UserDataPaths.getDefault()?.savedPictures;
  if (path == null) return null;

  path += '\\PixEz';
  return path;
}
