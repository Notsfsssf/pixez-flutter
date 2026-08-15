/*
 * Copyright (C) 2020. by perol_notsf, All rights reserved
 *
 * This program is free software: you can redistribute it and/or modify it under
 * the terms of the GNU General Public License as published by the Free Software
 * Foundation, either version 3 of the License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful, but WITHOUT ANY
 * WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
 * FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License along with
 * this program. If not, see <http://www.gnu.org/licenses/>.
 *
 */

import 'dart:convert';
import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:mobx/mobx.dart';
import 'package:pixez/constants.dart';
import 'package:pixez/er/sharer.dart';
import 'package:pixez/models/export_tag_history_data.dart';
import 'package:pixez/models/tags.dart';
import 'package:pixez/saf_plugin.dart';

part 'tag_history_store.g.dart';

class TagHistoryStore = _TagHistoryStoreBase with _$TagHistoryStore;

abstract class _TagHistoryStoreBase with Store {
  TagsPersistProvider tagsPersistProvider = TagsPersistProvider();
  ObservableList<TagsPersist> tags = ObservableList();

  @action
  fetch() async {
    await tagsPersistProvider.open();
    var result = await tagsPersistProvider.getAllAccount();
    tags.clear();
    tags.addAll(result);
  }

  @action
  insert(TagsPersist tagsPersist) async {
    await tagsPersistProvider.open();
    for (int i = 0; i < tags.length; i++) {
      if (tags[i].name == tagsPersist.name && tags[i].type == Constants.type) {
        await tagsPersistProvider.delete(tags[i].id!);
      }
    }
    tagsPersist.type = Constants.type;
    await tagsPersistProvider.insert(tagsPersist);
    await fetch();
  }

  @action
  delete(int id) async {
    await tagsPersistProvider.open();
    await tagsPersistProvider.delete(id);
    await fetch();
  }

  @action
  deleteAll() async {
    await tagsPersistProvider.open();
    await tagsPersistProvider.deleteAll(type: Constants.type);
    await fetch();
  }

  final EXPORT_TYPE = "history_tags";

  String _tagKey(TagsPersist tag) => '${tag.name}\u0000${tag.type ?? 0}';

  Future<void> importData() async {
    final result = await SAFPlugin.openFile();
    if (result == null) return;
    final json = utf8.decode(result);
    final decoder = JsonDecoder();
    final map = decoder.convert(json);
    final data = ExportData.fromJson(map);
    if (data.tagHisotry == null) return;
    await fetch();
    final existing = tags.map(_tagKey).toSet();
    data.tagHisotry!
        .removeWhere((element) => existing.contains(_tagKey(element)));
    if (data.tagHisotry!.isEmpty) return;
    for (final tag in data.tagHisotry!) {
      tag.id = null;
    }
    await tagsPersistProvider.open();
    await tagsPersistProvider.insertAll(data.tagHisotry!.toList());
    await fetch();
  }

  Future<void> exportData(BuildContext context) async {
    await tagsPersistProvider.open();
    final tagsToExport = await tagsPersistProvider.getAllAccount();
    for (final tag in tagsToExport) {
      tag.id = null;
    }
    final exportData = ExportData(tagHisotry: tagsToExport);
    final uint8List = utf8.encode(jsonEncode(exportData));
    if (Platform.isIOS) {
      await Sharer.exportUint8List(context, uint8List, 'search_history.json');
    } else {
      final uriStr =
          await SAFPlugin.createFile("search_history.json", "application/json");
      if (uriStr == null) return;
      await SAFPlugin.writeUri(uriStr, uint8List);
    }
  }
}
