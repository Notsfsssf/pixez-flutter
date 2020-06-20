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

part of 'lighting_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic

mixin _$LightingStore on _LightingStoreBase, Store {
  final _$illustsAtom = Atom(name: '_LightingStoreBase.illusts');

  @override
  ObservableList<Illusts> get illusts {
    _$illustsAtom.reportRead();
    return super.illusts;
  }

  @override
  set illusts(ObservableList<Illusts> value) {
    _$illustsAtom.reportWrite(value, super.illusts, () {
      super.illusts = value;
    });
  }

  final _$fetchAsyncAction = AsyncAction('_LightingStoreBase.fetch');

  @override
  Future fetch() {
    return _$fetchAsyncAction.run(() => super.fetch());
  }

  final _$fetchNextAsyncAction = AsyncAction('_LightingStoreBase.fetchNext');

  @override
  Future fetchNext() {
    return _$fetchNextAsyncAction.run(() => super.fetchNext());
  }

  @override
  String toString() {
    return '''
illusts: ${illusts}
    ''';
  }
}
