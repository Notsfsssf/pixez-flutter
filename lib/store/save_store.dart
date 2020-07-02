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
import 'package:pixez/generated/l10n.dart';
import 'package:pixez/main.dart';
import 'package:pixez/models/illust.dart';
import 'package:pixez/page/progress/progress_page.dart';
import 'package:save_in_gallery/save_in_gallery.dart';

part 'save_store.g.dart';

enum SaveState { JOIN, SUCCESS, ALREADY, INQUEUE }

class ProgressNum {
  int min, max;
  Illusts illusts;

  ProgressNum(this.min, this.max, this.illusts);
}

class SaveStream {
  SaveState state;
  Illusts data;
  int index;

  SaveStream(this.state, this.data, {this.index});
}

void listenBehavior(BuildContext context, SaveStream stream) {
  switch (stream.state) {
    case SaveState.SUCCESS:
      BotToast.showCustomText(
          onlyOne: true,
          duration: Duration(seconds: 1),
          toastBuilder: (textCancel) => Align(
                alignment: Alignment(0, 0.8),
                child: Card(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Icon(
                        Icons.check_circle,
                        color: Colors.green,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8.0, vertical: 4.0),
                        child: Text(
                            "${stream.data.title} ${I18n.of(context).Saved}"),
                      )
                    ],
                  ),
                ),
              ));
      break;
    case SaveState.JOIN:
      BotToast.showCustomText(
          onlyOne: true,
          duration: Duration(seconds: 1),
          toastBuilder: (textCancel) => Align(
                alignment: Alignment(0, 0.8),
                child: Card(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      IconButton(
                          icon: Icon(Icons.arrow_downward),
                          onPressed: () {
                            Navigator.of(context, rootNavigator: true)
                                .push(MaterialPageRoute(builder: (context) {
                              return ProgressPage();
                            }));
                          }),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Text("${I18n.of(context).Append_to_query}"),
                      )
                    ],
                  ),
                ),
              ));
      break;
    case SaveState.INQUEUE:
      BotToast.showCustomText(
          onlyOne: true,
          duration: Duration(seconds: 1),
          toastBuilder: (textCancel) => Align(
                alignment: Alignment(0, 0.8),
                child: Card(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      IconButton(icon: Icon(Icons.info), onPressed: () {}),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Text("${I18n.of(context).Already_in_query}"),
                      )
                    ],
                  ),
                ),
              ));
      break;
    case SaveState.ALREADY:
      BotToast.showCustomText(
          onlyOne: true,
          duration: Duration(seconds: 1),
          toastBuilder: (textCancel) => Align(
                alignment: Alignment(0, 0.8),
                child: Card(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      IconButton(
                          icon: Icon(Icons.refresh),
                          onPressed: () {
                            saveStore.redo(stream.data, stream.index);
                          }),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Text("${I18n.of(context).Already_Saved}"),
                      )
                    ],
                  ),
                ),
              ));
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
    if (Platform.isAndroid) {
      try {
        final fullPath = "${userSetting.path}/${fileName}";
        if (File(fullPath).existsSync()) {
          _streamController.add(SaveStream(SaveState.ALREADY, illusts));
          return;
        }
      } catch (e) {}
    }
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
        });
        File file = File(fullPath);
        uint8list = await file.readAsBytes();
        await _saveToGallery(uint8list, illusts, fileName);
        progressMaps.remove(url);
        _streamController.add(SaveStream(SaveState.SUCCESS, illusts));
      } catch (e) {
        debugPrint("${e}");
        progressMaps.remove(url);
      }
    } else {
      uint8list = await fileInfo.file.readAsBytes();
      _saveToGallery(uint8list, illusts, fileName);
    }
  }

  static const platform = const MethodChannel('com.perol.dev/save');

  Future<void> _saveToGallery(
      Uint8List uint8list, Illusts illusts, String fileName) async {
    if (Platform.isAndroid) {
      try {
        String path = userSetting.path;
        if (userSetting.singleFolder) {
          path = "${path}/${illusts.user.name}_${illusts.user.id}";
          Directory(userSetting.path).listSync().forEach((element) {
            if (element is Directory) {
              bool ok = element.path
                  .split('/')
                  .last
                  .contains(illusts.user.id.toString());
              if (ok) {
                path = element.path;
              }
            }
          });
        }
        final fullPath = "${path}/${fileName}";
        final file = File(fullPath);
        if (!file.existsSync()) {
          file.createSync(recursive: true);
        }
        await file.writeAsBytes(uint8list);
        await platform.invokeMethod('scan', {"path": fullPath});
      } catch (e) {
        debugPrint("${e}");
      }
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

  redo(Illusts illusts, int index) async {
    saveImage(illusts, index: index, redo: true);
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

  toFullPath(String name) => '${userSetting.path}/${name}';
  DateTime isIllustPartExist(Illusts illusts, {int index}) {
    if (Platform.isIOS) return null;
    String memType;
    if (illusts.pageCount == 1) {
      String url = illusts.metaSinglePage.originalImageUrl;
      memType = url.contains('.png') ? '.png' : '.jpg';
      String fileName = toFullPath(_handleFileName(illusts, 0, memType));
      return File(fileName).existsSync()
          ? File(fileName).lastModifiedSync()
          : null;
    } else {
      if (index != null) {
        var url = illusts.metaPages[index].imageUrls.original;
        memType = url.contains('.png') ? '.png' : '.jpg';
        String fileName = _handleFileName(illusts, index, memType);
        final fullPath = "${userSetting.path}/${fileName}";
        var file = File(fullPath);
        return file.existsSync() ? file.lastModifiedSync() : null;
      }
      return null;
    }
  }

  @action
  Future<void> saveImage(Illusts illusts,
      {int index, bool redo = false}) async {
    String memType;
    if (illusts.pageCount == 1) {
      String url = illusts.metaSinglePage.originalImageUrl;
      memType = url.contains('.png') ? '.png' : '.jpg';
      String fileName = _handleFileName(illusts, 0, memType);
      if (redo) {
        final fullPath = "${userSetting.path}/${fileName}";
        var file = File(fullPath);
        if (file.existsSync()) file.deleteSync();
      }
      _saveInternal(url, illusts, fileName);
    } else {
      if (index != null) {
        var url = illusts.metaPages[index].imageUrls.original;
        if (progressMaps.keys.contains(url)) {
          _streamController.add(SaveStream(SaveState.INQUEUE, illusts));
          return;
        }
        memType = url.contains('.png') ? '.png' : '.jpg';
        String fileName = _handleFileName(illusts, index, memType);
        if (redo) {
          final fullPath = "${userSetting.path}/${fileName}";
          var file = File(fullPath);
          if (file.existsSync()) file.deleteSync();
        }
        _saveInternal(url, illusts, fileName);
      } else {
        int index = 0;
        illusts.metaPages.forEach((f) {
          String url = f.imageUrls.original;
          memType = url.contains('.png') ? '.png' : '.jpg';
          String fileName = _handleFileName(illusts, index, memType);
          if (redo) {
            final fullPath = "${userSetting.path}/${fileName}";
            var file = File(fullPath);
            if (file.existsSync()) file.deleteSync();
          }
          _saveInternal(url, illusts, fileName);
          index++;
        });
      }
    }
  }
}
