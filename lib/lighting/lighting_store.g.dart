// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'lighting_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic

mixin _$LightingStore on _LightingStoreBase, Store {
  final _$illustsAtom = Atom(name: '_LightingStoreBase.illusts');

  @override
  ObservableList<Illusts> get illusts {
    _$illustsAtom.reportRead();
    return super.illusts;
  }

  @override
  set illusts(ObservableList<Illusts> value) {
    _$illustsAtom.reportWrite(value, super.illusts, () {
      super.illusts = value;
    });
  }

  final _$errorMessageAtom = Atom(name: '_LightingStoreBase.errorMessage');

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

  final _$fetchAsyncAction = AsyncAction('_LightingStoreBase.fetch');

  @override
  Future fetch() {
    return _$fetchAsyncAction.run(() => super.fetch());
  }

  final _$fetchNextAsyncAction = AsyncAction('_LightingStoreBase.fetchNext');

  @override
  Future fetchNext() {
    return _$fetchNextAsyncAction.run(() => super.fetchNext());
  }

  @override
  String toString() {
    return '''
illusts: ${illusts},
errorMessage: ${errorMessage}
    ''';
  }
}
