// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'directory_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic

mixin _$DirectoryStore on _DirectoryStoreBase, Store {
  final _$pathAtom = Atom(name: '_DirectoryStoreBase.path');

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

  final _$checkSuccessAtom = Atom(name: '_DirectoryStoreBase.checkSuccess');

  @override
  bool get checkSuccess {
    _$checkSuccessAtom.context.enforceReadPolicy(_$checkSuccessAtom);
    _$checkSuccessAtom.reportObserved();
    return super.checkSuccess;
  }

  @override
  set checkSuccess(bool value) {
    _$checkSuccessAtom.context.conditionallyRunInAction(() {
      super.checkSuccess = value;
      _$checkSuccessAtom.reportChanged();
    }, _$checkSuccessAtom, name: '${_$checkSuccessAtom.name}_set');
  }

  final _$listAtom = Atom(name: '_DirectoryStoreBase.list');

  @override
  ObservableList<FileSystemEntity> get list {
    _$listAtom.context.enforceReadPolicy(_$listAtom);
    _$listAtom.reportObserved();
    return super.list;
  }

  @override
  set list(ObservableList<FileSystemEntity> value) {
    _$listAtom.context.conditionallyRunInAction(() {
      super.list = value;
      _$listAtom.reportChanged();
    }, _$listAtom, name: '${_$listAtom.name}_set');
  }

  final _$enterFolderAsyncAction = AsyncAction('enterFolder');

  @override
  Future<void> enterFolder(Directory fileSystemEntity) {
    return _$enterFolderAsyncAction
        .run(() => super.enterFolder(fileSystemEntity));
  }

  final _$undoAsyncAction = AsyncAction('undo');

  @override
  Future<void> undo() {
    return _$undoAsyncAction.run(() => super.undo());
  }

  final _$checkAsyncAction = AsyncAction('check');

  @override
  Future<void> check() {
    return _$checkAsyncAction.run(() => super.check());
  }

  final _$backFolderAsyncAction = AsyncAction('backFolder');

  @override
  Future<void> backFolder() {
    return _$backFolderAsyncAction.run(() => super.backFolder());
  }

  final _$initAsyncAction = AsyncAction('init');

  @override
  Future<void> init() {
    return _$initAsyncAction.run(() => super.init());
  }

  final _$_DirectoryStoreBaseActionController =
      ActionController(name: '_DirectoryStoreBase');

  @override
  dynamic setPath(String result) {
    final _$actionInfo = _$_DirectoryStoreBaseActionController.startAction();
    try {
      return super.setPath(result);
    } finally {
      _$_DirectoryStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    final string =
        'path: ${path.toString()},checkSuccess: ${checkSuccess.toString()},list: ${list.toString()}';
    return '{$string}';
  }
}
