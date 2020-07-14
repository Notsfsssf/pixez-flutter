// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'account_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic

mixin _$AccountStore on _AccountStoreBase, Store {
  final _$nowAtom = Atom(name: '_AccountStoreBase.now');

  @override
  AccountPersist get now {
    _$nowAtom.reportRead();
    return super.now;
  }

  @override
  set now(AccountPersist value) {
    _$nowAtom.reportWrite(value, super.now, () {
      super.now = value;
    });
  }

  final _$selectAsyncAction = AsyncAction('_AccountStoreBase.select');

  @override
  Future select(int index) {
    return _$selectAsyncAction.run(() => super.select(index));
  }

  final _$deleteAllAsyncAction = AsyncAction('_AccountStoreBase.deleteAll');

  @override
  Future deleteAll() {
    return _$deleteAllAsyncAction.run(() => super.deleteAll());
  }

  final _$updateSingleAsyncAction =
      AsyncAction('_AccountStoreBase.updateSingle');

  @override
  Future updateSingle(AccountPersist accountPersist) {
    return _$updateSingleAsyncAction
        .run(() => super.updateSingle(accountPersist));
  }

  final _$deleteSingleAsyncAction =
      AsyncAction('_AccountStoreBase.deleteSingle');

  @override
  Future deleteSingle(int id) {
    return _$deleteSingleAsyncAction.run(() => super.deleteSingle(id));
  }

  final _$fetchAsyncAction = AsyncAction('_AccountStoreBase.fetch');

  @override
  Future fetch() {
    return _$fetchAsyncAction.run(() => super.fetch());
  }

  @override
  String toString() {
    return '''
now: ${now}
    ''';
  }
}
