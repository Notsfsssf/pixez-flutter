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

part of 'splash_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic

mixin _$SplashStore on _SplashStoreBase, Store {
  final _$helloWordAtom = Atom(name: '_SplashStoreBase.helloWord');

  @override
  String get helloWord {
    _$helloWordAtom.reportRead();
    return super.helloWord;
  }

  @override
  set helloWord(String value) {
    _$helloWordAtom.reportWrite(value, super.helloWord, () {
      super.helloWord = value;
    });
  }

  final _$onezeroResponseAtom = Atom(name: '_SplashStoreBase.onezeroResponse');

  @override
  OnezeroResponse get onezeroResponse {
    _$onezeroResponseAtom.reportRead();
    return super.onezeroResponse;
  }

  @override
  set onezeroResponse(OnezeroResponse value) {
    _$onezeroResponseAtom.reportWrite(value, super.onezeroResponse, () {
      super.onezeroResponse = value;
    });
  }

  final _$fetchAsyncAction = AsyncAction('_SplashStoreBase.fetch');

  @override
  Future fetch() {
    return _$fetchAsyncAction.run(() => super.fetch());
  }

  @override
  String toString() {
    return '''
helloWord: ${helloWord},
onezeroResponse: ${onezeroResponse}
    ''';
  }
}
