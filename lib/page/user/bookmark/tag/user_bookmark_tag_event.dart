import 'package:meta/meta.dart';
import 'package:pixez/models/illust_bookmark_tags_response.dart';

@immutable
abstract class UserBookmarkTagEvent {}

class FetchUserBookmarkTagEvent extends UserBookmarkTagEvent {
  final int id;
  final String restrict;

  FetchUserBookmarkTagEvent(this.id, this.restrict);
}

class FailUserBookmarkTagEvent extends UserBookmarkTagEvent {}

class LoadMoreUserBookmarkTagEvent extends UserBookmarkTagEvent {
  final List<BookmarkTag> bookmarkTags;
  final String nextUrl;

  LoadMoreUserBookmarkTagEvent(this.bookmarkTags, this.nextUrl);
}
