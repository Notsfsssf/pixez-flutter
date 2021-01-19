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

import 'dart:collection';
import 'dart:io';

import 'dart:isolate';

import 'package:dio/adapter.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pixez/component/pixiv_image.dart';
import 'package:pixez/er/lprinter.dart';
import 'package:pixez/er/toaster.dart';
import 'package:pixez/generated/l10n.dart';
import 'package:pixez/main.dart';
import 'package:pixez/models/illust.dart';
import 'package:pixez/models/task_persist.dart';
import 'package:pixez/network/api_client.dart';
import 'package:pixez/store/save_store.dart';
import 'package:pixez/exts.dart';
import 'package:quiver/collection.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum IsoTaskState { INIT, APPEND, PROGRESS, ERROR, COMPLETE, NOTIFY }

class IsoContactBean {
  final IsoTaskState state;
  final dynamic data;

  IsoContactBean({this.state, this.data});
}

class IsoProgressBean {
  final int min, total;
  final String url;

  IsoProgressBean({this.min, this.total, this.url});
}

class TaskBean {
  final String url;
  final Illusts illusts;
  final String fileName;
  final String savePath;

  TaskBean({this.url, this.illusts, this.fileName, this.savePath});
}

class Fetcher {
  BuildContext context;
  Queue<IsoContactBean> queue = new Queue();
  ReceivePort receivePort = ReceivePort();
  SendPort sendPortToChild;
  Isolate isolate;
  TaskPersistProvider taskPersistProvider = TaskPersistProvider();
  LruMap<String, JobEntity> jobMaps = LruMap();

  Fetcher() {}

  start() async {
    if (receivePort.isBroadcast) return;
    taskPersistProvider.open();
    LPrinter.d("Fetcher start");
    receivePort.listen((message) {
      try {
        IsoContactBean isoContactBean = message;
        switch (isoContactBean.state) {
          case IsoTaskState.INIT:
            sendPortToChild = isoContactBean.data;
            if (_presetHost != ImageHost) {
              IsoContactBean bean = IsoContactBean(
                  state: IsoTaskState.NOTIFY,
                  data: TaskBean(
                      url: _presetHost,
                      illusts: null,
                      fileName: null,
                      savePath: null));
              sendPortToChild?.send(bean);
            }
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
            _complete(taskBean.url, taskBean.savePath, taskBean.fileName,
                taskBean.illusts);
            break;
          case IsoTaskState.ERROR:
            _errorD(isoContactBean.data as String);
            break;
          case IsoTaskState.NOTIFY:
            break;
          default:
            break;
        }
      } catch (e) {}
    });
    isolate = await Isolate.spawn(entryPoint, receivePort.sendPort,
        debugName: 'childIsolate');
  }

  save(String url, Illusts illusts, String fileName) async {
    LPrinter.d(sendPortToChild.toString() + url);
    IsoContactBean isoContactBean = IsoContactBean(
        state: IsoTaskState.APPEND,
        data: TaskBean(
            url: url,
            illusts: illusts,
            fileName: fileName,
            savePath: (await getTemporaryDirectory()).path));
    sendPortToChild?.send(isoContactBean);
  }

  String _presetHost = ImageHost;

  notify(String host) {
    _presetHost = host;
    IsoContactBean bean = IsoContactBean(
        state: IsoTaskState.NOTIFY,
        data: TaskBean(
            url: _presetHost, illusts: null, fileName: null, savePath: null));
    sendPortToChild?.send(bean);
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
    Toaster.downloadOk("${illusts.title} ${I18n.of(context).saved}");
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

class Seed {}

Dio isolateDio = Dio(BaseOptions(headers: {
  "referer": "https://app-api.pixiv.net/",
  "User-Agent": "PixivIOSApp/5.8.0",
  "Host": "i.pximg.net"
}));
// 新Isolate入口函数
entryPoint(SendPort sendPort) {
  LPrinter.d("entryPoint =======");
  String inHost = splashStore.host;
  if (!userSetting.disableBypassSni)
    (isolateDio.httpClientAdapter as DefaultHttpClientAdapter)
        .onHttpClientCreate = (client) {
      HttpClient httpClient = new HttpClient();
      httpClient.badCertificateCallback =
          (X509Certificate cert, String host, int port) {
        return true;
      };
      return httpClient;
    };
  ReceivePort receivePort = ReceivePort();
  sendPort.send(
      IsoContactBean(state: IsoTaskState.INIT, data: receivePort.sendPort));
  receivePort.listen((message) async {
    try {
      IsoContactBean isoContactBean = message;
      TaskBean taskBean = isoContactBean.data;
      switch (isoContactBean.state) {
        case IsoTaskState.NOTIFY:
          inHost = taskBean.url;
          break;
        case IsoTaskState.ERROR:
          break;
        case IsoTaskState.APPEND:
          try {
            LPrinter.d("append =======" + inHost);
            var savePath =
                taskBean.savePath + Platform.pathSeparator + taskBean.fileName;
            String trueUrl = userSetting.disableBypassSni
                ? taskBean.url
                : (Uri.parse(taskBean.url).replace(host: inHost)).toString();
            isolateDio.download(trueUrl, savePath,
                onReceiveProgress: (min, total) {
              sendPort.send(IsoContactBean(
                  state: IsoTaskState.PROGRESS,
                  data: IsoProgressBean(
                      min: min, total: total, url: taskBean.url)));
            }).then((value) {
              sendPort.send(
                  IsoContactBean(state: IsoTaskState.COMPLETE, data: taskBean));
            }).catchError((e) {
              try {
                splashStore.maybeFetch();
                sendPort.send(IsoContactBean(
                    state: IsoTaskState.ERROR, data: taskBean.url));
              } catch (e) {
                LPrinter.d(e);
              }
            });
          } catch (e) {
            LPrinter.d(e);
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
