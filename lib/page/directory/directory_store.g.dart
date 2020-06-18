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
    _$pathAtom.reportRead();
    return super.path;
  }

  @override
  set path(String value) {
    _$pathAtom.reportWrite(value, super.path, () {
      super.path = value;
    });
  }

  final _$checkSuccessAtom = Atom(name: '_DirectoryStoreBase.checkSuccess');

  @override
  bool get checkSuccess {
    _$checkSuccessAtom.reportRead();
    return super.checkSuccess;
  }

  @override
  set checkSuccess(bool value) {
    _$checkSuccessAtom.reportWrite(value, super.checkSuccess, () {
      super.checkSuccess = value;
    });
  }

  final _$listAtom = Atom(name: '_DirectoryStoreBase.list');

  @override
  ObservableList<FileSystemEntity> get list {
    _$listAtom.reportRead();
    return super.list;
  }

  @override
  set list(ObservableList<FileSystemEntity> value) {
    _$listAtom.reportWrite(value, super.list, () {
      super.list = value;
    });
  }

  final _$enterFolderAsyncAction =
      AsyncAction('_DirectoryStoreBase.enterFolder');

  @override
  Future<void> enterFolder(Directory fileSystemEntity) {
    return _$enterFolderAsyncAction
        .run(() => super.enterFolder(fileSystemEntity));
  }

  final _$undoAsyncAction = AsyncAction('_DirectoryStoreBase.undo');

  @override
  Future<void> undo() {
    return _$undoAsyncAction.run(() => super.undo());
  }

  final _$checkAsyncAction = AsyncAction('_DirectoryStoreBase.check');

  @override
  Future<void> check() {
    return _$checkAsyncAction.run(() => super.check());
  }

  final _$backFolderAsyncAction = AsyncAction('_DirectoryStoreBase.backFolder');

  @override
  Future<void> backFolder() {
    return _$backFolderAsyncAction.run(() => super.backFolder());
  }

  final _$initAsyncAction = AsyncAction('_DirectoryStoreBase.init');

  @override
  Future<void> init() {
    return _$initAsyncAction.run(() => super.init());
  }

  final _$_DirectoryStoreBaseActionController =
      ActionController(name: '_DirectoryStoreBase');

  @override
  dynamic setPath(String result) {
    final _$actionInfo = _$_DirectoryStoreBaseActionController.startAction(
        name: '_DirectoryStoreBase.setPath');
    try {
      return super.setPath(result);
    } finally {
      _$_DirectoryStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
path: ${path},
checkSuccess: ${checkSuccess},
list: ${list}
    ''';
  }
}
