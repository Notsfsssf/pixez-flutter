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

part of 'rank_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic

mixin _$RankStore on _RankStoreBase, Store {
  final _$modeListAtom = Atom(name: '_RankStoreBase.modeList');

  @override
  ObservableList<String> get modeList {
    _$modeListAtom.reportRead();
    return super.modeList;
  }

  @override
  set modeList(ObservableList<String> value) {
    _$modeListAtom.reportWrite(value, super.modeList, () {
      super.modeList = value;
    });
  }

  final _$modifyUIAtom = Atom(name: '_RankStoreBase.modifyUI');

  @override
  bool get modifyUI {
    _$modifyUIAtom.reportRead();
    return super.modifyUI;
  }

  @override
  set modifyUI(bool value) {
    _$modifyUIAtom.reportWrite(value, super.modifyUI, () {
      super.modifyUI = value;
    });
  }

  final _$resetAsyncAction = AsyncAction('_RankStoreBase.reset');

  @override
  Future<void> reset() {
    return _$resetAsyncAction.run(() => super.reset());
  }

  final _$initAsyncAction = AsyncAction('_RankStoreBase.init');

  @override
  Future<void> init() {
    return _$initAsyncAction.run(() => super.init());
  }

  final _$saveChangeAsyncAction = AsyncAction('_RankStoreBase.saveChange');

  @override
  Future<void> saveChange(Map<int, bool> selectMap) {
    return _$saveChangeAsyncAction.run(() => super.saveChange(selectMap));
  }

  @override
  String toString() {
    return '''
modeList: ${modeList},
modifyUI: ${modifyUI}
    ''';
  }
}
