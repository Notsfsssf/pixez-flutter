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
class LoadMoreSuccessState extends BookmarkState {}
class FailWorkState extends BookmarkState {}

class LoadMoreFailState extends BookmarkState {}

class SuccessRefreshState extends BookmarkState {}

class LoadMoreEndState extends BookmarkState {}