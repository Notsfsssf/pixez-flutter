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
import 'dart:convert';

import 'package:material_ui/material_ui.dart';
import 'package:pixez/component/pixiv_image.dart';
import 'package:pixez/component/sort_group.dart';
import 'package:pixez/er/leader.dart';
import 'package:pixez/i18n.dart';
import 'package:pixez/main.dart';
import 'package:pixez/models/novel_task_persist.dart';
import 'package:pixez/models/task_persist.dart';
import 'package:pixez/page/novel/series/novel_series_page.dart';
import 'package:pixez/page/picture/illust_lighting_page.dart';
import 'package:pixez/store/save_store.dart';

class JobPage extends StatefulWidget {
  @override
  _JobPageState createState() => _JobPageState();
}

class _JobPageState extends State<JobPage> with SingleTickerProviderStateMixin {
  List<TaskPersist> _list = [];
  List<NovelTaskPersist> _novelList = [];
  TaskPersistProvider taskPersistProvider = TaskPersistProvider();
  NovelTaskPersistProvider novelTaskPersistProvider = NovelTaskPersistProvider();
  Timer? _timer;
  late AnimationController rotationController;
  ScrollController _scrollController = ScrollController();
  bool _itemSimple = true;
  int STATUS_ALL = 10;

  @override
  void initState() {
    rotationController = AnimationController(
        duration: const Duration(milliseconds: 500), vsync: this);
    _scrollController.addListener(() async {
      if (_scrollController.hasClients) {
        if (_scrollController.offset >=
            _scrollController.position.maxScrollExtent) {
          await _next();
        }
      }
    });
    super.initState();
    initMethod();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    rotationController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  initMethod() async {
    await taskPersistProvider.open();
    await novelTaskPersistProvider.open();
    _refresh();
    _timer = Timer.periodic(Duration(seconds: 1), (time) {
      _fetchLocal();
    });
  }

  _fetchLocal() async {
    if (mounted) {
      setState(() {
        if (currentIndex == 1) {
          _list = fetcher.queue
              .where((element) => fetcher.urlPool.contains(element.url))
              .map((e) => TaskPersist(
                  userName: e.illusts?.user.name ?? "",
                  title: e.illusts?.title ?? "",
                  url: e.url ?? "",
                  userId: e.illusts?.user.id ?? 0,
                  illustId: e.illusts?.id ?? 0,
                  fileName: e.fileName ?? "",
                  status: 1))
              .toList();
          // 系列小说下载
          _novelList = novelSeriesFetcher.queue
              .where((element) =>
                  novelSeriesFetcher.urlPool.contains(element.seriesId.toString()))
              .map((e) => NovelTaskPersist(
                  seriesId: e.seriesId,
                  seriesTitle: e.seriesTitle,
                  userName: e.userName ?? "",
                  coverUrl: e.coverUrl,
                  novelIds: jsonEncode(e.novelIds),
                  novelCount: e.novelIds.length,
                  doneCount:
                      novelSeriesFetcher.jobMaps[e.seriesId.toString()]?.min ?? 0,
                  status: 1))
              .toList();
        }
      });
    }
  }

  _refresh() async {
    _page = 0;
    _endOfPage = false;
    final results = await taskPersistProvider.getDownloadTask(
        _page, toTaskStatus(currentIndex), asc);
    final novelResults = await novelTaskPersistProvider.getDownloadTask(
        _page, toTaskStatus(currentIndex), asc);
    if (mounted) {
      setState(() {
        _list = results;
        _novelList = novelResults;
      });
    }
  }

  _reQueryFilter() async {
    final results = await taskPersistProvider.getDownloadTask(
        _page, toTaskStatus(currentIndex), asc);
    final novelResults = await novelTaskPersistProvider.getDownloadTask(
        _page, toTaskStatus(currentIndex), asc);
    if (mounted) {
      setState(() {
        _list = results;
        _novelList = novelResults;
      });
    }
  }

  bool _nextLoading = false;
  bool _endOfPage = false;

  _next() async {
    if (_nextLoading || _endOfPage) return;
    _nextLoading = true;
    _page++;
    final results = await taskPersistProvider.getDownloadTask(
        _page, toTaskStatus(currentIndex), asc);
    final novelResults = await novelTaskPersistProvider.getDownloadTask(
        _page, toTaskStatus(currentIndex), asc);
    _endOfPage =
        results.length < 16 && novelResults.length < 16;
    _nextLoading = false;
    if (mounted) {
      setState(() {
        _list += results;
        _novelList += novelResults;
      });
    }
  }

  int toTaskStatus(int index) {
    switch (index) {
      case 1:
        return 1;
      case 2:
        return 2;
      case 3:
        return 3;
      default:
        return STATUS_ALL;
    }
  }

  String toMessage(int i) {
    switch (i) {
      case 0:
        return "seed";
      case 1:
        return I18n.of(context).running;
      case 2:
        return I18n.of(context).complete;
      case 3:
        return I18n.of(context).failed;
      default:
        return "seed";
    }
  }

  Widget _buildStatusWidget(int i) {
    switch (i) {
      case 0:
        return Text("seed",
            style:
                Theme.of(context).textTheme.bodyMedium!.copyWith(fontSize: 12));
      case 1:
        return Text(I18n.of(context).running,
            style:
                Theme.of(context).textTheme.bodyMedium!.copyWith(fontSize: 12));
      case 2:
        return Icon(
          Icons.check_circle,
          color: Colors.green,
          size: 16,
        );
      case 3:
        return Icon(
          Icons.error,
          size: 16,
        );
      default:
        return Text(
          "seed",
          style: Theme.of(context).textTheme.bodyMedium!.copyWith(fontSize: 16),
        );
    }
  }

  bool asc = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: Text(I18n.of(context).task_progress),
        actions: [
          IconButton(
              onPressed: () {
                setState(() {
                  _itemSimple = !_itemSimple;
                });
              },
              icon: (_itemSimple ? Icon(Icons.hide_image) : Icon(Icons.image))),
          RotationTransition(
            turns: Tween(begin: 0.0, end: 0.5).animate(rotationController),
            child: IconButton(
                onPressed: () {
                  if (asc)
                    rotationController.forward();
                  else
                    rotationController.reverse();
                  setState(() {
                    asc = !asc;
                  });
                  _reQueryFilter();
                },
                icon: Icon(Icons.sort)),
          ),
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
                          final novelResults = await novelTaskPersistProvider.getAllAccount();
                          novelResults.forEach((element) {
                            if (element.status == 3) {
                              _retryNovelJob(element);
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
                          final novelResults = await novelTaskPersistProvider.getAllAccount();
                          novelResults.forEach((element) {
                            if (element.status == 0) {
                              _retryNovelJob(element);
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
                          final novelResults = await novelTaskPersistProvider.getAllAccount();
                          novelResults.forEach((element) {
                            if (element.status == 2) {
                              _deleteNovelJob(element);
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
  int _page = 0;

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
          _scrollController.jumpTo(0);
          setState(() {
            this.currentIndex = index;
            if (currentIndex == 1) {
              _list = fetcher.queue
                  .where((element) => fetcher.urlPool.contains(element.url))
                  .map((e) => TaskPersist(
                      userName: e.illusts?.user.name ?? "",
                      title: e.illusts?.title ?? "",
                      url: e.url ?? "",
                      userId: e.illusts?.user.id ?? 0,
                      illustId: e.illusts?.id ?? 0,
                      fileName: e.fileName ?? "",
                      status: 1))
                  .toList();
              _novelList = novelSeriesFetcher.queue
                  .where((element) => novelSeriesFetcher.urlPool
                      .contains(element.seriesId.toString()))
                  .map((e) => NovelTaskPersist(
                      seriesId: e.seriesId,
                      seriesTitle: e.seriesTitle,
                      userName: e.userName ?? "",
                      coverUrl: e.coverUrl,
                      novelIds: jsonEncode(e.novelIds),
                      novelCount: e.novelIds.length,
                      doneCount: novelSeriesFetcher
                              .jobMaps[e.seriesId.toString()]
                              ?.min ??
                          0,
                      status: 1))
                  .toList();
            } else {
              _refresh();
            }
          });
        },
      ),
    );
  }

  Widget _body() {
    final merged = <Object>[..._list, ..._novelList]
      ..sort((a, b) {
        final idA = a is TaskPersist ? a.id : (a as NovelTaskPersist).id;
        final idB = b is TaskPersist ? b.id : (b as NovelTaskPersist).id;
        return (idB ?? 0).compareTo(idA ?? 0);
      });
    final trueList = asc ? merged.reversed.toList() : merged;
    return ListView.builder(
      controller: _scrollController,
      itemBuilder: (context, index) {
        if (trueList.isEmpty)
          return Container(
            height: MediaQuery.of(context).size.width,
            child: Center(
              child: Text(
                "[ ]",
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium!
                    .copyWith(fontSize: 24),
              ),
            ),
          );
        return _buildItem(trueList[index], index);
      },
      itemCount: (trueList.isEmpty) ? 1 : trueList.length,
    );
  }

  Widget _buildItem(Object item, int index) {
    if (item is NovelTaskPersist) return _buildNovelItem(item, index);
    return _buildImageItem(item as TaskPersist, index);
  }

  Widget _buildImageItem(TaskPersist taskPersist, int index) {
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
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12))),
      child: InkWell(
        onTap: () {
          Leader.push(context, IllustLightingPage(id: taskPersist.illustId));
        },
        child: Stack(
          children: [
            Row(
              children: [
                (!_itemSimple)
                    ? Container(
                        child: Stack(
                          children: [
                            Container(
                              height: 100,
                              width: 100,
                              child: PixivImage(
                                taskPersist.medium ?? taskPersist.url,
                                fit: BoxFit.cover,
                                height: 100,
                                width: 100,
                              ),
                            ),
                            (jobEntity != null && jobEntity.status != 2)
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
                                    height: 100,
                                    width: 100,
                                  ),
                          ],
                        ),
                        width: 100,
                        height: 100,
                      )
                    : Container(
                        width: 8,
                      ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                taskPersist.title,
                                maxLines: 1,
                                overflow: TextOverflow.clip,
                                style: Theme.of(context).textTheme.bodyLarge,
                              ),
                            ),
                          ),
                          if (_itemSimple) ...[
                            InkWell(
                                onTap: () {
                                  _retryJob(taskPersist);
                                },
                                child: Icon(Icons.refresh)),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: InkWell(
                                  onTap: () {
                                    _deleteJob(taskPersist);
                                  },
                                  child: Icon(Icons.delete)),
                            ),
                          ],
                          Padding(
                            padding: const EdgeInsets.only(right: 16.0),
                            child: _buildStatusWidget(
                                jobEntity?.status ?? taskPersist.status),
                          ),
                        ],
                      ),
                      Padding(
                        padding:
                            const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Text(
                          taskPersist.userName,
                          style: Theme.of(context)
                              .textTheme
                              .bodyLarge!
                              .copyWith(
                                  color:
                                      Theme.of(context).colorScheme.primary,
                                  fontSize: 12),
                        ),
                      ),
                      (!_itemSimple)
                          ? Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                              mainAxisSize: MainAxisSize.max,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(" "),
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
                            )
                          : Container(
                              height: 10,
                            ),
                    ],
                  ),
                ),
              ],
            ),
            (jobEntity != null && jobEntity.status != 2)
                ? Positioned(
                    left: 0.0,
                    right: 0.0,
                    bottom: 0.0,
                    child: LinearProgressIndicator(
                      value: ((jobEntity.min ?? 0.0) /
                              ((jobEntity.max ?? 0.0)))
                          .toDouble(),
                      backgroundColor: Colors.grey[200],
                    ),
                  )
                : Container(),
          ],
        ),
      ),
    );
  }

  Future _deleteJob(TaskPersist persist) async {
    await taskPersistProvider.remove(persist.id!);
    fetcher.jobMaps.remove(persist.url);
    fetcher.queue.removeWhere((element) => element.url == persist.url);
    setState(() {
      _list.removeWhere((element) => element.id == persist.id);
    });
  }

  Future _retryJob(TaskPersist persist) async {
    if (persist.status == 2) return;
    await _deleteJob(persist);
    final taskPersist = persist;
    await taskPersistProvider.insert(taskPersist);
    await fetcher.save(persist.url, taskPersist.toIllusts(), persist.fileName);
    _refresh();
  }

  // 任务页面的系列小说下载项
  Widget _buildNovelItem(NovelTaskPersist taskPersist, int index) {
    final key = taskPersist.seriesId.toString();
    JobEntity? jobEntity = novelSeriesFetcher.jobMaps[key];
    if (currentIndex != 0) {
      if ((jobEntity?.status ?? taskPersist.status) != currentIndex)
        return Visibility(
          child: Container(
            height: 0,
          ),
          visible: false,
        );
    }
    final int done = jobEntity?.min ?? taskPersist.doneCount;
    final int total = jobEntity?.max ?? taskPersist.novelCount;
    final int status = jobEntity?.status ?? taskPersist.status;
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12))),
      child: InkWell(
        onTap: () {
          Leader.push(context, NovelSeriesPage(taskPersist.seriesId));
        },
        child: LayoutBuilder(builder: (context, constraints) {
          final coverWidth = constraints.maxWidth * 0.25;
          return SizedBox(
            height: 132,
            child: Row(
              children: [
                Container(
                  width: coverWidth,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      PixivImage(
                        taskPersist.coverUrl ?? "",
                        fit: BoxFit.cover,
                      ),
                      if (jobEntity != null && status != 2)
                        Center(
                          child: CircularProgressIndicator(
                            value: total == 0
                                ? null
                                : (done / total).toDouble(),
                            backgroundColor: Colors.grey[200],
                          ),
                        ),
                    ],
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                taskPersist.seriesTitle,
                                maxLines: 1,
                                overflow: TextOverflow.clip,
                                style:
                                    Theme.of(context).textTheme.bodyLarge,
                              ),
                            ),
                            _buildStatusWidget(status),
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              LinearProgressIndicator(
                                value: total == 0
                                    ? null
                                    : (done / total).toDouble(),
                                backgroundColor: Colors.grey[200],
                              ),
                              Padding(
                                padding: const EdgeInsets.only(top: 4.0),
                                child: Text(
                                  status == 2
                                      ? "$total/$total"
                                      : "$done/$total",
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium!
                                      .copyWith(fontSize: 12),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Align(
                            alignment: Alignment.bottomRight,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                    onPressed: () {
                                      _retryNovelJob(taskPersist);
                                    },
                                    icon: Icon(Icons.refresh)),
                                IconButton(
                                    onPressed: () {
                                      _deleteNovelJob(taskPersist);
                                    },
                                    icon: Icon(Icons.delete)),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }

  Future _deleteNovelJob(NovelTaskPersist persist) async {
    await novelTaskPersistProvider.remove(persist.id!);
    novelSeriesFetcher.jobMaps.remove(persist.seriesId.toString());
    novelSeriesFetcher.queue
        .removeWhere((element) => element.seriesId == persist.seriesId);
    setState(() {
      _novelList.removeWhere((element) => element.id == persist.id);
    });
  }

  Future _retryNovelJob(NovelTaskPersist persist) async {
    if (persist.status == 2) return;
    await _deleteNovelJob(persist);
    await novelSeriesFetcher.save(
      persist.seriesId,
      persist.getNovelIds(),
      seriesTitle: persist.seriesTitle,
      userName: persist.userName,
      coverUrl: persist.coverUrl,
    );
    _refresh();
  }
}
