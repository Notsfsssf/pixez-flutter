import 'package:equatable/equatable.dart';
import 'package:pixez/models/illust.dart';

abstract class RankingModeState extends Equatable {
  const RankingModeState();
}

class InitialRankingModeState extends RankingModeState {
  @override
  List<Object> get props => [];
}

class DataRankingModeState extends RankingModeState {
  final List<Illusts> illusts;
  final String nextUrl;

  DataRankingModeState(this.illusts, this.nextUrl);

  @override
  List<Object> get props => [illusts, nextUrl];
}
class FailRankingModeState extends RankingModeState {
  @override
  List<Object> get props => [];

}
class LoadMoreSuccessState extends RankingModeState {
  @override
  List<Object> get props => [];
}
