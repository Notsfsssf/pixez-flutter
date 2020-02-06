import 'package:meta/meta.dart';
import 'package:pixez/models/illust_bookmark_tags_response.dart';

@immutable
abstract class UserBookmarkTagState {}

class InitialUserBookmarkTagState extends UserBookmarkTagState {}

class DataUserBookmarkTagState extends UserBookmarkTagState {
  final List<BookmarkTag> bookmarkTags;
  final String nextUrl;

  DataUserBookmarkTagState(this.bookmarkTags, this.nextUrl);
}

class RefreshFail extends UserBookmarkTagState {}

class LoadMoreFail extends UserBookmarkTagState {}

class LoadMoreEnd extends UserBookmarkTagState {}
