// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'account_edit_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic

mixin _$AccountEditStore on _AccountEditStoreBase, Store {
  final _$errorStringAtom = Atom(name: '_AccountEditStoreBase.errorString');

  @override
  String get errorString {
    _$errorStringAtom.reportRead();
    return super.errorString;
  }

  @override
  set errorString(String value) {
    _$errorStringAtom.reportWrite(value, super.errorString, () {
      super.errorString = value;
    });
  }

  final _$fetchAsyncAction = AsyncAction('_AccountEditStoreBase.fetch');

  @override
  Future<bool> fetch(String newMailAddress, dynamic newPassword,
      dynamic oldPassword, dynamic newUserAccount) {
    return _$fetchAsyncAction.run(() =>
        super.fetch(newMailAddress, newPassword, oldPassword, newUserAccount));
  }

  @override
  String toString() {
    return '''
errorString: ${errorString}
    ''';
  }
}
