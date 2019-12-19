import 'package:meta/meta.dart';

@immutable
abstract class BookmarkDetailEvent {}
class FetchBookmarkDetailEvent extends BookmarkDetailEvent{
  final int id;

  FetchBookmarkDetailEvent(this.id);
}