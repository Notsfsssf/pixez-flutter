// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'novel_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic

mixin _$NovelStore on _NovelStoreBase, Store {
  final _$novelTextResponseAtom =
      Atom(name: '_NovelStoreBase.novelTextResponse');

  @override
  NovelTextResponse get novelTextResponse {
    _$novelTextResponseAtom.reportRead();
    return super.novelTextResponse;
  }

  @override
  set novelTextResponse(NovelTextResponse value) {
    _$novelTextResponseAtom.reportWrite(value, super.novelTextResponse, () {
      super.novelTextResponse = value;
    });
  }

  final _$errorMessageAtom = Atom(name: '_NovelStoreBase.errorMessage');

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

  final _$fetchAsyncAction = AsyncAction('_NovelStoreBase.fetch');

  @override
  Future fetch() {
    return _$fetchAsyncAction.run(() => super.fetch());
  }

  @override
  String toString() {
    return '''
novelTextResponse: ${novelTextResponse},
errorMessage: ${errorMessage}
    ''';
  }
}
