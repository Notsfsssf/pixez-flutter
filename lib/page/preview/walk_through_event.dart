import 'package:meta/meta.dart';
import 'package:pixez/models/illust.dart';

@immutable
abstract class WalkThroughEvent {}

class FetchWalkThroughEvent extends WalkThroughEvent {}

class LoadMoreWalkThroughEvent extends WalkThroughEvent {
  final String nextUrl;
  final List<Illusts> illusts;

  LoadMoreWalkThroughEvent(this.nextUrl, this.illusts);
}
