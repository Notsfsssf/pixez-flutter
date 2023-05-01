import 'dart:ffi';
import 'dart:io';

import 'package:ffi/ffi.dart';
import 'package:path_provider_windows/path_provider_windows.dart';
import 'package:win32/win32.dart';
import 'package:win32_registry/win32_registry.dart';

int getAccentColor() {
  final crColorization = calloc<DWORD>();
  final fOpaqueBlend = calloc<Int32>();
  try {
    final result = DwmGetColorizationColor(crColorization, fOpaqueBlend);
    if (result == S_OK) {
      return crColorization.value;
    } else {
      throw WindowsException(result);
    }
  } finally {
    free(crColorization);
    free(fOpaqueBlend);
  }
}

bool isDarkMode() {
  try {
    final key = Registry.openPath(
      RegistryHive.currentUser,
      path: 'SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Themes\\Personalize',
    );
    final value = key.getValue('AppsUseLightTheme');
    if (value != null && value.type == RegistryValueType.int32) {
      return value.data == 0;
    }
  } catch (error) {
    print(error);
  }
  return false;
}

registerProtocol(String scheme, String desc, String template) {
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

Future<String?> getPictureFolderPath() async {
  final PathProviderWindows provider = PathProviderWindows();
  String? result;
  result = await provider.getPath(FOLDERID_SavedPictures);
  // ignore: unnecessary_null_comparison
  if (result != null) return result;

  result = await provider.getPath(FOLDERID_Pictures);
  // ignore: unnecessary_null_comparison
  if (result != null) return result;

  return null;
}
