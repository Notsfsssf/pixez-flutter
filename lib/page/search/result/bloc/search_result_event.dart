import 'package:equatable/equatable.dart';
import 'package:pixez/models/illust.dart';

abstract class SearchResultEvent extends Equatable {
  const SearchResultEvent();
}

class FetchEvent extends SearchResultEvent {
  final String word, sort, searchTarget;
  final DateTime startDate, endDate;
  final bool enableDuration;

  FetchEvent(this.word, this.sort, this.searchTarget, this.startDate,
      this.endDate, this.enableDuration);

  @override
  List<Object> get props => [];
}

class LoadMoreEvent extends SearchResultEvent {
  final String nextUrl;
  final List<Illusts> illusts;

  LoadMoreEvent(this.nextUrl, this.illusts);

  @override
  List<Object> get props => [illusts, nextUrl];
}

class ShowBottomSheetEvent extends SearchResultEvent {
  @override
  List<Object> get props => [];
}
class ApplyEvent extends SearchResultEvent {
  final String word, sort, searchTarget;
  final DateTime startDate, endDate;
  final bool enableDuration;

  ApplyEvent(this.word, this.sort, this.searchTarget, this.startDate,
      this.endDate, this.enableDuration);

  @override
  List<Object> get props => [word, sort, searchTarget];
}
