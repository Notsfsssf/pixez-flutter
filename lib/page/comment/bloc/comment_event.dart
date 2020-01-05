import 'package:meta/meta.dart';
import 'package:pixez/models/comment_response.dart';

@immutable
abstract class CommentEvent {}

class FetchCommentEvent extends CommentEvent {
  final int id;

  FetchCommentEvent(this.id);
}

class LoadMoreCommentEvent extends CommentEvent {
  final CommentResponse commentResponse;

  LoadMoreCommentEvent(this.commentResponse);
}
