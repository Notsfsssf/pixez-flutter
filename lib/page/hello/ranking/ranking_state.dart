import 'package:equatable/equatable.dart';

abstract class RankingState extends Equatable {
  const RankingState();
}

class InitialRankingState extends RankingState {
  @override
  List<Object> get props => [];
}
