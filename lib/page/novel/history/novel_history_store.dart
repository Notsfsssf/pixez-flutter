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
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:mobx/mobx.dart';
import 'package:pixez/er/sharer.dart';
import 'package:pixez/models/novel_persist.dart';
import 'package:pixez/models/novel_recom_response.dart';
import 'package:pixez/saf_plugin.dart';

part 'novel_history_store.g.dart';

class NovelHistoryStore = _NovelHistoryStoreBase with _$NovelHistoryStore;

abstract class _NovelHistoryStoreBase with Store {
  NovelPersistProvider novelPersistProvider = NovelPersistProvider();
  ObservableList<NovelPersist> data = ObservableList();

  @action
  fetch() async {
    await novelPersistProvider.open();
    final result = await novelPersistProvider.getAllAccount();
    data.clear();
    data.addAll(result);
  }

  @action
  insert(Novel novel) async {
    await novelPersistProvider.open();
    await novelPersistProvider.insert(NovelPersist(
        time: DateTime.now().millisecondsSinceEpoch,
        userId: novel.user.id,
        title: novel.title,
        userName: novel.user.name,
        pictureUrl: novel.imageUrls.squareMedium,
        novelId: novel.id));
    await fetch();
  }

  @action
  delete(int id) async {
    await novelPersistProvider.open();
    await novelPersistProvider.delete(id);
    await fetch();
  }

  deleteAll() async {
    await novelPersistProvider.open();
    await novelPersistProvider.deleteAll();
    await fetch();
  }

  Future<void> importData() async {
    final result = await SAFPlugin.openFile();
    if (result == null) return;
    final json = utf8.decode(result);
    final decoder = JsonDecoder();
    List<dynamic> maps = decoder.convert(json);
    maps.forEach((illust) {
      var novelMap = Map.from(illust);
      var novelPersist = NovelPersist(
          novelId: novelMap['novel_id'],
          userId: novelMap['user_id'],
          pictureUrl: novelMap['picture_url'],
          time: novelMap['time'],
          title: novelMap['title'],
          userName: novelMap['user_name']);
      novelPersistProvider.insert(novelPersist);
    });
  }

  Future<void> exportData(BuildContext context) async {
    await novelPersistProvider.open();
    final exportData = await novelPersistProvider.getAllAccount();
    final uint8List = utf8.encode(jsonEncode(exportData));
    if (Platform.isIOS) {
      await Sharer.exportUint8List(context, uint8List, "novelpersist.json");
    } else {
      final uriStr =
          await SAFPlugin.createFile("novelpersist.json", "application/json");
      if (uriStr == null) return;
      await SAFPlugin.writeUri(uriStr, uint8List);
    }
  }
}
