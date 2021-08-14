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

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pixez/component/sort_group.dart';
import 'package:pixez/er/leader.dart';
import 'package:pixez/i18n.dart';
import 'package:pixez/main.dart';
import 'package:pixez/models/task_persist.dart';
import 'package:pixez/page/picture/illust_lighting_page.dart';
import 'package:pixez/store/save_store.dart';

class JobPage extends StatefulWidget {
  @override
  _JobPageState createState() => _JobPageState();
}

class _JobPageState extends State<JobPage> {
  List<TaskPersist> _list = [];
  TaskPersistProvider taskPersistProvider = TaskPersistProvider();
  Timer? _timer;
  String? cachePath;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    initMethod();
  }

  initMethod() async {
    await taskPersistProvider.open();
    await taskPersistProvider.getAllAccount();
    if (mounted) {
      setState(() {
        _list = fetcher.localQueue;
      });
    }
    _timer = Timer.periodic(Duration(seconds: 1), (time) {
      fetchLocal();
    });
    cachePath = (await getTemporaryDirectory()).path;
  }

  fetchLocal() async {
    List<TaskPersist> results = fetcher.localQueue;
    if (mounted) {
      setState(() {
        _list = results;
      });
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
          buildIconButton(context),
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

  IconButton buildIconButton(BuildContext context) {
    return IconButton(
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
                        title: Text(I18n.of(context).retry_seed_task),
                        onTap: () async {
                          final results =
                              await taskPersistProvider.getAllAccount();
                          results.forEach((element) {
                            if (element.status == 0) {
                              _retryJob(element);
                            }
                          });
                          Navigator.of(context).pop();
                        },
                      ),
                      ListTile(
                        title: Text(I18n.of(context).clear_completed_tasks),
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
        });
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
    if (_list.isEmpty)
      return Container(
        child: Center(
          child: Text("[ ]"),
        ),
      );
    return ListView.builder(
      itemBuilder: (context, index) {
        TaskPersist taskPersist = _list[index];
        JobEntity? jobEntity = fetcher.jobMaps[taskPersist.url];
        if (currentIndex != 0) {
          if ((jobEntity?.status ?? taskPersist.status) != currentIndex)
            return Visibility(
              child: Container(
                height: 0,
              ),
              visible: false,
            );
        }
        return Card(
          margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: () {
              Leader.push(
                  context, IllustLightingPage(id: taskPersist.illustId));
            },
            child: Container(
              child: Row(
                children: [
                  (taskPersist.status == 2 && cachePath != null)
                      ? Container(
                          height: 100,
                          width: 100,
                          child: Image.file(
                            File("${cachePath!}/${taskPersist.fileName}"),
                            fit: BoxFit.fitWidth,
                          ),
                        )
                      : (jobEntity != null && jobEntity.status != 2)
                          ? Container(
                              height: 100,
                              width: 100,
                              child: Center(
                                child: CircularProgressIndicator(
                                  value: ((jobEntity.min ?? 0.0) /
                                          ((jobEntity.max ?? 0.0)))
                                      .toDouble(),
                                  backgroundColor: Colors.grey[200],
                                ),
                              ),
                            )
                          : Container(
                              height: 0,
                            ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Container(
                                width: 200,
                                child: Text(
                                  taskPersist.title,
                                  maxLines: 1,
                                  overflow: TextOverflow.clip,
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(toMessage(
                                  jobEntity?.status ?? taskPersist.status)),
                            )
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Text(
                            taskPersist.userName,
                            style: Theme.of(context)
                                .textTheme
                                .bodyText2!
                                .copyWith(
                                    color: Theme.of(context).colorScheme.primary,
                                    fontSize: 12),
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            Text(""),
                            Row(
                              children: [
                                IconButton(
                                    onPressed: () {
                                      _retryJob(taskPersist);
                                    },
                                    icon: Icon(Icons.refresh)),
                                IconButton(
                                    onPressed: () {
                                      _deleteJob(taskPersist);
                                    },
                                    icon: Icon(Icons.delete)),
                              ],
                            )
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
      itemCount: _list.length,
    );
  }

  Future _deleteJob(TaskPersist persist) async {
    await taskPersistProvider.remove(persist.id!);
    fetcher.jobMaps.remove(persist.url);
  }

  Future _retryJob(TaskPersist persist) async {
    if (persist.status == 2) return;
    await _deleteJob(persist);
    final taskPersist = persist;
    await taskPersistProvider.insert(taskPersist);
    fetcher.save(persist.url, taskPersist.toIllusts(), persist.fileName);
  }
}
