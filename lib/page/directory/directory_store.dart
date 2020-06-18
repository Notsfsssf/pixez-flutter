import 'dart:io';

import 'package:flutter/services.dart';
import 'package:mobx/mobx.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
part 'directory_store.g.dart';

class DirectoryStore = _DirectoryStoreBase with _$DirectoryStore;

abstract class _DirectoryStoreBase with Store {
  static const platform = const MethodChannel('com.perol.dev/save');
  @observable
  String path;
  @observable
  bool checkSuccess = false;

  @observable
  ObservableList<FileSystemEntity> list = ObservableList();
  SharedPreferences _preferences;

  _DirectoryStoreBase() {
    init();
  }

  @action
  Future<void> enterFolder(Directory fileSystemEntity) async {
    path = fileSystemEntity.path;
    list = ObservableList.of(fileSystemEntity.listSync());
  }

  @action
  Future<void> undo() async {
    path = (await platform.invokeMethod('get_path')) as String;
    list = ObservableList.of(Directory(path).listSync());
  }

  @action
  Future<void> check() async {
    if (!path.contains("/storage/emulated/0")) {
      return;
    }
    await _preferences.setString("store_path", path);
    checkSuccess = true;
  }

  @action
  Future<void> backFolder() async {
    final fileSystemEntity = Directory(path).parent;
    if (!fileSystemEntity.path.contains("/storage/emulated/0")) {
      return;
    }
    path = fileSystemEntity.path;
    list = ObservableList.of(fileSystemEntity.listSync());
  }

  @action
  setPath(String result) {
    path = result;
  }

  @action
  Future<void> init() async {
    _preferences = await SharedPreferences.getInstance();
    path = _preferences.getString("store_path") ??
        (await platform.invokeMethod('get_path')) as String;
    final directory = Directory(path);
    if (!directory.existsSync()) {
      directory.createSync();
    }
    list = ObservableList.of(Directory(path).listSync());
  }
}
