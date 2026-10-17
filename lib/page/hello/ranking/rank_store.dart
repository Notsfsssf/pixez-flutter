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
import 'package:pixez/er/prefer.dart';

part 'rank_store.g.dart';

class RankStore = _RankStoreBase with _$RankStore;

abstract class _RankStoreBase with Store {
  static const MODE_LIST = 'mode_list';

  @observable
  ObservableMap<String, bool> filterState = ObservableMap<String, bool>();

  bool _loaded = false;

  _RankStoreBase() {
    reaction((_) => Map<String, bool>.of(filterState), (_) => _save());
    _init();
  }

  Future<void> _init() async {
    final list = Prefer.getStringList(MODE_LIST) ?? [];
    filterState
      ..clear()
      ..addEntries(list.map((mode) => MapEntry(mode, true)));
    _loaded = true;
  }

  Future<void> _save() async {
    if (!_loaded) return;
    final saveList = filterState.entries
        .where((entry) => entry.value)
        .map((entry) => entry.key)
        .toList();
    await Prefer.setStringList(MODE_LIST, saveList);
  }
}