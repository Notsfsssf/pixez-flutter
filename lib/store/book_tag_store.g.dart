// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'book_tag_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic

mixin _$BookTagStore on _BookTagStoreBase, Store {
  final _$bookTagListAtom = Atom(name: '_BookTagStoreBase.bookTagList');

  @override
  ObservableList<String> get bookTagList {
    _$bookTagListAtom.reportRead();
    return super.bookTagList;
  }

  @override
  set bookTagList(ObservableList<String> value) {
    _$bookTagListAtom.reportWrite(value, super.bookTagList, () {
      super.bookTagList = value;
    });
  }

  final _$initAsyncAction = AsyncAction('_BookTagStoreBase.init');

  @override
  Future init() {
    return _$initAsyncAction.run(() => super.init());
  }

  final _$bookTagAsyncAction = AsyncAction('_BookTagStoreBase.bookTag');

  @override
  Future<void> bookTag(String tag) {
    return _$bookTagAsyncAction.run(() => super.bookTag(tag));
  }

  final _$unBookTagAsyncAction = AsyncAction('_BookTagStoreBase.unBookTag');

  @override
  Future<void> unBookTag(String tag) {
    return _$unBookTagAsyncAction.run(() => super.unBookTag(tag));
  }

  final _$resetAsyncAction = AsyncAction('_BookTagStoreBase.reset');

  @override
  Future reset() {
    return _$resetAsyncAction.run(() => super.reset());
  }

  @override
  String toString() {
    return '''
bookTagList: ${bookTagList}
    ''';
  }
}
