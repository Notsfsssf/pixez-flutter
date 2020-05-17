// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'lighting_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic

mixin _$LightingStore on _LightingStoreBase, Store {
  final _$sourceAtom = Atom(name: '_LightingStoreBase.source');

  @override
  Future<Response<dynamic>> get source {
    _$sourceAtom.context.enforceReadPolicy(_$sourceAtom);
    _$sourceAtom.reportObserved();
    return super.source;
  }

  @override
  set source(Future<Response<dynamic>> value) {
    _$sourceAtom.context.conditionallyRunInAction(() {
      super.source = value;
      _$sourceAtom.reportChanged();
    }, _$sourceAtom, name: '${_$sourceAtom.name}_set');
  }

  final _$illustsAtom = Atom(name: '_LightingStoreBase.illusts');

  @override
  ObservableList<Illusts> get illusts {
    _$illustsAtom.context.enforceReadPolicy(_$illustsAtom);
    _$illustsAtom.reportObserved();
    return super.illusts;
  }

  @override
  set illusts(ObservableList<Illusts> value) {
    _$illustsAtom.context.conditionallyRunInAction(() {
      super.illusts = value;
      _$illustsAtom.reportChanged();
    }, _$illustsAtom, name: '${_$illustsAtom.name}_set');
  }

  final _$fetchAsyncAction = AsyncAction('fetch');

  @override
  Future fetch() {
    return _$fetchAsyncAction.run(() => super.fetch());
  }

  final _$fetchNextAsyncAction = AsyncAction('fetchNext');

  @override
  Future fetchNext() {
    return _$fetchNextAsyncAction.run(() => super.fetchNext());
  }

  @override
  String toString() {
    final string =
        'source: ${source.toString()},illusts: ${illusts.toString()}';
    return '{$string}';
  }
}
