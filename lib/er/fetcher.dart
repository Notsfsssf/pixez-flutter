/*
 * Copyright (C) 2020. by perol_notsf, All rights reserved
 *
 * This program is free software: you can redistribute it and/or modify it under
 * the terms of the GNU General Public License as published by the Free Software
 * Foundation, either version 3 of the License, or (at your option) any later version.
 *
 *  This program is distributed in the hope that it will be useful, but WITHOUT ANY
 *  WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
 *  FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License along with
 *  this program. If not, see <http://www.gnu.org/licenses/>.
 */

import 'dart:io';

import 'dart:isolate';

import 'package:dio/dio.dart';
import 'package:dio_compatibility_layer/dio_compatibility_layer.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_cache_manager_dio/flutter_cache_manager_dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pixez/component/pixiv_image.dart';
import 'package:pixez/er/hoster.dart';
import 'package:pixez/er/lprinter.dart';
import 'package:pixez/er/toaster.dart';
import 'package:pixez/i18n.dart';
import 'package:pixez/main.dart';
import 'package:pixez/models/illust.dart';
import 'package:pixez/models/task_persist.dart';
import 'package:pixez/store/save_store.dart';
import 'package:quiver/collection.dart';
import 'package:rhttp/rhttp.dart' as r;

enum IsoTaskState { INIT, APPEND, PROGRESS, ERROR, COMPLETE }

class IsoContactBean {
  final IsoTaskState state;
  final dynamic data;

  IsoContactBean({required this.state, required this.data});
}

class IsoProgressBean {
  final int min, total;
  final String url;

  IsoProgressBean({required this.min, required this.total, required this.url});
}

class TaskBean {
  String? url;
  Illusts? illusts;
  String? fileName;
  String? savePath;
  String? source;
  String? host;
  bool? byPass;

  TaskBean({
    required this.url,
    required this.illusts,
    required this.fileName,
    required this.savePath,
    this.byPass,
    this.host,
    this.source,
  });
}

class Fetcher {
  BuildContext? context;
  List<TaskBean> queue = [];
  ReceivePort receivePort = ReceivePort();
  SendPort? sendPortToChild;
  Isolate? isolate;
  TaskPersistProvider taskPersistProvider = TaskPersistProvider();
  LruMap<String, JobEntity> jobMaps = LruMap();

  Fetcher() {}

  start(String pictureSource) async {
    if (receivePort.isBroadcast) return;
    await taskPersistProvider.open();
    await taskPersistProvider.getAllAccount();
    LPrinter.d("Fetcher start");
    receivePort.listen((message) {
      try {
        IsoContactBean isoContactBean = message;
        switch (isoContactBean.state) {
          case IsoTaskState.INIT:
            sendPortToChild = isoContactBean.data;
            break;
          case IsoTaskState.PROGRESS:
            IsoProgressBean isoProgressBean = isoContactBean.data;
            var job = fetcher.jobMaps[isoProgressBean.url];
            if (job != null) {
              job
                ..min = isoProgressBean.min
                ..status = 1
                ..max = isoProgressBean.total;
            } else {
              fetcher.jobMaps[isoProgressBean.url] = JobEntity()
                ..status = 1
                ..min = isoProgressBean.min
                ..max = isoProgressBean.total;
            }
            break;
          case IsoTaskState.COMPLETE:
            TaskBean taskBean = isoContactBean.data;
            urlPool.remove(taskBean.url);
            if (queue.isNotEmpty) {
              queue.removeWhere((element) => element.url == taskBean.url);
              LPrinter.d("c ${queue.length}");
            }
            fetcher.jobMaps.removeWhere((key, value) => key == taskBean.url);
            nextJob();
            _complete(
              taskBean.url!,
              taskBean.savePath!,
              taskBean.fileName!,
              taskBean.illusts!,
            );
            break;
          case IsoTaskState.ERROR:
            TaskBean taskBean = isoContactBean.data;
            urlPool.remove(taskBean.url);
            if (queue.isNotEmpty) {
              queue.removeWhere((element) => element.url == taskBean.url);
              LPrinter.d("c ${queue.length}");
            }
            fetcher.jobMaps.removeWhere((key, value) => key == taskBean.url);
            nextJob();
            _errorD(taskBean.url!);
            break;
          default:
            break;
        }
      } catch (e) {}
    });
    isolate = await Isolate.spawn(
      entryPoint,
      SendMessage(
        receivePort.sendPort,
        pictureSource,
        userSetting.disableBypassSni,
        RootIsolateToken.instance!,
      ),
      debugName: 'childIsolate',
    );
  }

  save(String url, Illusts illusts, String fileName) async {
    LPrinter.d(sendPortToChild.toString() + url);
    var taskBean = TaskBean(
      url: url,
      illusts: illusts,
      fileName: fileName,
      byPass: userSetting.disableBypassSni,
      source: userSetting.pictureSource,
      host: splashStore.host,
      savePath: (await getTemporaryDirectory()).path,
    );
    queue.add(taskBean);
    nextJob();
  }

  List<String> urlPool = [];

  nextJob() {
    if (queue.isNotEmpty && urlPool.length < userSetting.maxRunningTask) {
      TaskBean? first = null;
      for (var i in queue) {
        if (!urlPool.contains(i.url)) {
          first = i;
          break;
        }
      }
      if (first == null) return;
      first.byPass = userSetting.disableBypassSni;
      first.source = userSetting.pictureSource;
      first.host = splashStore.host;
      IsoContactBean isoContactBean = IsoContactBean(
        state: IsoTaskState.APPEND,
        data: first,
      );
      sendPortToChild?.send(isoContactBean);
      if (first.url != null) urlPool.add(first.url!);
    }
  }

