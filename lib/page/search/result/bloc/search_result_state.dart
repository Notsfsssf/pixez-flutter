import 'package:equatable/equatable.dart';
import 'package:pixez/models/illust.dart';

abstract class SearchResultState extends Equatable {
  const SearchResultState();
}

class InitialSearchResultState extends SearchResultState {
  @override
  List<Object> get props => [];
}
class DataState extends SearchResultState {
  final List<Illusts> illusts;
  final String nextUrl;

  DataState(this.illusts, this.nextUrl);

  @override
  // TODO: implement props
  List<Object> get props => [illusts, nextUrl];
}