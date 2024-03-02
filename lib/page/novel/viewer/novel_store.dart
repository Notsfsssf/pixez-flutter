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

import 'package:html/parser.dart';
import 'package:dio/dio.dart';
import 'package:mobx/mobx.dart';
import 'package:pixez/er/lprinter.dart';
import 'package:pixez/main.dart';
import 'package:pixez/models/novel_recom_response.dart';
import 'package:pixez/models/novel_text_response.dart';
import 'package:pixez/models/novel_viewer_persist.dart';
import 'package:pixez/models/novel_web_response.dart';
import 'package:pixez/network/api_client.dart';

part 'novel_store.g.dart';

class NovelStore = _NovelStoreBase with _$NovelStore;

abstract class _NovelStoreBase with Store {
  final int id;

  _NovelStoreBase(this.id, this.novel);

  @observable
  Novel? novel;
  @observable
  NovelWebResponse? novelTextResponse;
  @observable
  String? errorMessage;
  @observable
  bool positionBooked = false;

  @observable
  double bookedOffset = 0.0;

  NovelViewerPersistProvider _novelViewerPersistProvider =
      NovelViewerPersistProvider();

  @action
  bookPosition(double offset) async {
    LPrinter.d("bookPosition $offset");
    await _novelViewerPersistProvider.open();
    await _novelViewerPersistProvider
        .insert(NovelViewerPersist(novelId: id, offset: offset));
    positionBooked = true;
  }

  @action
  deleteBookPosition() async {
    LPrinter.d("deleteBookPosition");
    await _novelViewerPersistProvider.open();
    await _novelViewerPersistProvider.delete(id);
    positionBooked = false;
  }

  @action
  fetch() async {
    errorMessage = null;
    try {
      bookedOffset = 0.0;
      final response = await apiClient.webviewNovel(id);
      String json = _parseHtml(response.data)!;
      novelTextResponse = NovelWebResponse.fromJson(jsonDecode(json));
      if (novel == null) {
        Response response = await apiClient.getNovelDetail(id);
        novel = Novel.fromJson(response.data['novel']);
      }
      novelHistoryStore.insert(novel!);
      fetchOffset();
    } catch (e) {
      print(e);
      errorMessage = e.toString();
    }
  }

  String? _parseHtml(String html) {
    var document = parse(html);
    final scriptElement = document.querySelector('script')!;
    String scriptContent = scriptElement.innerHtml;

    final novelStart = 'novel: ';
    final startIndex = scriptContent.indexOf(novelStart) + novelStart.length;
    final stack = <int>[];
    for (var i = startIndex; i < scriptContent.length; i++) {
      if (scriptContent[i] == '{') {
        stack.add(i);
      } else if (scriptContent[i] == '}') {
        stack.removeLast();
        if (stack.isEmpty) {
          return scriptContent.substring(startIndex, i + 1);
        }
      }
    }
    return null;
  }

  @action
  fetchOffset() async {
    try {
      await _novelViewerPersistProvider.open();
      final result = await _novelViewerPersistProvider.getNovelPersistById(id);
      if (result != null) {
        LPrinter.d("fetchOffset ${result.offset}");
        positionBooked = true;
        bookedOffset = result.offset;
      }
    } catch (e) {}
  }
}
