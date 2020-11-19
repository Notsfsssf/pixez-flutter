// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'splash_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic

mixin _$SplashStore on _SplashStoreBase, Store {
  final _$helloWordAtom = Atom(name: '_SplashStoreBase.helloWord');

  @override
  String get helloWord {
    _$helloWordAtom.reportRead();
    return super.helloWord;
  }

  @override
  set helloWord(String value) {
    _$helloWordAtom.reportWrite(value, super.helloWord, () {
      super.helloWord = value;
    });
  }

  final _$onezeroResponseAtom = Atom(name: '_SplashStoreBase.onezeroResponse');

  @override
  OnezeroResponse get onezeroResponse {
    _$onezeroResponseAtom.reportRead();
    return super.onezeroResponse;
  }

  @override
  set onezeroResponse(OnezeroResponse value) {
    _$onezeroResponseAtom.reportWrite(value, super.onezeroResponse, () {
      super.onezeroResponse = value;
    });
  }

  final _$helloAsyncAction = AsyncAction('_SplashStoreBase.hello');

  @override
  Future hello() {
    return _$helloAsyncAction.run(() => super.hello());
  }

  final _$fetchAsyncAction = AsyncAction('_SplashStoreBase.fetch');

  @override
  Future fetch() {
    return _$fetchAsyncAction.run(() => super.fetch());
  }

  @override
  String toString() {
    return '''
helloWord: ${helloWord},
onezeroResponse: ${onezeroResponse}
    ''';
  }
}
