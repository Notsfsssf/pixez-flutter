import 'dart:ffi';

import 'package:ffi/ffi.dart';
import 'package:win32/win32.dart';

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