  void stop() {
    isolate?.kill(priority: Isolate.immediate);
  }

  Future<void> _complete(
    String url,
    String savePath,
    String fileName,
    Illusts illusts,
  ) async {
    var taskPersist = await taskPersistProvider.getAccount(url);
    if (taskPersist == null) return;
    await taskPersistProvider.update(taskPersist..status = 2);
    File file = File(savePath + Platform.pathSeparator + fileName);
    final uint8list = await file.readAsBytes();
    await saveStore.saveToGallery(uint8list, illusts, fileName);
    Toaster.downloadOk("${illusts.title} ${I18n.of(context!).saved}");
    var job = jobMaps[url];
    if (job != null) {
      job.status = 2;
    } else {
      jobMaps[url] = JobEntity()
        ..status = 2
        ..min = 1
        ..max = 1;
    }
  }

  Future<void> _errorD(String url) async {
    var taskPersist = await taskPersistProvider.getAccount(url);
    if (taskPersist == null) return;
    await taskPersistProvider.update(taskPersist..status = 3);
    var job = jobMaps[url];
    if (job != null) {
      job.status = 3;
    } else {
      jobMaps[url] = JobEntity()
        ..status = 3
        ..min = 1
        ..max = 1;
    }
  }
}

class SendMessage {
  final SendPort sendPort;
  final String pictureSource;
  final bool disableBypassSni;
  final RootIsolateToken rootIsolateToken;

  SendMessage(
    this.sendPort,
    this.pictureSource,
    this.disableBypassSni,
    this.rootIsolateToken,
  );
}

entryPoint(SendMessage message) async {
  String pictureSource = message.pictureSource;
  RootIsolateToken rootIsolateToken = message.rootIsolateToken;
  SendPort sendPort = message.sendPort;
  LPrinter.d("entryPoint ====== $pictureSource");
  String inSource = pictureSource;
  BackgroundIsolateBinaryMessenger.ensureInitialized(rootIsolateToken);
  await r.Rhttp.init();
  await Hoster.initMap();
  Hoster.dnsQueryFetcher();
  final dio = Dio();
  final client = await r.RhttpCompatibleClient.createSync(
    settings: (message.disableBypassSni || pictureSource != ImageHost)
        ? null
        : r.ClientSettings(
            tlsSettings: r.TlsSettings(verifyCertificates: false, sni: false),
            dnsSettings: r.DnsSettings.dynamic(
              resolver: (host) async {
                if (host == 'i.pximg.net') {
                  return [Hoster.iPximgNet()];
                }
                if (host == 's.pximg.net') {
                  return [Hoster.sPximgNet()];
                }
                return await InternetAddress.lookup(
                  host,
                ).then((value) => value.map((e) => e.address).toList());
              },
            ),
          ),
  );
  dio.httpClientAdapter = ConversionLayerAdapter(client);
  DioCacheManager.initialize(dio);
  ReceivePort receivePort = ReceivePort();
  sendPort.send(
    IsoContactBean(state: IsoTaskState.INIT, data: receivePort.sendPort),
  );

  receivePort.listen((message) async {
    try {
      IsoContactBean isoContactBean = message;
      TaskBean taskBean = isoContactBean.data;
      switch (isoContactBean.state) {
        case IsoTaskState.ERROR:
          break;
        case IsoTaskState.APPEND:
          try {
            inSource = taskBean.source!;
            print("========taskBean.savePath: ${taskBean.savePath}");
            var savePath =
                taskBean.savePath! +
                Platform.pathSeparator +
                taskBean.fileName!;
            String trueUrl = taskBean.url!;
            String originHost = Uri.parse(taskBean.url!).host;
            if (taskBean.byPass == true) {
            } else {
              if (originHost == ImageHost) {
                trueUrl = 'https://${inSource}${Uri.parse(taskBean.url!).path}';
              } else {
                trueUrl = taskBean.url!;
              }
            }
            await for (final response in pixivCacheManager!.getFileStream(
              trueUrl,
              headers: {
                "referer": "https://app-api.pixiv.net/",
                "User-Agent": "PixivIOSApp/5.8.0",
              },
              withProgress: true,
            )) {
              if (response is DownloadProgress) {
                sendPort.send(
                  IsoContactBean(
                    state: IsoTaskState.PROGRESS,
                    data: IsoProgressBean(
                      min: response.downloaded,
                      total: response.totalSize ?? 1,
                      url: taskBean.url!,
                    ),
                  ),
                );
              } else if (response is FileInfo) {
                File file = File(savePath);
                if (!file.parent.existsSync()) {
                  file.parent.createSync(recursive: true);
                }
                await response.file.copy(file.path);
                sendPort.send(
                  IsoContactBean(state: IsoTaskState.COMPLETE, data: taskBean),
                );
              }
            }
          } catch (e) {
            LPrinter.d("fetcher=======");
            LPrinter.d(e);
            sendPort.send(
              IsoContactBean(state: IsoTaskState.ERROR, data: taskBean),
            );
          }
          break;
        default:
          break;
      }
    } catch (e) {
      LPrinter.d(e);
    }
  });
}
