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

class LoadEndState extends ResultPainterState {}

class LoadMoreFailState extends ResultPainterState {}

class LoadMoreSuccessState extends ResultPainterState {}

class RefreshFailState extends ResultPainterState {}

class RefreshSuccessState extends ResultPainterState {}
