import 'package:equatable/equatable.dart';
import 'package:pixez/models/illust.dart';

abstract class SearchResultEvent {
  const SearchResultEvent();
}

class FetchEvent extends SearchResultEvent {
  final String word, sort, searchTarget;
  final DateTime startDate, endDate;
  final bool enableDuration;

  FetchEvent(this.word, this.sort, this.searchTarget, this.startDate,
      this.endDate, this.enableDuration);
}

class LoadMoreEvent extends SearchResultEvent {
  final String nextUrl;
  final List<Illusts> illusts;

  LoadMoreEvent(this.nextUrl, this.illusts);
}

class ShowBottomSheetEvent extends SearchResultEvent {}

class PreviewEvent extends SearchResultEvent {
  final String word;

  PreviewEvent(this.word);
}

class ApplyEvent extends SearchResultEvent {
  final String word, sort, searchTarget;
  final DateTime startDate, endDate;
  final bool enableDuration;

  ApplyEvent(this.word, this.sort, this.searchTarget, this.startDate,
      this.endDate, this.enableDuration);
}
