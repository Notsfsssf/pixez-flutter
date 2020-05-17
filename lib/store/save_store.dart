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
import 'package:pixez/main.dart';
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
          leading: (_) => Icon(Icons.arrow_downward),
          title: (_) => Text("${I18n.of(context).Append_to_query}"),
          onTap: () {
            Navigator.of(context, rootNavigator: true)
                .push(MaterialPageRoute(builder: (context) {
              return ProgressPage();
            }));
          });
      break;
    case SaveState.ALREADY:
      BotToast.showNotification(
          leading: (_) => Icon(Icons.info),
          title: (_) => Text("${I18n.of(context).Already_Saved}"),
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
    saveStream = ObservableStream(_streamController.stream.asBroadcastStream());
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
  _saveInternal(String url, Illusts illusts, String fileName) async {
    try {
      final fullPath = "${userSetting.path}/${fileName}";
      if (File(fullPath).existsSync()) {
        _streamController.add(SaveStream(SaveState.ALREADY, illusts));
        return;
      }
    } catch (e) {}
    _streamController.add(SaveStream(SaveState.JOIN, illusts));
    FileInfo fileInfo = await DefaultCacheManager().getFileFromCache(url);
    Uint8List uint8list;
    if (fileInfo == null) {
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
            await _saveToGallery(uint8list, fileName);
            progressMaps.remove(url);
            _streamController.add(SaveStream(SaveState.SUCCESS, illusts));
          }
        });
      } catch (e) {
        progressMaps.remove(url);
      }
    } else {
      uint8list = await fileInfo.file.readAsBytes();
      _saveToGallery(uint8list, fileName);
    }
  }

  static const platform = const MethodChannel('com.perol.dev/save');
  Future<void> _saveToGallery(Uint8List uint8list, String fileName) async {
    if (Platform.isAndroid) {
      try {
        final fullPath = "${userSetting.path}/${fileName}";
        await File(fullPath).writeAsBytes(uint8list);
        await platform.invokeMethod('scan', {"path": fullPath});
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

  String _handleFileName(Illusts illust, int index, String memType) {
    final result = userSetting.format
        .replaceAll("{illust_id}", illust.id.toString())
        .replaceAll("{user_id}", illust.user.id.toString())
        .replaceAll("{part}", index.toString())
        .replaceAll("{user_name}", illust.user.name.toString())
        .replaceAll("{title}", illust.title);
    return "$result$memType"
        .replaceAll("/", "")
        .replaceAll("\\", "")
        .replaceAll(":", "")
        .replaceAll("*", "")
        .replaceAll("?", "")
        .replaceAll(">", "")
        .replaceAll("|", "")
        .replaceAll("<", "");
  }

  @action
  Future<void> saveImage(Illusts illusts, {int index}) async {
    final memType = illusts.imageUrls.large.contains("png") ? ".png" : ".jpg";
    if (illusts.pageCount == 1) {
      String fileName = _handleFileName(illusts, 0, memType);
      _saveInternal(illusts.metaSinglePage.originalImageUrl, illusts, fileName);
    } else {
      if (index != null) {
        String fileName = _handleFileName(illusts, index, memType);
        var url = illusts.metaPages[index].imageUrls.original;
        if (progressMaps.keys.contains(url)) {
          _streamController.add(SaveStream(SaveState.SUCCESS, illusts));
          return;
        }
        _saveInternal(url, illusts, fileName);
      } else {
        int index = 0;
        illusts.metaPages.forEach((f) {
          var url = f.imageUrls.original;
          String fileName = _handleFileName(illusts, index, memType);
          _saveInternal(url, illusts, fileName);
          index++;
        });
      }
    }
  }
}
