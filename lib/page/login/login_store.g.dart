// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'login_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic

mixin _$LoginStore on _LoginStoreBase, Store {
  final _$errorMessageAtom = Atom(name: '_LoginStoreBase.errorMessage');

  @override
  String get errorMessage {
    _$errorMessageAtom.reportRead();
    return super.errorMessage;
  }

  @override
  set errorMessage(String value) {
    _$errorMessageAtom.reportWrite(value, super.errorMessage, () {
      super.errorMessage = value;
    });
  }

  final _$authAsyncAction = AsyncAction('_LoginStoreBase.auth');

  @override
  Future<bool> auth(String username, dynamic password, {String deviceToken}) {
    return _$authAsyncAction
        .run(() => super.auth(username, password, deviceToken: deviceToken));
  }

  @override
  String toString() {
    return '''
errorMessage: ${errorMessage}
    ''';
  }
}
