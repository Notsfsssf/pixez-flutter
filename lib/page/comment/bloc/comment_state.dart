import 'package:meta/meta.dart';
import 'package:pixez/models/comment_response.dart';

@immutable
abstract class CommentState {}

class InitialCommentState extends CommentState {}

class DataCommentState extends CommentState {
  final CommentResponse commentResponse;

  DataCommentState(this.commentResponse);
}
