import 'package:equatable/equatable.dart';
import 'package:pixez/models/illust.dart';

abstract class SearchResultEvent extends Equatable {
  const SearchResultEvent();
}
class FetchEvent extends SearchResultEvent {
  final String word, sort, searchTarget;

  FetchEvent(this.word, this.sort, this.searchTarget);

  @override
  // TODO: implement props
  List<Object> get props => null;
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
  // TODO: implement props
  List<Object> get props => null;
}

class ApplyEvent extends SearchResultEvent {
  final String word, sort, searchTarget;

  ApplyEvent(this.word, this.sort, this.searchTarget);

  @override
  List<Object> get props => [word, sort, searchTarget];
}