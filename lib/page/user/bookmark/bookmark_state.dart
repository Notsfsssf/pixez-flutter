import 'package:equatable/equatable.dart';
import 'package:pixez/models/illust.dart';

abstract class BookmarkState extends Equatable {
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
  // TODO: implement props
  List<Object> get props => [illusts, nextUrl];
}

class LoadMoreSuccessState extends BookmarkState {
  @override
  // TODO: implement props
  List<Object> get props => null;
}
