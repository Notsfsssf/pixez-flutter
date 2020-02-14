import 'package:meta/meta.dart';

@immutable
abstract class NovelTextEvent {}
class FetchEvent extends NovelTextEvent{}
class LoadMoreEvent extends NovelTextEvent{}