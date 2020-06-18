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
