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
    _$modeListAtom.context.enforceReadPolicy(_$modeListAtom);
    _$modeListAtom.reportObserved();
    return super.modeList;
  }

  @override
  set modeList(ObservableList<String> value) {
    _$modeListAtom.context.conditionallyRunInAction(() {
      super.modeList = value;
      _$modeListAtom.reportChanged();
    }, _$modeListAtom, name: '${_$modeListAtom.name}_set');
  }

  final _$modifyUIAtom = Atom(name: '_RankStoreBase.modifyUI');

  @override
  bool get modifyUI {
    _$modifyUIAtom.context.enforceReadPolicy(_$modifyUIAtom);
    _$modifyUIAtom.reportObserved();
    return super.modifyUI;
  }

  @override
  set modifyUI(bool value) {
    _$modifyUIAtom.context.conditionallyRunInAction(() {
      super.modifyUI = value;
      _$modifyUIAtom.reportChanged();
    }, _$modifyUIAtom, name: '${_$modifyUIAtom.name}_set');
  }

  final _$resetAsyncAction = AsyncAction('reset');

  @override
  Future<void> reset() {
    return _$resetAsyncAction.run(() => super.reset());
  }

  final _$initAsyncAction = AsyncAction('init');

  @override
  Future<void> init() {
    return _$initAsyncAction.run(() => super.init());
  }

  final _$saveChangeAsyncAction = AsyncAction('saveChange');

  @override
  Future<void> saveChange(Map<String, bool> selectMap) {
    return _$saveChangeAsyncAction.run(() => super.saveChange(selectMap));
  }

  @override
  String toString() {
    final string =
        'modeList: ${modeList.toString()},modifyUI: ${modifyUI.toString()}';
    return '{$string}';
  }
}
