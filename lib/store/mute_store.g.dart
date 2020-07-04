// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'mute_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic

mixin _$MuteStore on _MuteStoreBase, Store {
  final _$fetchBanUserIdsAsyncAction =
      AsyncAction('_MuteStoreBase.fetchBanUserIds');

  @override
  Future<void> fetchBanUserIds() {
    return _$fetchBanUserIdsAsyncAction.run(() => super.fetchBanUserIds());
  }

  final _$insertBanUserIdAsyncAction =
      AsyncAction('_MuteStoreBase.insertBanUserId');

  @override
  Future<void> insertBanUserId(String id, String name) {
    return _$insertBanUserIdAsyncAction
        .run(() => super.insertBanUserId(id, name));
  }

  final _$deleteBanUserIdAsyncAction =
      AsyncAction('_MuteStoreBase.deleteBanUserId');

  @override
  Future<void> deleteBanUserId(int id) {
    return _$deleteBanUserIdAsyncAction.run(() => super.deleteBanUserId(id));
  }

  final _$fetchBanTagsAsyncAction = AsyncAction('_MuteStoreBase.fetchBanTags');

  @override
  Future fetchBanTags() {
    return _$fetchBanTagsAsyncAction.run(() => super.fetchBanTags());
  }

  final _$insertBanTagAsyncAction = AsyncAction('_MuteStoreBase.insertBanTag');

  @override
  Future insertBanTag(BanTagPersist banTagsPersist) {
    return _$insertBanTagAsyncAction
        .run(() => super.insertBanTag(banTagsPersist));
  }

  final _$deleteBanTagAsyncAction = AsyncAction('_MuteStoreBase.deleteBanTag');

  @override
  Future deleteBanTag(int id) {
    return _$deleteBanTagAsyncAction.run(() => super.deleteBanTag(id));
  }

  final _$fetchBanIllustsAsyncAction =
      AsyncAction('_MuteStoreBase.fetchBanIllusts');

  @override
  Future fetchBanIllusts() {
    return _$fetchBanIllustsAsyncAction.run(() => super.fetchBanIllusts());
  }

  final _$insertBanIllustsAsyncAction =
      AsyncAction('_MuteStoreBase.insertBanIllusts');

  @override
  Future insertBanIllusts(BanIllustIdPersist banIllustIdPersist) {
    return _$insertBanIllustsAsyncAction
        .run(() => super.insertBanIllusts(banIllustIdPersist));
  }

  final _$deleteBanIllustsAsyncAction =
      AsyncAction('_MuteStoreBase.deleteBanIllusts');

  @override
  Future deleteBanIllusts(int id) {
    return _$deleteBanIllustsAsyncAction.run(() => super.deleteBanIllusts(id));
  }

  @override
  String toString() {
    return '''

    ''';
  }
}
