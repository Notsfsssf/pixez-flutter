import 'package:meta/meta.dart';
import 'package:pixez/models/illust.dart';

@immutable
abstract class StarEvent {}

class ToStarEvent extends StarEvent {
  final Illusts illusts;
  final String restrict;
  final List<String> tags;

  ToStarEvent(this.illusts, this.restrict, this.tags);
}

class UnStarEvent extends StarEvent {
  final Illusts illusts;

  UnStarEvent(this.illusts);
}
