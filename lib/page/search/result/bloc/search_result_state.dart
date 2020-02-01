import 'package:equatable/equatable.dart';
import 'package:pixez/models/illust.dart';

abstract class SearchResultState {
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

}

class ShowBottomSheetState extends SearchResultState {

}
class RefreshFailState extends SearchResultState{}
class LoadEndState extends SearchResultState{}
class LoadMoreFailState extends SearchResultState{}