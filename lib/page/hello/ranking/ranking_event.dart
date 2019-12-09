import 'package:equatable/equatable.dart';

abstract class RankingEvent extends Equatable {
  const RankingEvent();
}
class DateChangeEvent extends RankingEvent {
final DateTime dateTime;

  DateChangeEvent(this.dateTime);
  @override
  List<Object> get props => [dateTime];
  
}