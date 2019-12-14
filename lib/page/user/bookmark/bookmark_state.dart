import 'package:pixez/models/illust.dart';

abstract class BookmarkState {
  const BookmarkState();
}

class InitialBookmarkState extends BookmarkState {
  @override
  List<Object> get props => [];
}

class DataBookmarkState extends BookmarkState {
  final List<Illusts> illusts;
  final String nextUrl;

  DataBookmarkState(this.illusts, this.nextUrl);

  @override
  List<Object> get props => [illusts, nextUrl];
}

class LoadMoreSuccessState extends BookmarkState {
  @override
  List<Object> get props => [];
}
