// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'soup_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic

mixin _$SoupStore on _SoupStoreBase, Store {
  final _$descriptionAtom = Atom(name: '_SoupStoreBase.description');

  @override
  String get description {
    _$descriptionAtom.reportRead();
    return super.description;
  }

  @override
  set description(String value) {
    _$descriptionAtom.reportWrite(value, super.description, () {
      super.description = value;
    });
  }

  final _$fetchAsyncAction = AsyncAction('_SoupStoreBase.fetch');

  @override
  Future fetch(String url) {
    return _$fetchAsyncAction.run(() => super.fetch(url));
  }

  @override
  String toString() {
    return '''
description: ${description}
    ''';
  }
}
