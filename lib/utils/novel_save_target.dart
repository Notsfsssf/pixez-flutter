import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as Path;
import 'package:path_provider/path_provider.dart';
import 'package:pixez/main.dart';
import 'package:pixez/saf_plugin.dart';

/// 小说保存位置管理（跨平台）：
/// - Android：未设置自定义目录时写入 `Download/PixEz/`，设置后走 SAF tree uri；
/// - iOS：默认写入应用文档目录下的 `novel_export/`；
/// - Windows / Linux / macOS：默认写入系统「下载」目录下的 `PixEz/`。
///
/// 桌面与 iOS 的自定义目录是一个绝对路径，Android 是一条持久化授权的 tree uri。
class NovelSaveTarget {
  /// Android：SAF 目录 uri
  static const String TREE_URI_KEY = "novel_save_tree_uri";

  /// 桌面 / iOS：自定义目录的绝对路径
  static const String DIR_PATH_KEY = "novel_save_dir_path";

  /// 界面展示用名称（各平台共用）
  static const String TREE_DISPLAY_KEY = "novel_save_tree_display";

  static const String DEFAULT_DISPLAY = "Download/PixEz";
  static const String IOS_DEFAULT_DISPLAY = "应用文档/novel_export";
  static const String DESKTOP_DEFAULT_DISPLAY = "下载目录/PixEz";

  static String? _read(String key) {
    final value = userSetting.prefs.getString(key);
    if (value == null || value.isEmpty) return null;
    return value;
  }

  static String? get treeUri => _read(TREE_URI_KEY);

  static String? get dirPath => _read(DIR_PATH_KEY);

  static String? get treeDisplay => _read(TREE_DISPLAY_KEY);

  /// 平台各自的默认位置
  static String get defaultDisplay {
    if (Platform.isAndroid) return DEFAULT_DISPLAY;
    if (Platform.isIOS) return IOS_DEFAULT_DISPLAY;
    return DESKTOP_DEFAULT_DISPLAY;
  }

  static bool get isCustom {
    if (Platform.isAndroid) return (treeUri ?? '').isNotEmpty;
    return (dirPath ?? '').isNotEmpty;
  }

  /// 界面上展示的当前保存目录
  static String get display =>
      isCustom ? (treeDisplay ?? "自定义目录") : defaultDisplay;

  /// 打开系统目录选择器并记住选择；返回是否选择成功
  static Future<bool> pick() async {
    if (Platform.isAndroid) {
      final result = await SAFPlugin.pickSaveDir();
      if (result == null) return false;
      final uri = result['uri'] ?? '';
      if (uri.isEmpty) return false;
      await userSetting.prefs.setString(TREE_URI_KEY, uri);
      await userSetting.prefs.setString(
        TREE_DISPLAY_KEY,
        (result['display'] ?? '').isEmpty ? "自定义目录" : result['display']!,
      );
      return true;
    }
    // 桌面 / iOS：系统目录选择器返回绝对路径
    String? path;
    try {
      path = await FilePicker.getDirectoryPath(dialogTitle: "选择小说保存目录");
    } catch (_) {
      // 平台不支持目录选择时保持原设置不变
      return false;
    }
    if (path == null || path.trim().isEmpty) return false;
    await userSetting.prefs.setString(DIR_PATH_KEY, path);
    await userSetting.prefs.setString(TREE_DISPLAY_KEY, path);
    return true;
  }

  /// 恢复默认保存位置
  static Future<void> reset() async {
    await userSetting.prefs.remove(TREE_URI_KEY);
    await userSetting.prefs.remove(DIR_PATH_KEY);
    await userSetting.prefs.remove(TREE_DISPLAY_KEY);
  }

  /// 保存文本文件：优先自定义目录，未设置或失败时回退到平台默认目录。
  /// [subDir] 非空时收纳到该子目录，用于整系列下载归档。
  /// 返回用于提示的可读路径，全部失败返回 null。
  static Future<String?> save(
    String name,
    String mimeType,
    String text, {
    String? subDir,
  }) async {
    final sub = (subDir ?? '').trim();
    if (Platform.isAndroid) return _saveAndroid(name, mimeType, text, sub);
    return _saveFile(name, text, sub);
  }

  static Future<String?> _saveAndroid(
    String name,
    String mimeType,
    String text,
    String sub,
  ) async {
    final uri = treeUri;
    if (uri != null && uri.isNotEmpty) {
      final saved = await SAFPlugin.saveToTree(
        uri,
        name,
        mimeType,
        text,
        subDir: sub.isEmpty ? null : sub,
      );
      if (saved != null && saved.isNotEmpty) return saved;
    }
    return SAFPlugin.saveToDownloads(
      name,
      mimeType,
      text,
      relativePath: sub.isEmpty ? 'PixEz' : 'PixEz/$sub',
    );
  }

  static Future<String?> _saveFile(String name, String text, String sub) async {
    try {
      var dir = await _targetDir();
      if (sub.isNotEmpty) dir = Directory(Path.join(dir.path, sub));
      if (!dir.existsSync()) dir.createSync(recursive: true);
      final file = File(Path.join(dir.path, name));
      await file.writeAsString(text, flush: true);
      return file.path;
    } catch (_) {
      return null;
    }
  }

  /// 实际写入目录：自定义目录可用则用它，否则用平台默认目录
  static Future<Directory> _targetDir() async {
    final custom = dirPath;
    if (custom != null && custom.isNotEmpty) {
      final dir = Directory(custom);
      try {
        if (!dir.existsSync()) dir.createSync(recursive: true);
        // 目录不可写（被删、外接盘拔掉等）时回退默认目录
        final probe = File(Path.join(dir.path, ".pixez_write_test"));
        probe.writeAsStringSync("");
        probe.deleteSync();
        return dir;
      } catch (_) {}
    }
    final dir = await _defaultDir();
    if (!dir.existsSync()) dir.createSync(recursive: true);
    return dir;
  }

  static Future<Directory> _defaultDir() async {
    if (Platform.isIOS) {
      final docs = await getApplicationDocumentsDirectory();
      return Directory(Path.join(docs.path, "novel_export"));
    }
    final downloads = await getDownloadsDirectory();
    if (downloads != null) {
      return Directory(Path.join(downloads.path, "PixEz"));
    }
    final docs = await getApplicationDocumentsDirectory();
    return Directory(Path.join(docs.path, "PixEz"));
  }
}
