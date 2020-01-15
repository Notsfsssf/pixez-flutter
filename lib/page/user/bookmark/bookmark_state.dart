import 'package:pixez/models/illust.dart';

abstract class BookmarkState {
  const BookmarkState();
}

class InitialBookmarkState extends BookmarkState {
}

class DataBookmarkState extends BookmarkState {
  final List<Illusts> illusts;
  final String nextUrl;

  DataBookmarkState(this.illusts, this.nextUrl);
}

class LoadMoreSuccessState extends BookmarkState {}

class FailWorkState extends BookmarkState {}

class LoadMoreFailState extends BookmarkState {}

class LoadMoreEndState extends BookmarkState {}