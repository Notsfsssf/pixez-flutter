// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'illust_detail_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic

mixin _$IllustDetailStore on _IllustDetailStoreBase, Store {
  final _$isFollowAtom = Atom(name: '_IllustDetailStoreBase.isFollow');

  @override
  bool get isFollow {
    _$isFollowAtom.reportRead();
    return super.isFollow;
  }

  @override
  set isFollow(bool value) {
    _$isFollowAtom.reportWrite(value, super.isFollow, () {
      super.isFollow = value;
    });
  }

  final _$followUserAsyncAction =
      AsyncAction('_IllustDetailStoreBase.followUser');

  @override
  Future followUser() {
    return _$followUserAsyncAction.run(() => super.followUser());
  }

  @override
  String toString() {
    return '''
isFollow: ${isFollow}
    ''';
  }
}
