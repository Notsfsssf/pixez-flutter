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
  FutureGet source;
  final ApiClient _client = apiClient;
  final EasyRefreshController controller;

  _NovelLightingStoreBase(this.source, this.controller);

  String? nextUrl;
  ObservableList<NovelStore> novels = ObservableList();
  @observable
  String? errorMessage;

  /// 单次 onRefresh / onLoad 内至少收集这么多条“可见（未被屏蔽）”小说再交给列表。
  ///
  /// 原因：easy_refresh 的 ClassicFooter 只有在用户离开底部一定距离
  /// （默认 infiniteOffset 70px）之后，才会把 footer 从 done 态重新置回可触发状态。
  /// 当屏蔽规则较重时，单页返回的小说大部分会被过滤掉，若本次只新增 1~3 条，
  /// 列表增长不足以把用户推出触发区，footer 会一直停在 done（显示 Succeeded），
  /// 表现为“继续上滑不再加载、下拉刷新也恢复不了”。
  /// 一次多取几页凑够目标条数，可以保证每次加载都让列表有足够增长。
  static const int _minVisibleTarget = 8;

  /// 单次 onRefresh / onLoad 内最多连续取页数，避免屏蔽规则过重时长时间空转。
  static const int _maxRounds = 10;

  @action
  Future<void> fetch() async {
    nextUrl = null;
    errorMessage = null;
    try {
      Response response = await source();
      NovelRecomResponse novelRecomResponse =
          NovelRecomResponse.fromJson(response.data);
      nextUrl = novelRecomResponse.nextUrl;

      // 过滤放在 store 层：进入列表的都是可见项，
      // 页面层不再需要（也不应该）在 build 里对 ObservableList 做 removeWhere。
      final collected = novelRecomResponse.novels
          .where((element) => !element.hateByUser())
          .toList();

      // 首屏可见项不足时继续向后取页，保证首屏就有足够内容可滚动。
      int round = 0;
      while (collected.length < _minVisibleTarget &&
          round < _maxRounds &&
          nextUrl != null &&
          nextUrl!.isNotEmpty) {
        round++;
        try {
          final Response nextResponse = await _client.getNext(nextUrl!);
          final NovelRecomResponse nextPayload =
              NovelRecomResponse.fromJson(nextResponse.data);
          nextUrl = nextPayload.nextUrl;
          collected.addAll(nextPayload.novels
              .where((element) => !element.hateByUser())
              .toList());
        } catch (e) {
          // 续取失败不视为整体失败：已收集到的内容照常展示。
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
    final collected = <Novel>[];
    int round = 0;
    while (round < _maxRounds && collected.length < _minVisibleTarget) {
      if (nextUrl == null || nextUrl!.isEmpty) break;
      round++;
      try {
        final Response response = await _client.getNext(nextUrl!);
        final NovelRecomResponse novelRecomResponse =
            NovelRecomResponse.fromJson(response.data);
        nextUrl = novelRecomResponse.nextUrl;
        collected.addAll(novelRecomResponse.novels
            .where((element) => !element.hateByUser())
            .toList());
      } catch (e) {
        break;
      }
    }

    if (collected.isNotEmpty) {
      novels.addAll(
          collected.map((element) => NovelStore(element.id, element)));
    }

    if (nextUrl == null || nextUrl!.isEmpty) {
      // 已经到底：有内容也一并展示，同时如实告知没有更多。
      controller.finishLoad(IndicatorResult.noMore);
    } else if (collected.isNotEmpty) {
      controller.finishLoad(IndicatorResult.success);
    } else {
      // 连续取页仍无可见项且后面还有内容，判定失败，交由用户重试。
      controller.finishLoad(IndicatorResult.fail);
    }
  }
}
