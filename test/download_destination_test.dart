import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:pixez/document_plugin.dart';
import 'package:pixez/main.dart' as app;
import 'package:pixez/models/illust.dart';
import 'package:pixez/models/task_persist.dart';
import 'package:pixez/store/save_store.dart';

import '../integration_test/fixtures/desktop_artworks.dart';

class _Paths extends PathProviderPlatform {
  @override
  Future<String?> getTemporaryPath() async => Directory.systemTemp.path;
}

class _Tasks extends TaskPersistProvider {
  _Tasks(this.task);
  final TaskPersist task;
  bool updated = false;
  @override
  Future<TaskPersist?> getAccount(String id) async => task;
  @override
  Future<int> update(TaskPersist value) async {
    updated = true;
    return 1;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test(
    'a completed URL can be saved again when the current destination is missing',
    () async {
      final artwork = Illusts.fromJson(
        jsonDecode(desktopArtworkJson)['illusts'][0],
      );
      final url = artwork.metaSinglePage!.originalImageUrl!;
      final tasks = _Tasks(
        TaskPersist(
          userName: '',
          title: '',
          url: url,
          userId: 1,
          illustId: artwork.id,
          fileName: 'previous-folder.jpg',
          status: 2,
        ),
      );
      final oldProvider = app.fetcher.taskPersistProvider;
      final oldPaths = PathProviderPlatform.instance;
      PathProviderPlatform.instance = _Paths();
      final oldPort = app.fetcher.sendPortToChild;
      final oldFormat = app.userSetting.format;
      final oldEval = app.userSetting.fileNameEval;
      final oldSingle = app.userSetting.singleFolder;
      app.fetcher.taskPersistProvider = tasks;
      app.fetcher.sendPortToChild = null;
      app.userSetting.format = 'new-destination_{illust_id}';
      app.userSetting.fileNameEval = 0;
      app.userSetting.singleFolder = false;
      final messenger =
          TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
      messenger.setMockMethodCallHandler(
        DocumentPlugin.platform,
        (call) async => false,
      );
      final store = SaveStore();
      addTearDown(() {
        app.fetcher.taskPersistProvider = oldProvider;
        PathProviderPlatform.instance = oldPaths;
        app.fetcher.sendPortToChild = oldPort;
        app.fetcher.queue.removeWhere((task) => task.url == url);
        app.fetcher.urlPool.remove(url);
        app.userSetting.format = oldFormat;
        app.userSetting.fileNameEval = oldEval;
        app.userSetting.singleFolder = oldSingle;
        messenger.setMockMethodCallHandler(DocumentPlugin.platform, null);
        store.dispose();
      });
      await store.saveImage(artwork);
      for (var i = 0; i < 100 && app.fetcher.queue.isEmpty; i++) {
        await Future<void>.delayed(const Duration(milliseconds: 10));
      }
      expect(app.fetcher.queue.single.fileName, startsWith('new-destination_'));
      expect(tasks.updated, isTrue);
      expect(tasks.task.status, 0);
    },
    skip: !Platform.isMacOS,
  );
}
