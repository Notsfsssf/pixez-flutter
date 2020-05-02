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

  final _$initAsyncAction = AsyncAction('init');

  @override
  Future<void> init() {
    return _$initAsyncAction.run(() => super.init());
  }

  final _$changeAsyncAction = AsyncAction('change');

  @override
  Future<void> change(int value) {
    return _$changeAsyncAction.run(() => super.change(value));
  }

  @override
  String toString() {
    final string = 'zoomQuality: ${zoomQuality.toString()}';
    return '{$string}';
  }
}
