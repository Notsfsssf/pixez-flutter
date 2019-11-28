import 'package:equatable/equatable.dart';
import 'package:pixez/models/illust.dart';

abstract class RankingModeEvent extends Equatable {
  const RankingModeEvent();
}

class FetchEvent extends RankingModeEvent {
  final String mode;

  FetchEvent(this.mode);

  @override
  // TODO: implement props
  List<Object> get props => null;
}

class LoadMoreEvent extends RankingModeEvent {
  final String nextUrl;
  final List<Illusts> illusts;

  LoadMoreEvent(this.nextUrl, this.illusts);

  @override
  List<Object> get props => [illusts, nextUrl];
}
