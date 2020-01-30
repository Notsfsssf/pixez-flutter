abstract class RankingEvent {
  const RankingEvent();
}

class DateChangeEvent extends RankingEvent {
  final DateTime dateTime;

  DateChangeEvent(this.dateTime);
}

class SaveChangeEvent extends RankingEvent {
  final Map<String, bool> selectMap;

  SaveChangeEvent(this.selectMap);
}

class ResetEvent extends RankingEvent {}
