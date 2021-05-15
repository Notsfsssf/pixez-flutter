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

import 'package:mobx/mobx.dart';
import 'package:pixez/constants.dart';
import 'package:pixez/models/tags.dart';

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
}
