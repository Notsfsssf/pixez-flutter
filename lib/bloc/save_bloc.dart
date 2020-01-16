import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:path_provider/path_provider.dart';
import 'package:save_in_gallery/save_in_gallery.dart';

import './bloc.dart';

class AlreadyGoingOnException {}

class SaveBloc extends Bloc<SaveEvent, SaveState> {
  List<String> taskImages = [];
  final Dio dio = Dio(BaseOptions(headers: {
    "referer": "https://app-api.pixiv.net/",
    "User-Agent": "PixivIOSApp/5.8.0"
  }));

  @override
  SaveState get initialState => InitialSaveState();

  Future<bool> saveImage(String url) async {
    if (taskImages.contains(url)) {
      throw AlreadyGoingOnException();
    }
    taskImages.add(url);
    var file = await DefaultCacheManager().getFileFromCache(url);
    Uint8List uint8list;
    if (file == null) {
      Directory tempDir = await getTemporaryDirectory();
      String tempPath = tempDir.path;
      String fullPath =
          "$tempPath/${DateTime.now().toIso8601String()}.${url.contains("png") ? "png" : "jpg"}"; //???
      await dio.download(url, fullPath,onReceiveProgress: (a,b){
        print('$a/$b');
      });
      File file = File(fullPath);
      uint8list = await file.readAsBytes();
    } else {
      uint8list = await file.file.readAsBytes();
    }
    final _imageSaver = ImageSaver();
    List<Uint8List> bytesList = [uint8list];
    final res = await _imageSaver.saveImages(
        imageBytes: bytesList, directoryName: 'pxez');
    taskImages.remove(url);
    return res;
  }

  @override
  Stream<SaveState> mapEventToState(
    SaveEvent event,
  ) async* {
    if (event is SaveChoiceImageEvent) {
      final illust = event.illusts;
      final index = event.indexs;
      if (illust.metaPages.isNotEmpty) {
        for (int i = 0; i < illust.metaPages.length; i++) {
          if (index[i]) {
            try {
              final res =
                  await saveImage(illust.metaPages[i].imageUrls.original);
            } catch (e) {
              if (e is AlreadyGoingOnException) {
                print("already");
                yield SaveAlreadyGoingOnState();
              }
            }
          }
        }
      } else {
        try {
          final res = await saveImage(illust.metaSinglePage.originalImageUrl);
          yield SaveSuccesState(res);
        } catch (e) {
          if (e is AlreadyGoingOnException) {
            print('Already');
            yield SaveAlreadyGoingOnState();
          }
        }
      }
    }
    if (event is SaveImageEvent) {
      try {
        final illust = event.illusts;
        final index = event.index;
        final url = illust.metaPages.isNotEmpty
            ? illust.metaPages[index].imageUrls.original
            : illust.metaSinglePage.originalImageUrl;
        final res = await saveImage(url);
        yield SaveSuccesState(res);
      } catch (e) {
        print(e);
        if (e is AlreadyGoingOnException) {
          yield SaveAlreadyGoingOnState();
        }
      }
    }
  }
}
