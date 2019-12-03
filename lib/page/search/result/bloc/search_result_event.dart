import 'package:equatable/equatable.dart';
import 'package:pixez/models/illust.dart';

abstract class SearchResultEvent extends Equatable {
  const SearchResultEvent();
}
class FetchEvent extends SearchResultEvent {
  final String word;

  FetchEvent(this.word);

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