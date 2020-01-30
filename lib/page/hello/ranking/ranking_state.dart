abstract class RankingState {
  const RankingState();
}

class InitialRankingState extends RankingState {
  @override
  List<Object> get props => [];
}

class DateState extends RankingState {
  DateTime dateTime;
  final List<String> modeList;

  DateState(this.dateTime, this.modeList);
}

class ModifyModeListState extends RankingState {}
