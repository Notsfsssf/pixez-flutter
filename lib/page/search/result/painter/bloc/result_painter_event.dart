import 'package:meta/meta.dart';

@immutable
abstract class ResultPainterEvent {}

class FetchEvent extends ResultPainterEvent {
  final String word;

  FetchEvent(this.word);
}

class LoadMoreEvent extends ResultPainterEvent {
  final String nextUrl;
  LoadMoreEvent(this.nextUrl);
}
