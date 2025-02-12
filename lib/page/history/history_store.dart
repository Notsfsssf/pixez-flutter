import 'dart:convert';
import 'dart:io';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:pixez/er/sharer.dart';
import 'package:pixez/models/illust.dart';
import 'package:pixez/models/illust_persist.dart';
import 'package:pixez/saf_plugin.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'history_store.freezed.dart';
part 'history_store.g.dart';

@freezed
class HistoryState with _$HistoryState {
  const factory HistoryState({
    required List<IllustPersist> data,
    required String word,
  }) = _HistoryState;
}

@riverpod
class History extends _$History {
  final illustPersistProvider = IllustPersistProvider();
  @override
  HistoryState build() {
    return HistoryState(data: [], word: "");
  }

  Future<void> fetch() async {
    await illustPersistProvider.open();
    final result = await illustPersistProvider.getAllAccount();
    state = state.copyWith(data: result);
  }

  Future<void> search(String word) async {
    await illustPersistProvider.open();
    final result = await illustPersistProvider.getLikeIllusts(word);
    state = state.copyWith(data: result);
  }

  Future<void> insert(Illusts illust) async {
    await illustPersistProvider.open();
    var illustPersist = IllustPersist(
        illustId: illust.id,
        userId: illust.user.id,
        pictureUrl: illust.imageUrls.squareMedium,
        time: DateTime.now().millisecondsSinceEpoch,
        title: illust.title,
        userName: illust.user.name);
    await illustPersistProvider.insert(illustPersist);
    await fetch();
  }

  static Future<void> insertIllust(Illusts illust) async {
    final illustPersistProvider = IllustPersistProvider();
    await illustPersistProvider.open();
    var illustPersist = IllustPersist(
        illustId: illust.id,
        userId: illust.user.id,
        pictureUrl: illust.imageUrls.squareMedium,
        time: DateTime.now().millisecondsSinceEpoch,
        title: illust.title,
        userName: illust.user.name);
    await illustPersistProvider.insert(illustPersist);
  }

  Future<void> delete(int id) async {
    await illustPersistProvider.open();
    await illustPersistProvider.delete(id);
    await fetch();
  }

  Future<void> deleteAll() async {
    await illustPersistProvider.open();
    await illustPersistProvider.deleteAll();
    await fetch();
  }

  Future<void> importData() async {
    final result = await SAFPlugin.openFile();
    if (result == null) return;
    final json = utf8.decode(result);
    final decoder = JsonDecoder();
    List<dynamic> maps = decoder.convert(json);
    maps.forEach((illust) {
      var illustMap = Map.from(illust);
      var illustPersist = IllustPersist(
          illustId: illustMap['illust_id'],
          userId: illustMap['user_id'],
          pictureUrl: illustMap['picture_url'],
          time: illustMap['time'],
          title: illustMap['title'],
          userName: illustMap['user_name']);
      illustPersistProvider.insert(illustPersist);
    });
  }

  Future<void> exportData(BuildContext context) async {
    await illustPersistProvider.open();
    final exportData = await illustPersistProvider.getAllAccount();
    final uint8List = utf8.encode(jsonEncode(exportData));
    if (Platform.isIOS) {
      await Sharer.exportUint8List(context, uint8List, "illustpersist.json");
    } else {
      final uriStr =
          await SAFPlugin.createFile("illustpersist.json", "application/json");
      if (uriStr == null) return;
      await SAFPlugin.writeUri(uriStr, uint8List);
    }
  }
}
