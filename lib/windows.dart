import 'dart:ffi';

import 'package:ffi/ffi.dart';
import 'package:flutter/widgets.dart' as ui;
import 'package:win32/winrt.dart';

/// 获取系统主题色
ui.Color getAccentColor() {
  final settings = UISettings();
  final color = settings.getColorValue(UIColorType.accent);
  return ui.Color.fromARGB(color.A, color.R, color.G, color.B);
}

/// 获取系统是否使用暗色主题
bool useDarkTheme() {
  final settings = UISettings();
  final color = settings.getColorValue(UIColorType.foreground);
  final isDark = (((5 * color.G) + (2 * color.R) + color.B) > (8 * 128));
  return isDark;
}

/// 判断系统build版本号是否大于 [build]
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

const _folder = '\\PixEz';

String? getAppDataFolderPath() {
  var path = UserDataPaths.getDefault()?.roamingAppData;
  if (path == null) return null;

  path += _folder;
  return path;
}

String? getPicturesFolderPath() {
  var path = UserDataPaths.getDefault()?.savedPictures;
  if (path == null) return null;

  path += _folder;
  return path;
}
