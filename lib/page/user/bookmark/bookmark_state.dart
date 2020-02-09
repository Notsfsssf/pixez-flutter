import 'package:flutter/foundation.dart';
import 'package:pixez/models/illust.dart';

abstract class BookmarkState {}

class InitialBookmarkState extends BookmarkState {
}

class DataBookmarkState extends BookmarkState {
  final List<Illusts> illusts;
  final String nextUrl;
  final String tag;

  DataBookmarkState(this.illusts, this.nextUrl, this.tag);
}

class LoadMoreState extends BookmarkState {
  final bool success;
  final bool noMore;

  LoadMoreState({@required this.success, @required this.noMore});
}

class RefreshState extends BookmarkState {
  final bool success;

  RefreshState({@required this.success});
}