import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:pixez/models/tags.dart';
import 'package:pixez/network/api_client.dart';

import './bloc.dart';

class SuggestionBloc extends Bloc<SuggestionEvent, SuggestionState> {
  final ApiClient client;

  SuggestionBloc(this.client);

  @override
  SuggestionState get initialState => InitialSuggestionState();

  @override
  Stream<SuggestionState> mapEventToState(
    SuggestionEvent event,
  ) async* {
    if (event is FetchSuggestionsEvent) {
      AutoWords autoWords =
          await client.getSearchAutoCompleteKeywords(event.query);
      yield DataState(autoWords);
    }
  }
}
