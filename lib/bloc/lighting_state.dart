import 'package:meta/meta.dart';
import 'package:pixez/models/illust.dart';

@immutable
abstract class LightingState {}

class LightingInitial extends LightingState {}

class LightingLoadSuccess extends LightingState {
  final List<Illusts> illusts;
  final String nextUrl;

  LightingLoadSuccess(this.illusts, this.nextUrl);
}

class LightingLoadFailure extends LightingState {}

class LightingLoadMoreSuccess extends LightingState {}

class LightingLoadMoreFailure extends LightingState {}
