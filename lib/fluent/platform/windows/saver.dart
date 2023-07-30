import 'package:flutter/foundation.dart';
import 'package:windows_storage/windows_storage.dart';

class Saver {
  static Future<StorageFolder?> _getFolder() async {
    final base = KnownFolders.savedPictures ?? KnownFolders.picturesLibrary;
    return await base?.createFolderAsync(
        "Pixez", CreationCollisionOption.openIfExists);
  }

  static Future<bool?> save(
    Uint8List uint8list,
    String fileName, {
    bool clearOld = false,
    int? saveMode,
  }) async {
    try {
      final folder = await _getFolder();
      final file = await folder?.createFileAsync(
          fileName, CreationCollisionOption.replaceExisting);
      if (file == null) return false;
      await FileIO.writeBytesAsync(file, uint8list);
      return true;
    } catch (e) {
      debugPrint(e.toString());
      return false;
    }
  }

  static Future<bool?> exist(
    String fileName, {
    int? saveMode,
  }) async {
    final folder = await _getFolder();
    final list = await folder
        ?.createFileQueryOverloadDefault()
        ?.getFilesAsyncDefaultStartAndCount();
    return list?.any((i) => i?.name == fileName);
  }
}
