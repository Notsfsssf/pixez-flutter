// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'top_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic

mixin _$TopStore on _TopStoreBase, Store {
  final _$topNameAtom = Atom(name: '_TopStoreBase.topName');

  @override
  String get topName {
    _$topNameAtom.reportRead();
    return super.topName;
  }

  @override
  set topName(String value) {
    _$topNameAtom.reportWrite(value, super.topName, () {
      super.topName = value;
    });
  }

  final _$_TopStoreBaseActionController =
      ActionController(name: '_TopStoreBase');

  @override
  dynamic setTop(String name) {
    final _$actionInfo = _$_TopStoreBaseActionController.startAction(
        name: '_TopStoreBase.setTop');
    try {
      return super.setTop(name);
    } finally {
      _$_TopStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
topName: ${topName}
    ''';
  }
}
