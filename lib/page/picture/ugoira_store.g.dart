// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ugoira_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic

mixin _$UgoiraStore on _UgoiraStoreBase, Store {
  final _$statusAtom = Atom(name: '_UgoiraStoreBase.status');

  @override
  UgoiraStatus get status {
    _$statusAtom.reportRead();
    return super.status;
  }

  @override
  set status(UgoiraStatus value) {
    _$statusAtom.reportWrite(value, super.status, () {
      super.status = value;
    });
  }

  final _$countAtom = Atom(name: '_UgoiraStoreBase.count');

  @override
  int get count {
    _$countAtom.reportRead();
    return super.count;
  }

  @override
  set count(int value) {
    _$countAtom.reportWrite(value, super.count, () {
      super.count = value;
    });
  }

  final _$totalAtom = Atom(name: '_UgoiraStoreBase.total');

  @override
  int get total {
    _$totalAtom.reportRead();
    return super.total;
  }

  @override
  set total(int value) {
    _$totalAtom.reportWrite(value, super.total, () {
      super.total = value;
    });
  }

  final _$unZipAsyncAction = AsyncAction('_UgoiraStoreBase.unZip');

  @override
  Future unZip() {
    return _$unZipAsyncAction.run(() => super.unZip());
  }

  final _$downloadAndUnzipAsyncAction =
      AsyncAction('_UgoiraStoreBase.downloadAndUnzip');

  @override
  Future downloadAndUnzip() {
    return _$downloadAndUnzipAsyncAction.run(() => super.downloadAndUnzip());
  }

  @override
  String toString() {
    return '''
status: ${status},
count: ${count},
total: ${total}
    ''';
  }
}
