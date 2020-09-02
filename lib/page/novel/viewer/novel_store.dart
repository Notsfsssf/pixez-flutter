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
import 'package:pixez/models/novel_text_response.dart';
import 'package:pixez/network/api_client.dart';

part 'novel_store.g.dart';

class NovelStore = _NovelStoreBase with _$NovelStore;

abstract class _NovelStoreBase with Store {
  final int id;

  _NovelStoreBase(this.id);

  @observable
  NovelTextResponse novelTextResponse;
  @observable
  String errorMessage;

  @action
  fetch() async {
    errorMessage = null;
    try {
      var response = await apiClient.getNovelText(id);
      novelTextResponse = NovelTextResponse.fromJson(response.data);
    } catch (e) {
      print(e);
      errorMessage = e.toString();
    }
  }
}
