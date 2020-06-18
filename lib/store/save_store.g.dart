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
    _$progressMapsAtom.reportRead();
    return super.progressMaps;
  }

  @override
  set progressMaps(ObservableMap<String, ProgressNum> value) {
    _$progressMapsAtom.reportWrite(value, super.progressMaps, () {
      super.progressMaps = value;
    });
  }

  final _$saveImageAsyncAction = AsyncAction('_SaveStoreBase.saveImage');

  @override
  Future<void> saveImage(Illusts illusts, {int index, bool redo = false}) {
    return _$saveImageAsyncAction
        .run(() => super.saveImage(illusts, index: index, redo: redo));
  }

  final _$_SaveStoreBaseActionController =
      ActionController(name: '_SaveStoreBase');

  @override
  void initContext(I18n context) {
    final _$actionInfo = _$_SaveStoreBaseActionController.startAction(
        name: '_SaveStoreBase.initContext');
    try {
      return super.initContext(context);
    } finally {
      _$_SaveStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void saveChoiceImage(Illusts illusts, List<bool> indexs) {
    final _$actionInfo = _$_SaveStoreBaseActionController.startAction(
        name: '_SaveStoreBase.saveChoiceImage');
    try {
      return super.saveChoiceImage(illusts, indexs);
    } finally {
      _$_SaveStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
progressMaps: ${progressMaps}
    ''';
  }
}
