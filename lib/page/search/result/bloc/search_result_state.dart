import 'package:equatable/equatable.dart';

abstract class SearchResultState extends Equatable {
  const SearchResultState();
}

class InitialSearchResultState extends SearchResultState {
  @override
  List<Object> get props => [];
}
