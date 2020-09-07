// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'novel_lighting_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic

mixin _$NovelLightingStore on _NovelLightingStoreBase, Store {
  final _$errorMessageAtom = Atom(name: '_NovelLightingStoreBase.errorMessage');

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

  final _$fetchAsyncAction = AsyncAction('_NovelLightingStoreBase.fetch');

  @override
  Future<Void> fetch() {
    return _$fetchAsyncAction.run(() => super.fetch());
  }

  final _$nextAsyncAction = AsyncAction('_NovelLightingStoreBase.next');

  @override
  Future<Void> next() {
    return _$nextAsyncAction.run(() => super.next());
  }

  @override
  String toString() {
    return '''
errorMessage: ${errorMessage}
    ''';
  }
}
