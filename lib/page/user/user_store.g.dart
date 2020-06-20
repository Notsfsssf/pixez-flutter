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

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic

mixin _$UserStore on _UserStoreBase, Store {
  final _$userDetailAtom = Atom(name: '_UserStoreBase.userDetail');

  @override
  UserDetail get userDetail {
    _$userDetailAtom.reportRead();
    return super.userDetail;
  }

  @override
  set userDetail(UserDetail value) {
    _$userDetailAtom.reportWrite(value, super.userDetail, () {
      super.userDetail = value;
    });
  }

  final _$isFollowAtom = Atom(name: '_UserStoreBase.isFollow');

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

  final _$valueAtom = Atom(name: '_UserStoreBase.value');

  @override
  int get value {
    _$valueAtom.reportRead();
    return super.value;
  }

  @override
  set value(int value) {
    _$valueAtom.reportWrite(value, super.value, () {
      super.value = value;
    });
  }

  final _$errorMessageAtom = Atom(name: '_UserStoreBase.errorMessage');

  @override
  String get errorMessage {
    _$errorMessageAtom.reportRead();
    return super.errorMessage;
  }

  @override
  set errorMessage(String value) {
    _$errorMessageAtom.reportWrite(value, super.errorMessage, () {
      super.errorMessage = value;
    });
  }

  final _$followAsyncAction = AsyncAction('_UserStoreBase.follow');

  @override
  Future<void> follow({bool needPrivate = false}) {
    return _$followAsyncAction
        .run(() => super.follow(needPrivate: needPrivate));
  }

  final _$firstFetchAsyncAction = AsyncAction('_UserStoreBase.firstFetch');

  @override
  Future<void> firstFetch() {
    return _$firstFetchAsyncAction.run(() => super.firstFetch());
  }

  @override
  String toString() {
    return '''
userDetail: ${userDetail},
isFollow: ${isFollow},
value: ${value},
errorMessage: ${errorMessage}
    ''';
  }
}
