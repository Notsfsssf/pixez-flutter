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

import 'package:fluent_ui/fluent_ui.dart';
import 'package:pixez/fluent/component/pixez_button.dart';
import 'package:pixez/fluent/component/pixiv_image.dart';
import 'package:pixez/fluent/component/sort_group.dart';
import 'package:pixez/er/leader.dart';
import 'package:pixez/i18n.dart';
import 'package:pixez/main.dart';
import 'package:pixez/models/task_persist.dart';
import 'package:pixez/fluent/page/picture/illust_lighting_page.dart';
import 'package:pixez/store/save_store.dart';

class JobPage extends StatefulWidget {
  @override
  _JobPageState createState() => _JobPageState();
}

class _JobPageState extends State<JobPage> with SingleTickerProviderStateMixin {
  List<TaskPersist> _list = [];
  TaskPersistProvider taskPersistProvider = TaskPersistProvider();
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
        }
      });
    }
  }

  _refresh() async {
    _page = 0;
    _endOfPage = false;
    final results = await taskPersistProvider.getDownloadTask(
        _page, toTaskStatus(currentIndex), asc);
    if (mounted) {
      setState(() {
        _list = results;
      });
    }
  }

  _reQueryFilter() async {
    final results = await taskPersistProvider.getDownloadTask(
        _page, toTaskStatus(currentIndex), asc);
    if (mounted) {
      setState(() {
        _list = results;
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
    _endOfPage = results.length < 16;
    _nextLoading = false;
    if (mounted) {
      setState(() {
        _list += results;
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
            style: FluentTheme.of(context)
                .typography
                .body!
                .copyWith(fontSize: 12));
      case 1:
        return Text(I18n.of(context).running,
            style: FluentTheme.of(context)
                .typography
                .body!
                .copyWith(fontSize: 12));
      case 2:
        return Icon(
          FluentIcons.check_mark,
          color: Colors.green,
          size: 16,
        );
      case 3:
        return Icon(
          FluentIcons.error,
          size: 16,
        );
      default:
        return Text(
          "seed",
          style:
              FluentTheme.of(context).typography.body!.copyWith(fontSize: 16),
        );
    }
  }

  bool asc = false;

  @override
  Widget build(BuildContext context) {
    return ContentDialog(
      title: PageHeader(
        title: Text(I18n.of(context).task_progress),
        commandBar: CommandBar(
          mainAxisAlignment: MainAxisAlignment.end,
          primaryItems: [
            CommandBarButton(
              onPressed: () {
                setState(() {
                  _itemSimple = !_itemSimple;
                });
              },
              icon: (_itemSimple
                  ? Icon(FluentIcons.picture)
                  : Icon(FluentIcons.hide3)),
            ),
            CommandBarButton(
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
              icon: RotationTransition(
                turns: Tween(begin: 0.0, end: 0.5).animate(rotationController),
                child: Icon(FluentIcons.sort_down),
              ),
            ),
          ],
          secondaryItems: [
            CommandBarButton(
              label: Text(I18n.of(context).retry_failed_tasks),
              onPressed: () async {
                final results = await taskPersistProvider.getAllAccount();
                results.forEach((element) {
                  if (element.status == 3) {
                    _retryJob(element);
                  }
                });
                initMethod();
              },
            ),
            CommandBarButton(
              label: Text(I18n.of(context).retry_seed_task),
              onPressed: () async {
                final results = await taskPersistProvider.getAllAccount();
                results.forEach((element) {
                  if (element.status == 0) {
                    _retryJob(element);
                  }
                });
                initMethod();
              },
            ),
            CommandBarButton(
              label: Text(I18n.of(context).clear_completed_tasks),
              onPressed: () async {
                final results = await taskPersistProvider.getAllAccount();
                results.forEach((element) {
                  if (element.status == 2) {
                    _deleteJob(element);
                  }
                });
                initMethod();
              },
            )
          ],
        ),
      ),
      content: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTopChip(),
            Expanded(child: _body()),
          ],
        ),
      ),
      actions: [
        FilledButton(
          child: Text(I18n.of(context).ok),
          onPressed: Navigator.of(context).pop,
        ),
      ],
    );
  }

  int currentIndex = 0;
  int _page = 0;

  Widget _buildTopChip() {
    return SortGroup(
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
          } else {
            _refresh();
          }
        });
      },
    );
  }

  Widget _body() {
    final trueList = asc ? _list.reversed.toList() : _list;
    return ListView.builder(
      controller: _scrollController,
      itemBuilder: (context, index) {
        if (trueList.isEmpty)
          return Container(
            height: MediaQuery.of(context).size.width,
            child: Center(
              child: Text(
                "[ ]",
                style: FluentTheme.of(context)
                    .typography
                    .body!
                    .copyWith(fontSize: 24),
              ),
            ),
          );
        return _buildItem(trueList[index], index);
      },
      itemCount: (trueList.isEmpty) ? 1 : trueList.length,
    );
  }

  Widget _buildItem(TaskPersist taskPersist, int index) {
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
    return PixEzButton(
      onPressed: () {
        Leader.push(
          context,
          IllustLightingPage(id: taskPersist.illustId),
          icon: const Icon(FluentIcons.picture),
          title: Text(I18n.of(context).illust),
        );
      },
      child: Card(
        padding: EdgeInsets.zero,
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
                                      child: ProgressRing(
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
                              ),
                            ),
                          ),
                          if (_itemSimple) ...[
                            PixEzButton(
                                onPressed: () {
                                  _retryJob(taskPersist);
                                },
                                child: Icon(FluentIcons.refresh)),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: PixEzButton(
                                  onPressed: () {
                                    _deleteJob(taskPersist);
                                  },
                                  child: Icon(FluentIcons.delete)),
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
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Text(
                          taskPersist.userName,
                          style:
                              FluentTheme.of(context).typography.body?.copyWith(
                                    color: FluentTheme.of(context).accentColor,
                                    fontSize: 12,
                                  ),
                        ),
                      ),
                      (!_itemSimple)
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              mainAxisSize: MainAxisSize.max,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(" "),
                                Row(
                                  children: [
                                    PixEzButton(
                                        onPressed: () {
                                          _retryJob(taskPersist);
                                        },
                                        child: Icon(FluentIcons.refresh)),
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: PixEzButton(
                                          onPressed: () {
                                            _deleteJob(taskPersist);
                                          },
                                          child: Icon(FluentIcons.delete)),
                                    ),
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
                    child: ProgressBar(
                      value: ((jobEntity.min ?? 0.0) / ((jobEntity.max ?? 0.0)))
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
}
