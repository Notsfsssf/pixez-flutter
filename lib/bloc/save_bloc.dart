import 'dart:async';
import 'dart:typed_data';
import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:save_in_gallery/save_in_gallery.dart';
import './bloc.dart';

class SaveBloc extends Bloc<SaveEvent, SaveState> {
  @override
  SaveState get initialState => InitialSaveState();

  @override
  Stream<SaveState> mapEventToState(
    SaveEvent event,
  ) async* {
    if (event is SaveChoiceImageEvent) {

    }
    if (event is SaveImageEvent) {
      try {
        final illust = event.illusts;
        final index = event.index;
        final url = illust.metaPages.isNotEmpty
            ? illust.metaPages[index].imageUrls.medium
            : illust.imageUrls.medium;
        var file = await DefaultCacheManager().getFileFromCache(url);
        Uint8List uint8list;
        if (file == null) {
          Response<List<int>> response = await Dio(BaseOptions(headers: {
            "referer": "https://app-api.pixiv.net/",
            "User-Agent": "PixivIOSApp/5.8.0"
          },responseType: ResponseType.bytes,)).get<List<int>>(url);
          uint8list =   Uint8List.fromList(response.data);
        }else{
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
