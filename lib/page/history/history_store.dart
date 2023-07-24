import 'dart:convert';
import 'dart:typed_data';

import 'package:mobx/mobx.dart';
import 'package:pixez/models/illust.dart';
import 'package:pixez/models/illust_persist.dart';
import 'package:pixez/saf_plugin.dart';

part 'history_store.g.dart';

class HistoryStore = _HistoryStoreBase with _$HistoryStore;

abstract class _HistoryStoreBase with Store {
  IllustPersistProvider illustPersistProvider = IllustPersistProvider();
  ObservableList<IllustPersist> data = ObservableList();
  @observable
  var word = "";

  @action
  fetch() async {
    await illustPersistProvider.open();
    final result = await illustPersistProvider.getAllAccount();
    data.clear();
    data.addAll(result);
  }

  @action
  search(String word) async {
    await illustPersistProvider.open();
    final result = await illustPersistProvider.getLikeIllusts(word);
    data.clear();
    data.addAll(result);
  }

  @action
  insert(Illusts illust) async {
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

  @action
  delete(int id) async {
    await illustPersistProvider.open();
    await illustPersistProvider.delete(id);
    await fetch();
  }

  deleteAll() async {
    await illustPersistProvider.open();
    await illustPersistProvider.deleteAll();
    await fetch();
  }

  importData() async {
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
  exportData() async {
    final uriStr =
        await SAFPlugin.createFile("illustpersist.json", "application/json");
    if (uriStr == null) return;
    await illustPersistProvider.open();
    final exportData = await illustPersistProvider.getAllAccount();
    await SAFPlugin.writeUri(uriStr,
        Uint8List.fromList(utf8.encode(jsonEncode(exportData))));
  }
}
