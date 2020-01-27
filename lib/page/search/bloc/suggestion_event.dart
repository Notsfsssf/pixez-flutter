
abstract class SuggestionEvent {
  const SuggestionEvent();
}

class FetchSuggestionsEvent extends SuggestionEvent {
  final String query;

  FetchSuggestionsEvent(this.query);

}
