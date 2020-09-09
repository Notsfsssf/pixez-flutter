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
import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pixez/component/pixiv_image.dart';
import 'package:pixez/generated/l10n.dart';
import 'package:pixez/main.dart';
import 'package:pixez/models/illust.dart';
import 'package:pixez/models/tags.dart';
import 'package:pixez/models/task_persist.dart';
import 'package:pixez/store/save_store.dart';

class JobPage extends StatefulWidget {
  @override
  _JobPageState createState() => _JobPageState();
}

class _JobPageState extends State<JobPage> {
  List<TaskPersist> _list = [];
  TaskPersistProvider taskPersistProvider = TaskPersistProvider();
  Timer _timer;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(Duration(seconds: 1), (time) {
      if (mounted) setState(() {});
    });

    initMethod();
  }

  initMethod() async {
    await taskPersistProvider.open();
    final results = await taskPersistProvider.getAllAccount();
    if (results != null && results.isNotEmpty) {
      if (mounted) {
        setState(() {
          _list = results;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(I18n.of(context).task_progress),
        actions: [
          IconButton(
              icon: Icon(Icons.more_vert),
              onPressed: () {
                showModalBottomSheet(
                    context: context,
                    shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.vertical(top: Radius.circular(16.0))),
                    builder: (_) {
                      return SafeArea(
                        child: Column(
                          children: <Widget>[
                            ListTile(
                              title: Text(I18n.of(context).retry_failed_tasks),
                              onTap: () async {
                                final results =
                                    await taskPersistProvider.getAllAccount();
                                results.forEach((element) {
                                  if (element.status == 3) {
                                    _retryJob(element);
                                  }
                                });
                              },
                            ),
                            ListTile(
                              title:
                                  Text(I18n.of(context).clear_completed_tasks),
                              onTap: () async {
                                final results =
                                    await taskPersistProvider.getAllAccount();
                                results.forEach((element) {
                                  if (element.status == 2) {
                                    _deleteJob(element);
                                  }
                                });
                              },
                            )
                          ],
                          mainAxisSize: MainAxisSize.min,
                        ),
                      );
                    });
              }),
          IconButton(
            onPressed: () async {
              await taskPersistProvider.deleteAll();
              saveStore.jobMaps.clear();
              initMethod();
            },
            icon: Icon(Icons.delete),
          )
        ],
      ),
      body: _list.isNotEmpty
          ? ListView.builder(
              itemBuilder: (context, index) {
                var persist = _list[index];
                var job = saveStore.jobMaps[persist.url];
                if (job == null) {
                  return ListTile(
                    title: Text(persist.title),
                    subtitle: Text(persist.status.toString()),
                  );
                }
                return ListTile(
                  title: Text(persist.title),
                  subtitle: Text('${job.min}/${job.max}/${job.status}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                          icon: Icon(Icons.refresh),
                          onPressed: () async {
                            await _retryJob(persist);
                          }),
                      IconButton(
                          icon: Icon(Icons.delete),
                          onPressed: () async {
                            await _deleteJob(persist);
                            initMethod();
                          }),
                    ],
                  ),
                );
              },
              itemCount: _list.length,
            )
          : Container(
              child: Center(
                child: Text("[]"),
              ),
            ),
    );
  }

  Future _deleteJob(TaskPersist persist) async {
    await taskPersistProvider.remove(persist.id);
    saveStore.maps.remove(persist.url);
  }

  Future _retryJob(TaskPersist persist) async {
    await _deleteJob(persist);
    final taskPersist = persist;
    final jobMaps = saveStore.jobMaps;
    try {
      await taskPersistProvider.insert(taskPersist);
      var savePath = (await getTemporaryDirectory()).path +
          Platform.pathSeparator +
          persist.fileName;
      await saveStore.imageDio.download(persist.url, savePath,
          onReceiveProgress: (received, total) async {
        if (total != -1) {
          var job = jobMaps[persist.url];
          if (job != null) {
            job
              ..min = received
              ..status = 1
              ..max = total;
          } else {
            jobMaps[persist.url] = JobEntity()
              ..status = 1
              ..min = received
              ..max = total;
          }
          initMethod();
          if (received / total == 1) {
            await taskPersistProvider.update(taskPersist..status = 2);
            File file = File(savePath);
            final uint8list = await file.readAsBytes();
            await saveStore.saveToGallery(
                uint8list,
                Illusts(user: User(id: persist.userId, name: persist.userName)),
                persist.fileName);
            var job = jobMaps[persist.url];
            if (job != null) {
              job.status = 2;
            } else {
              jobMaps[persist.url] = JobEntity()
                ..status = 2
                ..min = 1
                ..max = 1;
            }
          }
        }
      },
          deleteOnError: true,
          options: Options(headers: {
            "referer": "https://app-api.pixiv.net/",
            "User-Agent": "PixivIOSApp/5.8.0"
          }));
    } catch (e) {
      await taskPersistProvider.update(taskPersist..status = 3);
      var job = jobMaps[persist.url];
      if (job != null) {
        job.status = 3;
      } else {
        jobMaps[persist.url] = JobEntity()
          ..status = 3
          ..min = 1
          ..max = 1;
      }
      print(e);
    }
  }
}
