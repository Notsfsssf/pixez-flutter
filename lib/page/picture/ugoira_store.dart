import 'dart:io';

import 'package:archive/archive.dart';
import 'package:dio/dio.dart';
import 'package:mobx/mobx.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pixez/models/ugoira_metadata_response.dart';
import 'package:pixez/network/api_client.dart';
part 'ugoira_store.g.dart';

enum UgoiraStatus { pre, progress, play }
class UgoiraStore = _UgoiraStoreBase with _$UgoiraStore;

abstract class _UgoiraStoreBase with Store {
  final int id;

  _UgoiraStoreBase(this.id);
  @observable
  UgoiraStatus status;
  @observable
  int count=0;
  @observable
  int total=1;

  List<FileSystemEntity> drawPool;
  UgoiraMetadataResponse ugoiraMetadataResponse;
  @action
  unZip() async {
    Directory tempDir = await getTemporaryDirectory();
    String tempPath = tempDir.path;
    String fullPath = "$tempPath/${id}.zip";
    File fullPathFile = File(fullPath);
    try {
      // Read the Zip file from disk.
      final bytes = fullPathFile.readAsBytesSync();

      // Decode the Zip file
      final archive = ZipDecoder().decodeBytes(bytes);

      // Extract the contents of the Zip archive to disk.
      for (final file in archive) {
        final filename = file.name;
        if (file.isFile) {
          final data = file.content as List<int>;
          File('$tempPath/$id/' + filename)
            ..createSync(recursive: true)
            ..writeAsBytesSync(data);
        } else {
          Directory('$tempPath/$id/' + filename)..create(recursive: true);
        }
      }
      Directory zipDirectory = Directory('$tempPath/$id/');
      var listSync = zipDirectory.listSync();
      listSync.sort((l, r) => l.path.compareTo(r.path));
      drawPool = listSync;
      status = UgoiraStatus.play;
    } catch (e) {
      print(e);
      if (fullPathFile.existsSync()) fullPathFile.deleteSync();
      if (Directory('$tempPath/$id/').existsSync()) {
        Directory('$tempPath/$id/').deleteSync(recursive: true);
      }
      status = UgoiraStatus.pre;
    }
  }

  @action
  downloadAndUnzip() async {
    status = UgoiraStatus.progress;
    Directory tempDir = await getTemporaryDirectory();
    String tempPath = tempDir.path;
    String fullPath = "$tempPath/$id.zip";
    File fullPathFile = File(fullPath);
    try {
      ugoiraMetadataResponse = await apiClient.getUgoiraMetadata(id);
      String zipUrl = ugoiraMetadataResponse.ugoiraMetadata.zipUrls.medium;
      if (!fullPathFile.existsSync()) {
        Dio(BaseOptions(headers: {
          "referer": "https://app-api.pixiv.net/",
          "User-Agent": "PixivIOSApp/5.8.0"
        })).download(zipUrl, fullPath,
            onReceiveProgress: (int count, int total) {
          print("$count/$total");
          this.count = count;
          this.total = total;
          if (count / total == 1) {
            unZip();
          }
        }, deleteOnError: true);
      } else {
        unZip();
      }
    } catch (e) {
      print(e);
      if (fullPathFile.existsSync()) fullPathFile.deleteSync();
      if (Directory('$tempPath/$id/').existsSync()) {
        Directory('$tempPath/$id/').deleteSync(recursive: true);
      }
      status = UgoiraStatus.pre;
    }
  }
}
