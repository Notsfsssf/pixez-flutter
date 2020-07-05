// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'rank_mode_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic

mixin _$RankModeStore on _RankModeStoreBase, Store {
  final _$illustsAtom = Atom(name: '_RankModeStoreBase.illusts');

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

  final _$startAsyncAction = AsyncAction('_RankModeStoreBase.start');

  @override
  Future<void> start() {
    return _$startAsyncAction.run(() => super.start());
  }

  @override
  String toString() {
    return '''
illusts: ${illusts}
    ''';
  }
}
