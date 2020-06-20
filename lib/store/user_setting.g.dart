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

part of 'user_setting.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic

mixin _$UserSetting on _UserSettingBase, Store {
  final _$zoomQualityAtom = Atom(name: '_UserSettingBase.zoomQuality');

  @override
  int get zoomQuality {
    _$zoomQualityAtom.reportRead();
    return super.zoomQuality;
  }

  @override
  set zoomQuality(int value) {
    _$zoomQualityAtom.reportWrite(value, super.zoomQuality, () {
      super.zoomQuality = value;
    });
  }

  final _$languageNumAtom = Atom(name: '_UserSettingBase.languageNum');

  @override
  int get languageNum {
    _$languageNumAtom.reportRead();
    return super.languageNum;
  }

  @override
  set languageNum(int value) {
    _$languageNumAtom.reportWrite(value, super.languageNum, () {
      super.languageNum = value;
    });
  }

  final _$singleFolderAtom = Atom(name: '_UserSettingBase.singleFolder');

  @override
  bool get singleFolder {
    _$singleFolderAtom.reportRead();
    return super.singleFolder;
  }

  @override
  set singleFolder(bool value) {
    _$singleFolderAtom.reportWrite(value, super.singleFolder, () {
      super.singleFolder = value;
    });
  }

  final _$pathAtom = Atom(name: '_UserSettingBase.path');

  @override
  String get path {
    _$pathAtom.reportRead();
    return super.path;
  }

  @override
  set path(String value) {
    _$pathAtom.reportWrite(value, super.path, () {
      super.path = value;
    });
  }

  final _$formatAtom = Atom(name: '_UserSettingBase.format');

  @override
  String get format {
    _$formatAtom.reportRead();
    return super.format;
  }

  @override
  set format(String value) {
    _$formatAtom.reportWrite(value, super.format, () {
      super.format = value;
    });
  }

  final _$initAsyncAction = AsyncAction('_UserSettingBase.init');

  @override
  Future<void> init() {
    return _$initAsyncAction.run(() => super.init());
  }

  final _$setSingleFolderAsyncAction =
      AsyncAction('_UserSettingBase.setSingleFolder');

  @override
  Future<void> setSingleFolder(bool value) {
    return _$setSingleFolderAsyncAction.run(() => super.setSingleFolder(value));
  }

  final _$getPathAsyncAction = AsyncAction('_UserSettingBase.getPath');

  @override
  Future<String> getPath() {
    return _$getPathAsyncAction.run(() => super.getPath());
  }

  final _$setLanguageNumAsyncAction =
      AsyncAction('_UserSettingBase.setLanguageNum');

  @override
  Future setLanguageNum(int value) {
    return _$setLanguageNumAsyncAction.run(() => super.setLanguageNum(value));
  }

  final _$setFormatAsyncAction = AsyncAction('_UserSettingBase.setFormat');

  @override
  Future setFormat(String format) {
    return _$setFormatAsyncAction.run(() => super.setFormat(format));
  }

  final _$changeAsyncAction = AsyncAction('_UserSettingBase.change');

  @override
  Future<void> change(int value) {
    return _$changeAsyncAction.run(() => super.change(value));
  }

  final _$_UserSettingBaseActionController =
      ActionController(name: '_UserSettingBase');

  @override
  dynamic setPath(dynamic result) {
    final _$actionInfo = _$_UserSettingBaseActionController.startAction(
        name: '_UserSettingBase.setPath');
    try {
      return super.setPath(result);
    } finally {
      _$_UserSettingBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
zoomQuality: ${zoomQuality},
languageNum: ${languageNum},
singleFolder: ${singleFolder},
path: ${path},
format: ${format}
    ''';
  }
}
