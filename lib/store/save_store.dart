import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:bot_toast/bot_toast.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:mobx/mobx.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pixez/generated/i18n.dart';
import 'package:pixez/models/illust.dart';
import 'package:pixez/page/progress/progress_page.dart';
import 'package:save_in_gallery/save_in_gallery.dart';
part 'save_store.g.dart';

enum SaveState { JOIN, SUCCESS, ALREADY }

class ProgressNum {
  int min, max;
  Illusts illusts;
  ProgressNum(this.min, this.max, this.illusts);
}

class SaveStream {
  SaveState state;
  Illusts data;
  SaveStream(this.state, this.data);
}

void listenBehavior(BuildContext context, SaveStream stream) {
  switch (stream.state) {
    case SaveState.SUCCESS:
      BotToast.showNotification(
          leading: (_) => Icon(
                Icons.check_circle,
                color: Colors.green,
              ),
          title: (_) => Text("${stream.data.title} ${I18n.of(context).Saved}"),
          onTap: () {});
      break;
    case SaveState.JOIN:
      BotToast.showNotification(
          trailing: (_) => Icon(Icons.arrow_right),
          title: (_) => Text("${I18n.of(context).Append_to_query}"),
          onTap: () {
            Navigator.of(context, rootNavigator: true)
                .push(MaterialPageRoute(builder: (context) {
              return ProgressPage();
            }));
          });
      break;

    default:
  }
}

class SaveStore = _SaveStoreBase with _$SaveStore;

abstract class _SaveStoreBase with Store {
  _SaveStoreBase() {
    _streamController = StreamController();
    saveStream = ObservableStream(_streamController.stream);
  }

  @override
  void dispose() async {
    await _streamController?.close();
  }

  I18n i18n;
  @action
  void initContext(I18n context) {
    this.i18n = context;
  }

  @observable
  ObservableMap<String, ProgressNum> progressMaps = ObservableMap();
  StreamController<SaveStream> _streamController;
  ObservableStream<SaveStream> saveStream;
  final Dio _dio = Dio(BaseOptions(headers: {
    "referer": "https://app-api.pixiv.net/",
    "User-Agent": "PixivIOSApp/5.8.0"
  }));
  _saveInternal(String url, Illusts illusts) async {
    BotToast.showNotification(title: (_) => Text(i18n.Append_to_query));
    var file = await DefaultCacheManager().getFileFromCache(url);
    Uint8List uint8list;

    if (file == null) {
      Directory tempDir = await getTemporaryDirectory();
      String tempPath = tempDir.path;
      String fullPath =
          "$tempPath/${DateTime.now().toIso8601String()}.${url.contains("png") ? "png" : "jpg"}"; //???
      try {
        await _dio.download(url, fullPath, deleteOnError: true,
            onReceiveProgress: (a, b) async {
          // print('$a/$b');
          progressMaps[url] = ProgressNum(a, b, illusts);
          if (a / b >= 1) {
            File file = File(fullPath);
            uint8list = await file.readAsBytes();
            await _saveToGallery(uint8list, illusts);
            progressMaps.remove(url);
            _streamController.add(SaveStream(SaveState.SUCCESS, illusts));
          }
        });
      } catch (e) {
        progressMaps.remove(url);
      }
    } else {
      uint8list = await file.file.readAsBytes();
      _saveToGallery(uint8list, illusts);
    }
  }

  static const platform = const MethodChannel('com.perol.dev/save');
  Future<void> _saveToGallery(Uint8List uint8list, Illusts illusts) async {
    String fileName = "";
    String memType = illusts.imageUrls.large.contains("png") ? "png" : "jpg";
    fileName = "${illusts.id}_p${illusts.pageCount - 1}.${memType}";
    if (Platform.isAndroid) {
      try {
        await platform
            .invokeMethod('save', {"data": uint8list, "name": fileName});
      } catch (e) {}
      return;
    } else {
      final _imageSaver = ImageSaver();
      List<Uint8List> bytesList = [uint8list];
      final res = await _imageSaver.saveImages(
          imageBytes: bytesList, directoryName: 'pxez');
    }
  }

  @action
  void saveChoiceImage(Illusts illusts, List<bool> indexs) {
    if (illusts.pageCount == 1) {
      saveImage(illusts);
    } else {
      for (var i = 0; i < indexs.length; i++) {
        if (indexs[i]) {
          saveImage(illusts, index: i);
        }
      }
    }
  }

  @action
  Future<void> saveImage(Illusts illusts, {int index}) async {
    String fileName = "";
    String memType = illusts.imageUrls.large.contains("png") ? "png" : "jpg";
    fileName = "${illusts.id}_p${illusts.pageCount - 1}.${memType}";
    if (Platform.isAndroid) {
      try {
        bool result = await platform.invokeMethod("exist",{"name":fileName});

        if (result) {
          _streamController.add(SaveStream(SaveState.SUCCESS, illusts));
          return;
        }
      } catch (e) {}
    }
    if (illusts.pageCount == 1) {
      _saveInternal(illusts.metaSinglePage.originalImageUrl, illusts);
    } else {
      if (index != null) {
        var url = illusts.metaPages[index].imageUrls.original;
        if (progressMaps.keys.contains(url)) {
          _streamController.add(SaveStream(SaveState.SUCCESS, illusts));
          return;
        }
        _saveInternal(url, illusts);
      } else {
        illusts.metaPages.forEach((f) {
          var url = f.imageUrls.original;
          if (progressMaps.keys.contains(url)) {
            _streamController.add(SaveStream(SaveState.SUCCESS, illusts));
          } else
            _saveInternal(url, illusts);
        });
      }
    }
  }
}
