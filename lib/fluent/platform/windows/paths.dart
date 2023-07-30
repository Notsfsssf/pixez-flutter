import 'package:windows_storage/windows_storage.dart';

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
