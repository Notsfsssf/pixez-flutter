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
import 'dart:ffi';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mobx/mobx.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pixez/component/pixiv_image.dart';
import 'package:pixez/document_plugin.dart';
import 'package:pixez/er/toaster.dart';
import 'package:pixez/exts.dart';
import 'package:pixez/i18n.dart';
import 'package:pixez/main.dart';
import 'package:pixez/models/illust.dart';
import 'package:pixez/models/task_persist.dart';
import 'package:pixez/page/task/job_page.dart';

part 'save_store.g.dart';

enum SaveState { JOIN, SUCCESS, ALREADY, INQUEUE }

class SaveData {
  Illusts illusts;
  String fileName;

  SaveData({required this.illusts, required this.fileName});
}

class SaveStream {
  SaveState state;
  Illusts data;
  int? index;

  SaveStream(this.state, this.data, {this.index});
}

class JobEntity {
  int? max;
  int? min;
  int? status;

// JobEntity({required this.max, required this.min, required this.status});
}

class SaveStore = _SaveStoreBase with _$SaveStore;

abstract class _SaveStoreBase with Store {
  _SaveStoreBase() {
    streamController = StreamController();
    saveStream = ObservableStream(streamController.stream.asBroadcastStream());
  }

  void dispose() async {
    await streamController.close();
  }

