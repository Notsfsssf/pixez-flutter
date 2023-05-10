import 'dart:ffi';

import 'package:ffi/ffi.dart';
import 'package:win32/winrt.dart';

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
