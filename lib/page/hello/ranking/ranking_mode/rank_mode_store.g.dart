// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'rank_mode_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic

mixin _$RankModeStore on _RankModeStoreBase, Store {
  final _$illustsAtom = Atom(name: '_RankModeStoreBase.illusts');

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

  final _$startAsyncAction = AsyncAction('start');

  @override
  Future<void> start() {
    return _$startAsyncAction.run(() => super.start());
  }

  @override
  String toString() {
    final string = 'illusts: ${illusts.toString()}';
    return '{$string}';
  }
}