  void listenBehavior(SaveStream stream) {
    switch (stream.state) {
      case SaveState.SUCCESS:
        Toaster.downloadOk(
            "${stream.data.title} (p${stream.index ?? 0}) ${I18n.of(ctx!).saved}");
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
                              Navigator.of(ctx!, rootNavigator: true)
                                  .push(MaterialPageRoute(builder: (context) {
                                return JobPage();
                              }));
                            }),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8.0, vertical: 8.0),
                          child: Text("${I18n.of(ctx!).append_to_query}"),
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
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8.0, vertical: 8.0),
                          child: Text("${I18n.of(ctx!).already_in_query}"),
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
                              saveStore.redo(stream.data, stream.index ?? 0);
                            }),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8.0, vertical: 8.0),
                          child: Text(
                              "${stream.data.title} (p${stream.index ?? 0}) ${I18n.of(ctx!).already_saved}"),
                        )
                      ],
                    ),
                  ),
                ));
        break;
      default:
    }
  }

  BuildContext? ctx;

  late StreamController<SaveStream> streamController;
  late ObservableStream<SaveStream> saveStream;

  Future<String> findLocalPath() async {
    final directory = Platform.isAndroid
        ? (await getTemporaryDirectory()).path
        : (await getApplicationDocumentsDirectory()).path + '/pixez';
    return directory;
  }

  _joinOnDart(String url, Illusts illusts, String fileName) async {
    final result = await fetcher.taskPersistProvider.getAccount(url);
    if (result != null) {
      streamController.add(SaveStream(SaveState.INQUEUE, illusts));
      return;
    }
    var taskPersist = TaskPersist(
        userId: illusts.user.id,
        userName: illusts.user.name,
        illustId: illusts.id,
        title: illusts.title,
        sanityLevel: illusts.sanityLevel,
        fileName: fileName,
        status: 0,
        url: url);
    try {
      await fetcher.taskPersistProvider.insert(taskPersist);
      fetcher.save(url, illusts, fileName);
    } catch (e) {}
  }

  _joinQueue(String url, Illusts illusts, String fileName) async {
    _joinOnDart(url, illusts, fileName);
    return;
  }

  _saveInternal(String url, Illusts illusts, String fileName, int index,
      {bool redo = false}) async {
    if (Platform.isAndroid) {
      try {
        String targetFileName = fileName;
        if (userSetting.singleFolder) {
          targetFileName =
              "${illusts.user.name.toLegal()}_${illusts.user.id}/$fileName";
        }
        final isExist = await DocumentPlugin.exist(targetFileName);
        if (isExist! && !redo) {
          streamController
              .add(SaveStream(SaveState.ALREADY, illusts, index: index));
          return;
        }
      } catch (e) {}
    }
    streamController.add(SaveStream(SaveState.JOIN, illusts, index: index));
    File? file = (await pixivCacheManager.getFileFromCache(url))?.file;
    if (file == null) {
      _joinQueue(url, illusts, fileName);
    } else {
      saveToGallery(file.readAsBytesSync(), illusts, fileName);
      streamController
          .add(SaveStream(SaveState.SUCCESS, illusts, index: index));
    }
  }

  Future<void> saveToGalleryWithUser(Uint8List uint8list, String userName,
      int userId, int sanityLevel, String fileName,
      {bool antiHashCheck = false}) async {
    if (Platform.isAndroid || Platform.isIOS) {
      try {
        String overFileName = fileName;
        if (userSetting.singleFolder) {
          String name = userName.toLegal();
          String id = userId.toString();
          fileName = "${name}_$id/$overFileName";
        }
        if (userSetting.overSanityLevelFolder && sanityLevel > 2) {
          fileName = "sanity/$overFileName";
        }

        if (userSetting.saveEffectEnable && antiHashCheck) {
          uint8ListProcess(uint8list);
        }

        if (userSetting.isClearOldFormatFile)
          DocumentPlugin.save(uint8list, fileName,
              clearOld: userSetting.isClearOldFormatFile);
        else
          DocumentPlugin.save(uint8list, fileName);
      } catch (e) {
        print(e);
      }
      return;
    } else {
      //TODO OTHER PLATFORM
    }
  }

  void uint8ListProcess(Uint8List uint8list) {
    var random = Random(DateTime.now().millisecondsSinceEpoch);
    var randomList =
        List<int>.generate(8, (x) => random.nextInt(9223372036854775807));
    uint8list.addAll(randomList);
  }

  Future<void> saveToGallery(
      Uint8List uint8list, Illusts illusts, String fileName) async {
    // Attach random bytes to image file while:
    // for a specific image manually;
    // for all R-18 images when setting "anti_hash_check" is enable.
    bool antiHashCheck = userSetting.saveEffect == 0;
    saveToGalleryWithUser(uint8list, illusts.user.name, illusts.user.id,
        illusts.sanityLevel, fileName,
        antiHashCheck: ((illusts.xRestrict > 0) & antiHashCheck));
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
    final result = userSetting.format!
        .replaceAll("{illust_id}", illust.id.toString())
        .replaceAll("{user_id}", illust.user.id.toString())
        .replaceAll("{part}", index.toString())
        .replaceAll("{user_name}", illust.user.name.toString())
        .replaceAll("{title}", illust.title);
    return "$result$memType".toLegal();
  }

  @action
  Future<void> saveImage(Illusts illusts,
      {int? index, bool redo = false}) async {
    String memType;
    if (illusts.pageCount == 1) {
      String url = illusts.metaSinglePage!.originalImageUrl!;
      memType = url.contains('.png') ? '.png' : '.jpg';
      String fileName = _handleFileName(illusts, 0, memType);
      // If enable antiHashCheck, force re-save image.
      _saveInternal(url, illusts, fileName, 0,
          redo: redo | (userSetting.saveEffectEnable));
    } else {
      if (index != null) {
        var url = illusts.metaPages[index].imageUrls!.original;
        memType = url.contains('.png') ? '.png' : '.jpg';
        String fileName = _handleFileName(illusts, index, memType);
        _saveInternal(url, illusts, fileName, index,
            redo: redo | (userSetting.saveEffectEnable));
      } else {
        int index = 0;
        illusts.metaPages.forEach((f) {
          String url = f.imageUrls!.original;
          memType = url.contains('.png') ? '.png' : '.jpg';
          String fileName = _handleFileName(illusts, index, memType);
          _saveInternal(url, illusts, fileName, index,
              redo: redo | (userSetting.saveEffectEnable));
          index++;
        });
      }
    }
  }
}
