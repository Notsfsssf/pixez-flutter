import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pixez/models/illust.dart';
import 'package:save_in_gallery/save_in_gallery.dart';

import './bloc.dart';

class AlreadyGoingOnException implements Exception {}

class SaveBloc extends Bloc<SaveEvent, SaveState> {
  final Dio dio = Dio(BaseOptions(headers: {
    "referer": "https://app-api.pixiv.net/",
    "User-Agent": "PixivIOSApp/5.8.0"
  }));
  Map<String, ProgressNum> progressMaps = Map();

  @override
  SaveState get initialState => InitialSaveState();

  saveImage(String url, Illusts illusts) {
    if (progressMaps.keys.contains(url)) throw AlreadyGoingOnException();
    add(SaveStartEvent());
    saveAsync(url, illusts);
  }

  saveAsync(String url, Illusts illusts) async {
    var file = await DefaultCacheManager().getFileFromCache(url);
    Uint8List uint8list;
    if (file == null) {
      Directory tempDir = await getTemporaryDirectory();
      String tempPath = tempDir.path;
      String fullPath =
          "$tempPath/${DateTime.now().toIso8601String()}.${url.contains("png") ? "png" : "jpg"}"; //???
      try {
        await dio.download(url, fullPath, deleteOnError: true,
            onReceiveProgress: (a, b) async {
          print('$a/$b');
          progressMaps[url] = ProgressNum(a, b, illusts);
          add(SaveProgressImageEvent(progressMaps));
          if (a / b >= 1) {
            File file = File(fullPath);
            uint8list = await file.readAsBytes();
            add(SaveToPictureFoldEvent(uint8list));
          }
        });
      } catch (e) {
        progressMaps.remove(url);
      }
    } else {
      uint8list = await file.file.readAsBytes();
      add(SaveToPictureFoldEvent(uint8list));
    }
  }

  static const platform = const MethodChannel('samples.flutter.dev/battery');

  Stream<SaveSuccesState> _mapSaveSuccesState(
      SaveToPictureFoldEvent event) async* {
    if (Platform.isAndroid) {
      final inputDate = event.uint8list;
      final int result =
          await platform.invokeMethod('getBatteryLevel', inputDate);
    }
    if (Platform.isIOS) {
      final _imageSaver = ImageSaver();
      List<Uint8List> bytesList = [event.uint8list];
      final res = await _imageSaver.saveImages(
          imageBytes: bytesList, directoryName: 'pxez');
      yield SaveSuccesState(res);
    }
  }

  @override
  Stream<SaveState> mapEventToState(
    SaveEvent event,
  ) async* {
    if (event is SaveStartEvent) {
      yield SaveStartState();
    }
    if (event is SaveToPictureFoldEvent) {
      yield* _mapSaveSuccesState(event);
    }
    if (event is SaveProgressImageEvent) {
      yield SaveProgressSate(event.progressMaps);
    }
    if (event is SaveChoiceImageEvent) {
      final illust = event.illusts;
      final index = event.indexs;
      if (illust.metaPages.isNotEmpty) {
        for (int i = 0; i < illust.metaPages.length; i++) {
          if (index[i]) {
            try {
              saveImage(illust.metaPages[i].imageUrls.original, illust);
            } on AlreadyGoingOnException {
              print('Already');
              yield SaveAlreadyGoingOnState();
            } catch (e) {}
          }
        }
      } else {
        try {
          saveImage(illust.metaSinglePage.originalImageUrl, illust);
        } on AlreadyGoingOnException {
          print('Already');
          yield SaveAlreadyGoingOnState();
        } catch (e) {}
      }
    }
    if (event is SaveImageEvent) {
      try {
        final illust = event.illusts;
        final index = event.index;
        final url = illust.metaPages.isNotEmpty
            ? illust.metaPages[index].imageUrls.original
            : illust.metaSinglePage.originalImageUrl;
        saveImage(url, illust);
      } on AlreadyGoingOnException {
        print('Already');
        yield SaveAlreadyGoingOnState();
      } catch (e) {}
    }
  }
}

class NoNeedException implements Exception {}

List<String> a = [];

tryToDownLoad(String url) {
  if (a.contains(url)) throw NoNeedException();
  Dio().download(url, 'a.txt', onReceiveProgress: (min, max) {});
}

main() {}
