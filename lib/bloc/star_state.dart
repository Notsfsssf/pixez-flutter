import 'package:meta/meta.dart';

@immutable
abstract class StarState {}

class InitialStarState extends StarState {
  final bool isStar;

  InitialStarState(this.isStar);
}

class NowStarState extends StarState {
  final bool isStar;

  NowStarState(this.isStar);
}
