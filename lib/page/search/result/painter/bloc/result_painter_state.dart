import 'package:meta/meta.dart';
import 'package:pixez/models/user_preview.dart';

@immutable
abstract class ResultPainterState {}
  
class InitialResultPainterState extends ResultPainterState {}
class  ResultPainterDataState extends ResultPainterState {
  final List<UserPreviews> userPreviews;
  final String nextUrl;

  ResultPainterDataState(this.userPreviews, this.nextUrl);
}

class LoadMoreState extends ResultPainterState {
  final bool success;
  final bool noMore;

  LoadMoreState({@required this.success, @required this.noMore});
}

class RefreshState extends ResultPainterState {
  final bool success;

  RefreshState({this.success});
}
