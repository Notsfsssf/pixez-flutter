import 'package:meta/meta.dart';
import 'package:pixez/models/illust.dart';

@immutable
abstract class WalkThroughState {}

class InitialWalkThroughState extends WalkThroughState {}

class DataWalkThroughState extends WalkThroughState {
  final List<Illusts> illusts;
  final String nextUrl;

  DataWalkThroughState(this.illusts, this.nextUrl);
}
