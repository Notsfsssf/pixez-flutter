import 'package:equatable/equatable.dart';

abstract class SuggestionEvent extends Equatable {
  const SuggestionEvent();
}

class FetchSuggestionsEvent extends SuggestionEvent {
  final String query;

  FetchSuggestionsEvent(this.query);

  @override
  // TODO: implement props
  List<Object> get props => [query];
}
