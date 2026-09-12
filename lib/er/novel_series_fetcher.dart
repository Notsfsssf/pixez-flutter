import 'dart:convert';
import 'dart:io';

import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as Path;
import 'package:path_provider/path_provider.dart';
import 'package:pixez/er/lprinter.dart';
import 'package:pixez/exts.dart';
import 'package:pixez/i18n.dart';
import 'package:pixez/main.dart';
import 'package:pixez/models/novel_task_persist.dart';
import 'package:pixez/models/novel_web_response.dart';
import 'package:pixez/network/api_client.dart';
import 'package:pixez/page/novel/viewer/novel_store.dart';
import 'package:pixez/saf_plugin.dart';
import 'package:pixez/store/save_store.dart';
import 'package:quiver/collection.dart';

class NovelSeriesTaskBean {
  int seriesId;
  String seriesTitle;
  String? userName;
  String? coverUrl;
  List<int> novelIds;
  String fileName;

  NovelSeriesTaskBean({
    required this.seriesId,
    required this.seriesTitle,
    required this.novelIds,
    required this.fileName,
    this.userName,
    this.coverUrl,
  });
}

class NovelSeriesFetcher {
  BuildContext? context;
  List<NovelSeriesTaskBean> queue = [];
  List<String> urlPool = [];
  NovelTaskPersistProvider novelTaskPersistProvider = NovelTaskPersistProvider();
  LruMap<String, JobEntity> jobMaps = LruMap();

  CancelFunc? _bannerCancel;
  final ValueNotifier<String> _bannerText = ValueNotifier('');

  NovelSeriesFetcher();

  Future<void> start() async {
    await novelTaskPersistProvider.open();
  }

  Future<void> save(
    int seriesId,
    List<int> novelIds, {
    String? seriesTitle,
    String? userName,
    String? coverUrl,
  }) async {
    await novelTaskPersistProvider.open();
    final key = seriesId.toString();
    if (queue.isNotEmpty || urlPool.isNotEmpty) {
      BotToast.showText(text: "已有任务进行中");
      return;
    }
    final exist = await novelTaskPersistProvider.getAccount(key);
    if (exist != null) {
      BotToast.showText(text: "already in queue");
      return;
    }
    final title = seriesTitle ?? "";
    final persist = NovelTaskPersist(
      seriesId: seriesId,
      seriesTitle: title,
      userName: userName ?? "",
      coverUrl: coverUrl,
      novelIds: jsonEncode(novelIds),
      novelCount: novelIds.length,
      status: 0,
      fileName: "${title.trim().toLegal()}.txt",
    );
    await novelTaskPersistProvider.insert(persist);
    queue.add(NovelSeriesTaskBean(
      seriesId: seriesId,
      seriesTitle: title,
      userName: userName,
      coverUrl: coverUrl,
      novelIds: novelIds,
      fileName: persist.fileName!,
    ));
    nextJob();
  }

  void nextJob() {
    // 系列小说一次只允许一个下载任务
    if (queue.isNotEmpty && urlPool.isEmpty) {
      NovelSeriesTaskBean? first = null;
      for (var i in queue) {
        if (!urlPool.contains(i.seriesId.toString())) {
          first = i;
          break;
        }
      }
      if (first == null) return;
      urlPool.add(first.seriesId.toString());
      _download(first);
    }
  }

  // 顶部"下载中"提示
  void _updateBanner() {
    if (urlPool.isEmpty) {
      _hideBanner();
      return;
    }
    final parts = <String>[];
    for (final key in urlPool) {
      final bean =
          queue.where((e) => e.seriesId.toString() == key).firstOrNull;
      if (bean == null) continue;
      final job = jobMaps[key];
      final done = job?.min ?? 0;
      final total = job?.max ?? bean.novelIds.length;
      parts.add('${bean.seriesTitle.split('').take(2).join('')}... $done/$total');
    }
    _showBanner(parts.join('、'));
  }

