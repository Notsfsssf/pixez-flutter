import 'package:equatable/equatable.dart';
import 'package:pixez/models/tags.dart';

abstract class SuggestionState  {
  const SuggestionState();
}

class InitialSuggestionState extends SuggestionState {

}

class DataState extends SuggestionState {
  final AutoWords autoWords;
  DataState(this.autoWords);

}
