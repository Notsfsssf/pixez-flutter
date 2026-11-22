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

import 'package:dio/dio.dart';
import 'package:easy_refresh/easy_refresh.dart';
import 'package:mobx/mobx.dart';
import 'package:pixez/exts.dart';
import 'package:pixez/lighting/lighting_store.dart';
import 'package:pixez/models/novel_recom_response.dart';
import 'package:pixez/network/api_client.dart';
import 'package:pixez/page/novel/viewer/novel_store.dart';

part 'novel_lighting_store.g.dart';

class NovelLightingStore = _NovelLightingStoreBase with _$NovelLightingStore;

abstract class _NovelLightingStoreBase with Store {
  /// 单次 onRefresh / onLoad 内最多连续取页数，防止屏蔽规则过重时空转。
  static const int _maxRounds = 10;

  /// 期望每次至少凑够的可见小说条数。
  ///
  /// 屏蔽规则较重时，一页 30 条里可能只剩 1~2 条可见。列表高度增长太少，
  /// 用户始终停在距底部 70px 的触发区以内，easy_refresh 的 footer 会一直
  /// 保持在 done("Succeeded") 状态而不再重新触发 onLoad —— 表现出来就是
  /// "上拉转圈但再也不出新小说，下拉刷新也救不回来"。
  /// 因此这里先把屏蔽项过滤掉，再续取若干页，保证列表每次都有足够增长。
  static const int _minVisibleTarget = 8;

  FutureGet source;
  final ApiClient _client = apiClient;
  final EasyRefreshController controller;

  _NovelLightingStoreBase(this.source, this.controller);

  String? nextUrl;
  ObservableList<NovelStore> novels = ObservableList();
  @observable
  String? errorMessage;

  @action
  Future<void> fetch() async {
    nextUrl = null;
    errorMessage = null;
    try {
      Response response = await source();
      NovelRecomResponse novelRecomResponse =
          NovelRecomResponse.fromJson(response.data);
      nextUrl = novelRecomResponse.nextUrl;
      final collected = novelRecomResponse.novels
          .where((element) => !element.hateByUser())
          .toList();
      // 首页可见项太少时同样续取，否则首屏不可滚动，无法触发 onLoad。
      int round = 0;
      while (collected.length < _minVisibleTarget &&
          round < _maxRounds &&
          nextUrl != null &&
          nextUrl!.isNotEmpty) {
        round++;
        try {
          final nextResponse = await _client.getNext(nextUrl!);
          final nextNovelRecomResponse =
              NovelRecomResponse.fromJson(nextResponse.data);
          nextUrl = nextNovelRecomResponse.nextUrl;
          collected.addAll(
              nextNovelRecomResponse.novels.where((e) => !e.hateByUser()));
        } catch (e) {
          break;
        }
      }
      this.novels.clear();
      this.novels.addAll(
          collected.map((element) => NovelStore(element.id, element)));
      controller.finishRefresh(IndicatorResult.success);
    } catch (e) {
      print(e);
      errorMessage = e.toString();
      controller.finishRefresh(IndicatorResult.fail);
    }
  }

  @action
  Future<void> next() async {
    // 累计式加载：一次 onLoad 内持续取页，直到凑够 _minVisibleTarget 条可见小说。
    final collected = <Novel>[];
    int round = 0;
    while (round < _maxRounds && collected.length < _minVisibleTarget) {
      if (nextUrl == null || nextUrl!.isEmpty) break;
      round++;
      try {
        Response response = await _client.getNext(nextUrl!);
        NovelRecomResponse novelRecomResponse =
            NovelRecomResponse.fromJson(response.data);
        nextUrl = novelRecomResponse.nextUrl;
        collected.addAll(
            novelRecomResponse.novels.where((e) => !e.hateByUser()));
      } catch (e) {
        break;
      }
    }
    if (collected.isNotEmpty) {
      novels.addAll(
          collected.map((element) => NovelStore(element.id, element)));
    }
    if (nextUrl == null || nextUrl!.isEmpty) {
      // 已经真的到底了：有多少放多少，并如实告知没有更多。
      controller.finishLoad(IndicatorResult.noMore);
    } else if (collected.isNotEmpty) {
      controller.finishLoad(IndicatorResult.success);
    } else {
      // 连续取满 _maxRounds 轮却一条可见都没有，且后面还有页：判定失败交给用户重试。
      controller.finishLoad(IndicatorResult.fail);
    }
  }
}
