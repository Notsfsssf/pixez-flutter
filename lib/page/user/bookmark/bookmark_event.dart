import 'package:equatable/equatable.dart';
import 'package:pixez/models/illust.dart';

abstract class BookmarkEvent extends Equatable {
  const BookmarkEvent();
}

class FetchBookmarkEvent extends BookmarkEvent {
  final int user_id;
  final String type;
  final String tags;

  FetchBookmarkEvent(this.user_id, this.type, {this.tags});

  @override
  // TODO: implement props
  List<Object> get props => [user_id, type];
}

class LoadMoreEvent extends BookmarkEvent {
  final String nextUrl;
  final List<Illusts> illusts;

  LoadMoreEvent(this.nextUrl, this.illusts);

  @override
  List<Object> get props => [illusts, nextUrl];
}
