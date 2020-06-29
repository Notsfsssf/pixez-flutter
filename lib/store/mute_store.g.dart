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

  @override
  String toString() {
    return '''

    ''';
  }
}
