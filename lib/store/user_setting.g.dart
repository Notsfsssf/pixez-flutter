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
    _$zoomQualityAtom.context.enforceReadPolicy(_$zoomQualityAtom);
    _$zoomQualityAtom.reportObserved();
    return super.zoomQuality;
  }

  @override
  set zoomQuality(int value) {
    _$zoomQualityAtom.context.conditionallyRunInAction(() {
      super.zoomQuality = value;
      _$zoomQualityAtom.reportChanged();
    }, _$zoomQualityAtom, name: '${_$zoomQualityAtom.name}_set');
  }

  final _$languageNumAtom = Atom(name: '_UserSettingBase.languageNum');

  @override
  int get languageNum {
    _$languageNumAtom.context.enforceReadPolicy(_$languageNumAtom);
    _$languageNumAtom.reportObserved();
    return super.languageNum;
  }

  @override
  set languageNum(int value) {
    _$languageNumAtom.context.conditionallyRunInAction(() {
      super.languageNum = value;
      _$languageNumAtom.reportChanged();
    }, _$languageNumAtom, name: '${_$languageNumAtom.name}_set');
  }

  final _$pathAtom = Atom(name: '_UserSettingBase.path');

  @override
  String get path {
    _$pathAtom.context.enforceReadPolicy(_$pathAtom);
    _$pathAtom.reportObserved();
    return super.path;
  }

  @override
  set path(String value) {
    _$pathAtom.context.conditionallyRunInAction(() {
      super.path = value;
      _$pathAtom.reportChanged();
    }, _$pathAtom, name: '${_$pathAtom.name}_set');
  }

  final _$formatAtom = Atom(name: '_UserSettingBase.format');

  @override
  String get format {
    _$formatAtom.context.enforceReadPolicy(_$formatAtom);
    _$formatAtom.reportObserved();
    return super.format;
  }

  @override
  set format(String value) {
    _$formatAtom.context.conditionallyRunInAction(() {
      super.format = value;
      _$formatAtom.reportChanged();
    }, _$formatAtom, name: '${_$formatAtom.name}_set');
  }

  final _$initAsyncAction = AsyncAction('init');

  @override
  Future<void> init() {
    return _$initAsyncAction.run(() => super.init());
  }

  final _$getPathAsyncAction = AsyncAction('getPath');

  @override
  Future<String> getPath() {
    return _$getPathAsyncAction.run(() => super.getPath());
  }

  final _$setLanguageNumAsyncAction = AsyncAction('setLanguageNum');

  @override
  Future setLanguageNum(int value) {
    return _$setLanguageNumAsyncAction.run(() => super.setLanguageNum(value));
  }

  final _$setFormatAsyncAction = AsyncAction('setFormat');

  @override
  Future setFormat(String format) {
    return _$setFormatAsyncAction.run(() => super.setFormat(format));
  }

  final _$changeAsyncAction = AsyncAction('change');

  @override
  Future<void> change(int value) {
    return _$changeAsyncAction.run(() => super.change(value));
  }

  final _$_UserSettingBaseActionController =
      ActionController(name: '_UserSettingBase');

  @override
  dynamic setPath(dynamic result) {
    final _$actionInfo = _$_UserSettingBaseActionController.startAction();
    try {
      return super.setPath(result);
    } finally {
      _$_UserSettingBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    final string =
        'zoomQuality: ${zoomQuality.toString()},languageNum: ${languageNum.toString()},path: ${path.toString()},format: ${format.toString()}';
    return '{$string}';
  }
}
