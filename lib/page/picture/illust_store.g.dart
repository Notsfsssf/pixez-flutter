// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'illust_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic

mixin _$IllustStore on _IllustStoreBase, Store {
  final _$illustsAtom = Atom(name: '_IllustStoreBase.illusts');

  @override
  Illusts get illusts {
    _$illustsAtom.reportRead();
    return super.illusts;
  }

  @override
  set illusts(Illusts value) {
    _$illustsAtom.reportWrite(value, super.illusts, () {
      super.illusts = value;
    });
  }

  final _$isBookmarkAtom = Atom(name: '_IllustStoreBase.isBookmark');

  @override
  bool get isBookmark {
    _$isBookmarkAtom.reportRead();
    return super.isBookmark;
  }

  @override
  set isBookmark(bool value) {
    _$isBookmarkAtom.reportWrite(value, super.isBookmark, () {
      super.isBookmark = value;
    });
  }

  final _$errorMessageAtom = Atom(name: '_IllustStoreBase.errorMessage');

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

  final _$stateAtom = Atom(name: '_IllustStoreBase.state');

  @override
  int get state {
    _$stateAtom.reportRead();
    return super.state;
  }

  @override
  set state(int value) {
    _$stateAtom.reportWrite(value, super.state, () {
      super.state = value;
    });
  }

  final _$fetchAsyncAction = AsyncAction('_IllustStoreBase.fetch');

  @override
  Future fetch() {
    return _$fetchAsyncAction.run(() => super.fetch());
  }

  final _$starAsyncAction = AsyncAction('_IllustStoreBase.star');

  @override
  Future<bool> star({String restrict = 'public', List<String> tags}) {
    return _$starAsyncAction
        .run(() => super.star(restrict: restrict, tags: tags));
  }

  @override
  String toString() {
    return '''
illusts: ${illusts},
isBookmark: ${isBookmark},
errorMessage: ${errorMessage},
state: ${state}
    ''';
  }
}
