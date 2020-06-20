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
import 'package:pixez/models/illust.dart';
import 'package:pixez/models/recommend.dart';
import 'package:pixez/network/api_client.dart';

part 'rank_mode_store.g.dart';

class RankModeStore = _RankModeStoreBase with _$RankModeStore;

abstract class _RankModeStoreBase with Store {
  final ApiClient client;
  final String mode, date;
  _RankModeStoreBase(this.mode, this.date, this.client);

  @observable
  ObservableList<Illusts> illusts =ObservableList();
  @action
  Future<void> start() async {
    try {
      final response = await client.getIllustRanking(mode, date);
      Recommend recommend = Recommend.fromJson(response.data);
      illusts.addAll(recommend.illusts);
    } catch (e) {
    }
  }
}