  void _showBanner(String text) {
    _bannerText.value = text;
    if (_bannerCancel != null) return;
    _bannerCancel = BotToast.showCustomNotification(
      align: Alignment.topCenter,
      onlyOne: true,
      crossPage: true,
      enableSlideOff: false,
      dismissDirections: const [],
      duration: const Duration(days: 1),
      toastBuilder: (cancel) => ValueListenableBuilder<String>(
        valueListenable: _bannerText,
        builder: (context, value, _) => Align(
          alignment: Alignment.topCenter,
          child: Card(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  const SizedBox(width: 10),
                  Text('${I18n.of(context).downloading} $value'),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _hideBanner() {
    _bannerCancel?.call();
    _bannerCancel = null;
  }

  Future<void> _download(NovelSeriesTaskBean bean) async {
    final key = bean.seriesId.toString();
    final job = jobMaps[key] ?? (jobMaps[key] = JobEntity());
    job
      ..status = 1
      ..min = 0
      ..max = bean.novelIds.length;
    _updateBanner();
    try {
      final buffer = StringBuffer();
      // 小说并发下载, 数量受「最大同时下载任务数量」设置限制
      final contents = List<String?>.filled(bean.novelIds.length, null);
      final limit = userSetting.maxRunningTask < 1
          ? 1
          : userSetting.maxRunningTask;
      var done = 0;
      var index = 0;
      Future<void> fetch() async {
        while (true) {
          final i = index++;
          if (i >= bean.novelIds.length) break;
          final response = await apiClient.webviewNovel(bean.novelIds[i]);
          final json = parseNovelJsonFromHtml(response.data);
          if (json != null) {
            final webResponse = NovelWebResponse.fromJson(jsonDecode(json));
            contents[i] = '${webResponse.title}\n\n${webResponse.text}\n\n';
          }
          done++;
          job.min = done;
          await _updateProgress(bean, done);
          _updateBanner();
        }
      }

      await Future.wait(List.generate(limit, (_) => fetch()));
      for (final content in contents) {
        if (content != null) buffer.write(content);
      }
      final content = buffer.toString();
      if (Platform.isAndroid) {
        final uri = await SAFPlugin.createFile(bean.fileName, "application/txt");
        if (uri == null) {
          BotToast.showText(text: "export cancel");
          job.status = 3;
          await _updateStatus(bean, 3);
          _finish(bean);
          return;
        }
        await SAFPlugin.writeUri(uri, utf8.encode(content));
      } else if (Platform.isIOS) {
        final path = await getApplicationDocumentsDirectory();
        final dirPath = Path.join(path.path, "novel_export");
        final dir = Directory(dirPath);
        if (!dir.existsSync()) {
          dir.createSync(recursive: true);
        }
        final allPath = Path.join(dirPath, "All");
        final allDir = Directory(allPath);
        if (!allDir.existsSync()) {
          allDir.createSync(recursive: true);
        }
        final filePath = Path.join(allPath, bean.fileName);
        File(filePath).writeAsStringSync(content);
        LPrinter.d("path: $filePath");
      }
      job.status = 2;
      await _updateStatus(bean, 2);
      BotToast.showText(text: "export success");
    } catch (e) {
      print(e);
      job.status = 3;
      await _updateStatus(bean, 3);
      BotToast.showText(text: "export failed: ${e.toString()}");
    } finally {
      _finish(bean);
    }
  }

  Future<void> _updateProgress(NovelSeriesTaskBean bean, int done) async {
    final persist = await novelTaskPersistProvider.getAccount(
        bean.seriesId.toString());
    if (persist == null) return;
    await novelTaskPersistProvider.update(persist..doneCount = done);
  }

  Future<void> _updateStatus(NovelSeriesTaskBean bean, int status) async {
    final persist = await novelTaskPersistProvider.getAccount(
        bean.seriesId.toString());
    if (persist == null) return;
    await novelTaskPersistProvider.update(persist..status = status);
  }

  void _finish(NovelSeriesTaskBean bean) {
    final key = bean.seriesId.toString();
    urlPool.remove(key);
    queue.removeWhere((element) => element.seriesId == bean.seriesId);
    nextJob();
    _updateBanner();
  }
}
