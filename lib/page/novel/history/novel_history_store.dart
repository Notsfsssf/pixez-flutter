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
import 'package:mobx/mobx.dart';
import 'package:pixez/models/novel_persist.dart';
import 'package:pixez/models/novel_recom_response.dart';

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
        novelId: novel.id,
        id: 0));
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
}
