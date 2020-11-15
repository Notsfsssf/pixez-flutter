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

import 'package:bot_toast/bot_toast.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pixez/component/pixiv_image.dart';
import 'package:pixez/component/sort_group.dart';
import 'package:pixez/generated/l10n.dart';
import 'package:pixez/main.dart';
import 'package:pixez/models/illust.dart';
import 'package:pixez/models/task_persist.dart';
import 'package:pixez/page/picture/illust_lighting_page.dart';
import 'package:pixez/store/save_store.dart';
import 'package:pixez/exts.dart';

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
    if (results != null) {
      if (mounted) {
        setState(() {
          _list = results;
        });
      }
    }
  }

  String toMessage(int i) {
    switch (i) {
      case 0:
        return "seed";
        break;
      case 1:
        return I18n.of(context).running;
        break;
      case 2:
        return I18n.of(context).complete;
      case 3:
        return I18n.of(context).failed;
      default:
        return "seed";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: Text(I18n.of(context).task_progress),
        actions: [
          IconButton(
              icon: Icon(Icons.more_vert),
              onPressed: () async {
                await showModalBottomSheet(
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
                                Navigator.of(context).pop();
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
                                Navigator.of(context).pop();
                              },
                            )
                          ],
                          mainAxisSize: MainAxisSize.min,
                        ),
                      );
                    });
                initMethod();
              }),
        ],
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [_buildTopChip(), Expanded(child: _body())],
        ),
      ),
    );
  }

  int currentIndex = 0;

  Widget _buildTopChip() {
    return Padding(
      padding: const EdgeInsets.only(left: 16.0),
      child: SortGroup(
        children: [
          I18n.of(context).all,
          I18n.of(context).running,
          I18n.of(context).complete,
          I18n.of(context).failed,
        ],
        onChange: (index) {
          setState(() {
            this.currentIndex = index;
          });
        },
      ),
    );
  }

  Widget _body() {
    return _list.isNotEmpty
        ? ListView.builder(
            itemBuilder: (context, index) {
              if (index == _list.length) {
                return Container(
                  height: 8.0,
                );
              }
              var persist = _list[index];
              var job = saveStore.jobMaps[persist.url];

              if (currentIndex == 0) {
                if (job == null) {
                  return Container(
                    child: ListTile(
                      title: Text(persist.title),
                      subtitle: Text(toMessage(persist.status)),
                      onTap: () {
                        Navigator.of(context)
                            .push(MaterialPageRoute(builder: (context) {
                          return IllustLightingPage(
                            id: persist.illustId,
                          );
                        }));
                      },
                      trailing: Row(
                        children: [
                          if (persist.status == 3 ||
                              persist.status == 0 ||
                              persist.status == 2)
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
                        mainAxisAlignment: MainAxisAlignment.end,
                        mainAxisSize: MainAxisSize.min,
                      ),
                    ),
                  );
                }
                return Container(
                  child: Column(
                    children: [
                      ListTile(
                        title: Text(
                          persist.title,
                          maxLines: 1,
                        ),
                        onTap: () {
                          Navigator.of(context)
                              .push(MaterialPageRoute(builder: (context) {
                            return IllustLightingPage(
                              id: persist.illustId,
                            );
                          }));
                        },
                        subtitle: Text('${toMessage(job.status)}'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (persist.status == 3 ||
                                persist.status == 0 ||
                                persist.status == 2)
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
                      ),
                      if (job.max / job.min != 1)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: LinearProgressIndicator(
                            value: job.min / job.max,
                            backgroundColor: Colors.grey,
                          ),
                        ),
                    ],
                  ),
                );
              } else {
                return Builder(builder: (context) {
                  if (job == null) {
                    return Visibility(
                      visible: persist.status == currentIndex,
                      child: ListTile(
                        title: Text(persist.title),
                        subtitle: Text(toMessage(persist.status)),
                        onTap: () {
                          Navigator.of(context)
                              .push(MaterialPageRoute(builder: (context) {
                            return IllustLightingPage(
                              id: persist.illustId,
                            );
                          }));
                        },
                        trailing: Row(
                          children: [
                            if (persist.status == 3 ||
                                persist.status == 0 ||
                                persist.status == 2)
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
                          mainAxisAlignment: MainAxisAlignment.end,
                          mainAxisSize: MainAxisSize.min,
                        ),
                      ),
                    );
                  }
                  return Visibility(
                    visible: currentIndex == job.status,
                    child: Column(
                      children: [
                        ListTile(
                          title: Text(
                            persist.title,
                            maxLines: 1,
                          ),
                          onTap: () {
                            Navigator.of(context)
                                .push(MaterialPageRoute(builder: (context) {
                              return IllustLightingPage(
                                id: persist.illustId,
                              );
                            }));
                          },
                          subtitle: Text('${toMessage(job.status)}'),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (persist.status == 3 ||
                                  persist.status == 0 ||
                                  persist.status == 2)
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
                        ),
                        if (job.min / job.max != 1)
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 16.0),
                            child: LinearProgressIndicator(
                              value: job.min / job.max,
                              backgroundColor: Colors.grey,
                            ),
                          ),
                      ],
                    ),
                  );
                });
              }
            },
            itemCount: _list.length + 1,
          )
        : Container(
            child: Center(
              child: Text(
                "[  ]",
                style: Theme.of(context)
                    .textTheme
                    .headline4
                    .copyWith(fontStyle: FontStyle.italic),
              ),
            ),
          );
  }

  Future _deleteJob(TaskPersist persist) async {
    await taskPersistProvider.remove(persist.id);
    saveStore.jobMaps.remove(persist.url);
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
      await saveStore.imageDio.download(persist.url.toTrueUrl(), savePath,
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
                                  horizontal: 8.0, vertical: 8.0),
                              child: Text(
                                  "${persist.title} ${I18n.of(context).saved}"),
                            )
                          ],
                        ),
                      ),
                    ));
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
            "User-Agent": "PixivIOSApp/5.8.0",
            "Host": ImageHost
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
