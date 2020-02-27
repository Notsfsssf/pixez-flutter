import 'dart:async';
import 'dart:io';

import 'package:archive/archive.dart';
import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pixez/models/ugoira_metadata_response.dart';
import 'package:pixez/network/api_client.dart';
import 'package:gifencoder/gifencoder.dart' as gifencoder;
import './bloc.dart';

class UgoiraMetadataBloc
    extends Bloc<UgoiraMetadataEvent, UgoiraMetadataState> {
  final ApiClient client;

  UgoiraMetadataBloc(this.client);

  @override
  Future<void> close() {
    return super.close();
  }

  @override
  UgoiraMetadataState get initialState => InitialUgoiraMetadataState();

  @override
  Stream<UgoiraMetadataState> mapEventToState(
    UgoiraMetadataEvent event,
  ) async* {
    if (event is EncodeToGifEvent) {
//      List<int> bytes = gifencoder.makeGif(width, height, data.data);
    }
    if (event is ProgressUgoiraMetadataEvent) {
      yield DownLoadProgressState(event.count, event.total);
    }
    if (event is FetchUgoiraMetadataEvent) {
      Directory tempDir = await getTemporaryDirectory();
      String tempPath = tempDir.path;
      String fullPath = "$tempPath/${event.id}.zip";
      File fullPathFile = File(fullPath);
      try {
        UgoiraMetadataResponse ugoiraMetadataResponse =
        await client.getUgoiraMetadata(event.id);
        String zipUrl = ugoiraMetadataResponse.ugoiraMetadata.zipUrls.medium;
        if (!fullPathFile.existsSync()) {
          Dio(BaseOptions(headers: {
            "referer": "https://app-api.pixiv.net/",
            "User-Agent": "PixivIOSApp/5.8.0"
          })).download(zipUrl, fullPath,
              onReceiveProgress: (int count, int total) {
                print("$count/$total");
                add(ProgressUgoiraMetadataEvent(count, total));
                if (count / total == 1) {
                  add(UnzipUgoiraMetadataEvent(event.id,ugoiraMetadataResponse));
                }
              }, deleteOnError: true);
        }else {
          add(UnzipUgoiraMetadataEvent(event.id,ugoiraMetadataResponse));
        }
      } catch (e) {
        print(e);
        if (fullPathFile.existsSync()) fullPathFile.deleteSync();
        if (Directory('$tempPath/${event.id}/').existsSync()) {
          Directory('$tempPath/${event.id}/').deleteSync(recursive: true);
        }
      }
    }
    if (event is UnzipUgoiraMetadataEvent) {
      try {
        Directory tempDir = await getTemporaryDirectory();
        String tempPath = tempDir.path;
        String fullPath = "$tempPath/${event.id}.zip";
        File fullPathFile = File(fullPath);
        // Read the Zip file from disk.
        final bytes = fullPathFile.readAsBytesSync();

        // Decode the Zip file
        final archive = ZipDecoder().decodeBytes(bytes);

        // Extract the contents of the Zip archive to disk.
        for (final file in archive) {
          final filename = file.name;
          if (file.isFile) {
            final data = file.content as List<int>;
            File('$tempPath/${event.id}/' + filename)
              ..createSync(recursive: true)
              ..writeAsBytesSync(data);
          } else {
            Directory('$tempPath/${event.id}/' + filename)
              ..create(recursive: true);
          }
        }
        Directory zipDirectory = Directory('$tempPath/${event.id}/');
        var listSync = zipDirectory.listSync();
        listSync.sort((l, r) => l.path.compareTo(r.path));
        yield PlayUgoiraMetadataState(
            listSync, event.ugoiraMetadataResponse.ugoiraMetadata.frames);
      } catch (e) {}
    }
  }
}
