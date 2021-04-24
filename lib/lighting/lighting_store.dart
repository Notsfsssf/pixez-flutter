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

import 'package:dio/dio.dart';
import 'package:mobx/mobx.dart';
import 'package:pixez/main.dart';
import 'package:pixez/models/illust.dart';
import 'package:pixez/models/recommend.dart';
import 'package:pixez/network/api_client.dart';
import 'package:pixez/page/picture/illust_store.dart';
import 'package:pixez/widgetkit_plugin.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

part 'lighting_store.g.dart';

class LightingStore = _LightingStoreBase with _$LightingStore;

typedef Future<Response> FutureGet();

abstract class _LightingStoreBase with Store {
  FutureGet source;
  String? nextUrl;
  RefreshController? controller;
  final Function? onChange;
  @observable
  ObservableList<IllustStore> iStores = ObservableList();

  dispose() {
    // iStores.forEach((element) {
    //   final provider = ExtendedNetworkImageProvider(
    //     element.illusts.imageUrls.medium,
    //   );
    //   provider.evict();
    // });
    // iStores.clear();
  }

  @observable
  String? errorMessage;

  _LightingStoreBase(this.source, this.controller, {this.onChange});

  bool okForUser(Illusts illust) {
    // if (userSetting.hIsNotAllow)
    //   for (int i = 0; i < illust.tags.length; i++)
    //     if (illust.tags[i].name.startsWith('R-18')) return false;
    for (var t in muteStore.banTags) {
      for (var f in illust.tags) {
        if (f.name == t.name) return false;
      }
    }
    for (var j in muteStore.banUserIds) {
      if (j.userId == illust.user.id.toString()) {
        return false;
      }
    }
    for (var i in muteStore.banillusts)
      if (illust.id == i.id) {
        return false;
      }
    return true;
  }

  @action
  Future<bool> fetch({String? url}) async {
    nextUrl = null;
    errorMessage = null;
    controller?.footerMode.value = LoadStatus.idle;
    controller?.headerMode.value = RefreshStatus.refreshing;
    try {
      final result = await source();
      Recommend recommend = Recommend.fromJson(result.data);
      nextUrl = recommend.nextUrl;
      iStores.clear();
      iStores.addAll(recommend.illusts.map((e) => IllustStore(e.id, e)));
      if (userSetting.prefs.getString("app_widget_data") == null) {
        if (url == null || !url.contains("walkthrough"))
          await userSetting.prefs
              .setString("app_widget_data", jsonEncode(recommend));
        else {
          bool condition =
              userSetting.prefs.getBool("walkthrough_data_init") ?? false;
          if (!condition) {
            await userSetting.prefs
                .setString("app_widget_data", jsonEncode(recommend));
            await userSetting.prefs.setBool("walkthrough_data_init", true);
          }
        }
        WidgetkitPlugin.notify();
      }
      controller?.refreshCompleted();
      return true;
    } catch (e) {
      errorMessage = e.toString();
      controller?.refreshFailed();
      return false;
    }
  }

  @action
  update(FutureGet futureGet) async {
    source = futureGet;
    await fetch();
  }

  @action
  Future<bool> fetchNext() async {
    errorMessage = null;
    try {
      if (nextUrl != null && nextUrl!.isNotEmpty) {
        Response result = await apiClient.getNext(nextUrl!);
        Recommend recommend = Recommend.fromJson(result.data);
        nextUrl = recommend.nextUrl;
        iStores.addAll(recommend.illusts.map((e) => IllustStore(e.id, e)));
        controller?.loadComplete();
      } else {
        controller?.loadNoData();
      }
      return true;
    } catch (e) {
      controller?.loadFailed();
      return false;
    }
  }
}
