import 'dart:async';
import 'dart:typed_data';

import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:pixez/models/illust.dart';
import 'package:pixez/network/api_client.dart';
import 'package:save_in_gallery/save_in_gallery.dart';

import './bloc.dart';

class PictureBloc extends Bloc<PictureEvent, PictureState> {
  final ApiClient client;
  PictureBloc(this.client);

  @override
  PictureState get initialState => InitialPictureState();

  @override
  Stream<PictureState> mapEventToState(
    PictureEvent event,
  ) async* {
    if (event is StarEvent) {
      if (!event.illusts.isBookmarked) {
        try {
          Response response =
              await client.postLikeIllust(event.illusts.id, "public", null);
          yield DataState(event.illusts..isBookmarked = true);
        } catch (e) {}
      } else {
        try {
          Response response = await client.postUnLikeIllust(event.illusts.id);
          yield DataState(event.illusts..isBookmarked = false);
        } catch (e) {}
      }
    }
    if (event is SaveImageEvent) {
      try {
        final illust = event.illusts;
        final index = event.index;
        var file = await DefaultCacheManager().getFileFromCache(
            illust.metaPages.isNotEmpty
                ? illust.metaPages[index].imageUrls.medium
                : illust.imageUrls.medium);
        final data = await file.file.readAsBytes();
        final _imageSaver = ImageSaver();
        List<Uint8List> bytesList = [data];
        final res = await _imageSaver.saveImages(
            imageBytes: bytesList, directoryName: 'pxez');
        yield SaveSuccesState(res);
      } catch (e) {
        debugPrint(e);
      }
    }
  }
}
