import 'dart:async';
import 'package:bloc/bloc.dart';
import './bloc.dart';

class SearchResultBloc extends Bloc<SearchResultEvent, SearchResultState> {
  @override
  SearchResultState get initialState => InitialSearchResultState();

  @override
  Stream<SearchResultState> mapEventToState(
    SearchResultEvent event,
  ) async* {
    // TODO: Add Logic
  }
}
