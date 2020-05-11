// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'save_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic

mixin _$SaveStore on _SaveStoreBase, Store {
  final _$progressMapsAtom = Atom(name: '_SaveStoreBase.progressMaps');

  @override
  ObservableMap<String, ProgressNum> get progressMaps {
    _$progressMapsAtom.context.enforceReadPolicy(_$progressMapsAtom);
    _$progressMapsAtom.reportObserved();
    return super.progressMaps;
  }

  @override
  set progressMaps(ObservableMap<String, ProgressNum> value) {
    _$progressMapsAtom.context.conditionallyRunInAction(() {
      super.progressMaps = value;
      _$progressMapsAtom.reportChanged();
    }, _$progressMapsAtom, name: '${_$progressMapsAtom.name}_set');
  }

  final _$saveImageAsyncAction = AsyncAction('saveImage');

  @override
  Future<void> saveImage(Illusts illusts, {int index}) {
    return _$saveImageAsyncAction
        .run(() => super.saveImage(illusts, index: index));
  }

  final _$_SaveStoreBaseActionController =
      ActionController(name: '_SaveStoreBase');

  @override
  void initContext(I18n context) {
    final _$actionInfo = _$_SaveStoreBaseActionController.startAction();
    try {
      return super.initContext(context);
    } finally {
      _$_SaveStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void saveChoiceImage(Illusts illusts, List<bool> indexs) {
    final _$actionInfo = _$_SaveStoreBaseActionController.startAction();
    try {
      return super.saveChoiceImage(illusts, indexs);
    } finally {
      _$_SaveStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    final string = 'progressMaps: ${progressMaps.toString()}';
    return '{$string}';
  }
}
