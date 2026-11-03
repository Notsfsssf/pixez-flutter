import 'dart:convert';

import 'package:bot_toast/bot_toast.dart';
import 'package:material_ui/material_ui.dart';
import 'package:pixez/exts.dart';
import 'package:pixez/models/novel_recom_response.dart';
import 'package:pixez/models/novel_series_detail.dart';
import 'package:pixez/models/novel_web_response.dart';
import 'package:pixez/network/api_client.dart';
import 'package:pixez/page/novel/viewer/novel_store.dart' show parseNovelJsonFromHtml;
import 'package:pixez/utils/novel_save_target.dart';

/// 整系列一键下载：
/// 1. 顺着 next_url 把系列所有分页拉完（不受当前列表已加载多少的限制）
/// 2. 逐篇拉正文，保存到「保存目录 / 系列名」子目录
/// 3. 文件名加三位序号，保证在文件管理器里按阅读顺序排列
class NovelSeriesDownload {
  static bool _running = false;

  static Future<void> start(
    BuildContext context, {
    required int seriesId,
    String? seriesTitle,
  }) async {
    if (_running) {
      BotToast.showText(text: "已有下载任务在进行中");
      return;
    }
    _running = true;
    String? summary;
    try {
      summary = await showDialog<String>(
        context: context,
        barrierDismissible: false,
        builder: (_) => _SeriesDownloadDialog(
          seriesId: seriesId,
          seriesTitle: seriesTitle,
        ),
      );
    } finally {
      _running = false;
    }
    if (summary != null && summary.isNotEmpty) {
      BotToast.showText(text: summary);
    }
  }
}

class _SeriesDownloadDialog extends StatefulWidget {
  final int seriesId;
  final String? seriesTitle;

  const _SeriesDownloadDialog({required this.seriesId, this.seriesTitle});

  @override
  State<_SeriesDownloadDialog> createState() => _SeriesDownloadDialogState();
}

class _SeriesDownloadDialogState extends State<_SeriesDownloadDialog> {
  String _stage = "正在获取系列目录…";
  String _current = "";
  String _folder = "";
  int _done = 0;
  int _total = 0;
  int _failed = 0;
  bool _cancel = false;
  bool _closed = false;

  @override
  void initState() {
    super.initState();
    _run();
  }

  @override
  void dispose() {
    // 弹窗被意外关闭时让循环尽快停下
    _cancel = true;
    super.dispose();
  }

  void _update(VoidCallback fn) {
    if (!mounted) return;
    setState(fn);
  }

  void _finish(String text) {
    if (_closed) return;
    _closed = true;
    if (mounted) Navigator.of(context).pop(text);
  }

  /// 目录名过滤：控制字符、路径非法字符、结尾点全部去掉，并限制长度
  static String _sanitize(String raw) {
    var s = raw
        .replaceAll(RegExp(r'[\x00-\x1F\x7F]'), ' ')
        .replaceAll('"', '')
        .trim()
        .toLegal()
        .trim();
    while (s.endsWith('.')) {
      s = s.substring(0, s.length - 1).trim();
    }
    if (s.length > 60) s = s.substring(0, 60).trim();
    return s;
  }

  Future<List<Novel>> _fetchAll() async {
    final collected = <Novel>[];
    final response = await apiClient.novelSeries(widget.seriesId);
    final detail = NovelSeriesResponse.fromJson(response.data);
    collected.addAll(detail.novels);
    if (_folder.isEmpty) {
      _folder = _sanitize(widget.seriesTitle ?? detail.novelSeriesDetail.title);
    }
    var next = detail.nextUrl;
    var guard = 0;
    while (next != null && !_cancel && guard < 200) {
      guard++;
      _update(() => _stage = "正在获取系列目录…（已 ${collected.length} 篇）");
      final page = await apiClient.getNext(next);
      final pageDetail = NovelSeriesResponse.fromJson(page.data);
      collected.addAll(pageDetail.novels);
      next = pageDetail.nextUrl;
    }
    // 分页边界可能重复，按 id 去重并保持原顺序
    final seen = <int>{};
    final unique = <Novel>[];
    for (final novel in collected) {
      if (seen.add(novel.id)) unique.add(novel);
    }
    return unique;
  }

  Future<void> _run() async {
    List<Novel> novels;
    try {
      novels = await _fetchAll();
    } catch (e) {
      _finish("获取系列目录失败：$e");
      return;
    }
    if (_cancel) {
      _finish("已取消");
      return;
    }
    if (novels.isEmpty) {
      _finish("这个系列没有可下载的小说");
      return;
    }
    if (_folder.isEmpty) _folder = "novel_series_${widget.seriesId}";
    _update(() {
      _total = novels.length;
      _stage = "开始下载";
    });

    for (var i = 0; i < novels.length; i++) {
      if (_cancel) break;
      final novel = novels[i];
      _update(() => _current = novel.title);
      try {
        final response = await apiClient.webviewNovel(novel.id);
        final json = parseNovelJsonFromHtml(response.data);
        if (json == null) throw const FormatException("无法解析正文");
        final web = NovelWebResponse.fromJson(jsonDecode(json));
        final text = web.text;
        if (text.trim().isEmpty) throw const FormatException("正文为空");
        final seq = (i + 1).toString().padLeft(3, '0');
        final name = "${seq}_${novel.title.trim().toLegal().trim()}.txt";
        final path = await NovelSaveTarget.save(
          name,
          "text/plain",
          text,
          subDir: _folder,
        );
        if (path == null) throw const FormatException("写入失败");
      } catch (e) {
        _failed++;
      }
      _update(() => _done = i + 1);
      // 稍微放缓，避免连续请求触发限流
      if (i < novels.length - 1) {
        await Future.delayed(const Duration(milliseconds: 150));
      }
    }

    final ok = _done - _failed;
    if (_cancel) {
      _finish("已取消：成功 $ok 篇，失败 $_failed 篇（共 $_total 篇）");
    } else if (_failed == 0) {
      _finish("已保存 $ok 篇到 ${NovelSaveTarget.display}/$_folder");
    } else {
      _finish("完成：成功 $ok 篇，失败 $_failed 篇");
    }
  }

  @override
  Widget build(BuildContext context) {
    final progress = _total == 0 ? null : (_done / _total).clamp(0.0, 1.0);
    return AlertDialog(
      title: Text("整系列下载"),
      content: SizedBox(
        width: 320,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              _total == 0
                  ? _stage
                  : "正在下载 $_done / $_total 篇（失败 $_failed）",
            ),
            const SizedBox(height: 12),
            LinearProgressIndicator(value: progress),
            const SizedBox(height: 12),
            Text(
              _current.isEmpty ? " " : _current,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 12),
            Text(
              "保存到：${NovelSaveTarget.display}/${_folder.isEmpty ? "…" : _folder}",
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            if (_cancel) return;
            setState(() => _cancel = true);
          },
          child: Text(_cancel ? "正在停止…" : "取消"),
        ),
      ],
    );
  }
}
