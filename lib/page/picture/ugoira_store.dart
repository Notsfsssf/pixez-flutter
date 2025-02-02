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

import 'dart:io';
import 'package:archive/archive.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:dio/dio.dart';
import 'package:mobx/mobx.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pixez/er/hoster.dart';
import 'package:pixez/er/lprinter.dart';
import 'package:pixez/main.dart';
import 'package:pixez/models/ugoira_metadata_response.dart';
import 'package:pixez/network/api_client.dart';
import 'package:pixez/saf_plugin.dart';

part 'ugoira_store.g.dart';

enum UgoiraStatus { pre, progress, play }

class UgoiraStore = _UgoiraStoreBase with _$UgoiraStore;

abstract class _UgoiraStoreBase with Store {
  final int id;

  _UgoiraStoreBase(this.id);

  @observable
  UgoiraStatus? status;
  @observable
  int count = 0;
  @observable
  int total = 1;

  List<FileSystemEntity> drawPool = [];
  UgoiraMetadataResponse? ugoiraMetadataResponse;

  export() async {
    try {
      Directory tempDir = await getTemporaryDirectory();
      String tempPath = tempDir.path;
      String fullPath = "$tempPath/${id}.zip";
      File fullPathFile = File(fullPath);
      if (fullPathFile.existsSync()) {
        final data = fullPathFile.readAsBytesSync();
        if (Platform.isAndroid) {
          try {
            String? uriString =
                await SAFPlugin.createFile("${id}.zip", "application/zip");
            uriString!;
            await SAFPlugin.writeUri(uriString, data);
            BotToast.showText(text: "export success");
            return;
          } catch (e) {}
        }
        Directory? directory = await getExternalStorageDirectory();
        Directory zipFolder = Directory("${directory!.path}/ugoira_zip/");
        if (!zipFolder.existsSync()) {
          zipFolder.createSync(recursive: true);
        }
        File targetFile = File("${zipFolder.path}/${id}.zip");
        fullPathFile.copySync(targetFile.path);
        BotToast.showText(text: "export ${targetFile.path} success");
      }
    } catch (e) {
      LPrinter.d(e);
    }
  }

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
      String zipUrl =
          ugoiraMetadataResponse!.ugoiraMetadata.zipUrls.medium;
      if (!fullPathFile.existsSync()) {
        var dio = Dio(BaseOptions(
            headers: Hoster.header(
                url: ugoiraMetadataResponse!.ugoiraMetadata.zipUrls.medium)));
        if (!userSetting.disableBypassSni) {
          dio.httpClientAdapter = await ApiClient.createCompatibleClient();
        }
        dio.download(zipUrl, fullPath,
            onReceiveProgress: (int count, int total) {
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
      if (fullPathFile.existsSync()) fullPathFile.deleteSync();
      if (Directory('$tempPath/$id/').existsSync()) {
        Directory('$tempPath/$id/').deleteSync(recursive: true);
      }
      status = UgoiraStatus.pre;
    }
  }
}
