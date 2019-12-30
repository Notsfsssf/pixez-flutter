import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:path_provider/path_provider.dart';
import 'package:save_in_gallery/save_in_gallery.dart';

import './bloc.dart';

class SaveBloc extends Bloc<SaveEvent, SaveState> {
  final Dio dio = Dio(BaseOptions(headers: {
    "referer": "https://app-api.pixiv.net/",
    "User-Agent": "PixivIOSApp/5.8.0"
  }));

  @override
  SaveState get initialState => InitialSaveState();

  @override
  Stream<SaveState> mapEventToState(
    SaveEvent event,
  ) async* {
    if (event is SaveChoiceImageEvent) {}
    if (event is SaveImageEvent) {
      try {
        final illust = event.illusts;
        final index = event.index;
        final url = illust.metaPages.isNotEmpty
            ? illust.metaPages[index].imageUrls.original
            : illust.metaSinglePage.originalImageUrl;
        var file = await DefaultCacheManager().getFileFromCache(url);
        Uint8List uint8list;
        if (file == null) {
          Directory tempDir = await getTemporaryDirectory();
          String tempPath = tempDir.path;
          await dio.download(url, tempPath);
        } else {
          uint8list = await file.file.readAsBytes();
        }
        final _imageSaver = ImageSaver();
        List<Uint8List> bytesList = [uint8list];
        final res = await _imageSaver.saveImages(
            imageBytes: bytesList, directoryName: 'pxez');
        yield SaveSuccesState(res);
      } catch (e) {
        print(e);
      }
    }
  }
}
