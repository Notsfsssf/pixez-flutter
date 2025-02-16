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

import 'package:fluent_ui/fluent_ui.dart';
import 'package:mobx/mobx.dart';
import 'package:pixez/er/lprinter.dart';
import 'package:pixez/er/prefer.dart';
import 'package:pixez/er/sharer.dart';
import 'package:pixez/models/ban_comment_persist.dart';
import 'package:pixez/models/ban_illust_id.dart';
import 'package:pixez/models/ban_tag.dart';
import 'package:pixez/models/ban_user_id.dart';
import 'package:pixez/models/comment_response.dart';
import 'package:pixez/saf_plugin.dart';

part 'mute_store.g.dart';

class MuteStore = _MuteStoreBase with _$MuteStore;

abstract class _MuteStoreBase with Store {
  BanIllustIdProvider banIllustIdProvider = BanIllustIdProvider();
  BanUserIdProvider banUserIdProvider = BanUserIdProvider();
  BanCommenProvider banCommentPersistProvider = BanCommenProvider();
  BanTagProvider banTagProvider = BanTagProvider();
  ObservableList<BanUserIdPersist> banUserIds = ObservableList();
  ObservableList<BanTagPersist> banTags = ObservableList();
  ObservableList<BanIllustIdPersist> banillusts = ObservableList();
  ObservableList<BanCommentPersist> banComments = ObservableList();

  @observable
  bool banAIIllust = false;

  _MuteStoreBase() {}

  @action
  Future<void> changeBanAI(bool value) async {
    await Prefer.setBool("ban_ai_illust", value);
    banAIIllust = value;
  }

  @action
  Future<void> fetchBanAI() async {
    final result = Prefer.getBool("ban_ai_illust") ?? false;
    banAIIllust = result;
  }

  @action
  Future<void> fetchBanUserIds() async {
    await banUserIdProvider.open();
    List<BanUserIdPersist> userids = await banUserIdProvider.getAllAccount();
    banUserIds.clear();
    banUserIds.addAll(userids);
  }

  @action
  Future<void> fetchBanComments() async {
    await banCommentPersistProvider.open();
    List<BanCommentPersist> userids =
        await banCommentPersistProvider.getAllAccount();
    banComments.clear();
    banComments.addAll(userids);
  }

  @action
  Future<void> insertBanUserId(String id, String name) async {
    await banUserIdProvider.open();
    await banUserIdProvider.insert(BanUserIdPersist()
      ..userId = id
      ..name = name);
    await fetchBanUserIds();
  }

  @action
  Future<void> deleteBanUserId(int id) async {
    await banUserIdProvider.open();
    await banUserIdProvider.delete(id);
    await fetchBanUserIds();
  }

  @action
  fetchBanTags() async {
    await banTagProvider.open();
    var results = await banTagProvider.getAllAccount();
    banTags.clear();
    banTags.addAll(results);
  }

  @action
  insertBanTag(BanTagPersist banTagsPersist) async {
    await banTagProvider.open();
    await banTagProvider.insert(banTagsPersist);
    await fetchBanTags();
  }

  @action
  insertComment(Comment comment) async {
    await banCommentPersistProvider.open();
    await banCommentPersistProvider.insert(BanCommentPersist(
        commentId: comment.id?.toString() ?? "",
        name: comment.user?.name ?? ""));
    await fetchBanComments();
  }

  @action
  deleteBanTag(int id) async {
    await banTagProvider.open();
    await banTagProvider.delete(id);
    await fetchBanTags();
  }

  @action
  fetchBanIllusts() async {
    await banIllustIdProvider.open();
    var results = await banIllustIdProvider.getAllAccount();
    banillusts.clear();
    banillusts.addAll(results);
  }

  @action
  insertBanIllusts(BanIllustIdPersist banIllustIdPersist) async {
    await banIllustIdProvider.open();
    await banIllustIdProvider.insert(banIllustIdPersist);
    await fetchBanIllusts();
  }

  @action
  deleteBanIllusts(int id) async {
    await banIllustIdProvider.open();
    await banIllustIdProvider.delete(id);
    await fetchBanIllusts();
  }

  export(BuildContext context) async {
    await banUserIdProvider.open();
    await banIllustIdProvider.open();
    await banTagProvider.open();
    final banIllust = await banIllustIdProvider.getAllAccount();
    final banUser = await banUserIdProvider.getAllAccount();
    final banTag = await banTagProvider.getAllAccount();
    var entity = {
      "banillustid": banIllust,
      "banuserid": banUser,
      "bantag": banTag
    };
    final exportJson = jsonEncode(entity);
    final uint8List = utf8.encode(exportJson);
    if (Platform.isIOS) {
      await Sharer.exportUint8List(context, uint8List,
          "pixez_mute_${DateTime.now().toIso8601String()}.json");
    } else {
      final uri = await SAFPlugin.createFile(
          "pixez_mute_${DateTime.now().toIso8601String()}.json",
          "application/json");
      LPrinter.d("exportJson:$exportJson");
      if (uri != null) {
        await SAFPlugin.writeUri(uri, uint8List);
      }
    }
  }

  importFile() async {
    final uri = await SAFPlugin.openFile();
    if (uri != null) {
      final data = utf8.decode(uri);
      final entity = jsonDecode(data);
      final banIllust = entity["banillustid"];
      final banUser = entity["banuserid"];
      final banTag = entity["bantag"];
      await banIllustIdProvider.open();
      await banUserIdProvider.open();
      await banTagProvider.open();
      if (banIllust is List) {
        await banIllustIdProvider.insertAll(
            banIllust.map((e) => BanIllustIdPersist.fromJson(e)).toList());
      }
      if (banUser is List) {
        await banUserIdProvider.insertAll(
            banUser.map((e) => BanUserIdPersist.fromJson(e)).toList());
      }
      if (banTag is List) {
        await banTagProvider
            .insertAll(banTag.map((e) => BanTagPersist.fromJson(e)).toList());
      }
      await fetchBanIllusts();
      await fetchBanUserIds();
      await fetchBanTags();
    }
  }
}
