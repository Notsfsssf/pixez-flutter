import 'package:equatable/equatable.dart';
import 'package:pixez/models/tags.dart';

abstract class SuggestionState extends Equatable {
  const SuggestionState();
}

class InitialSuggestionState extends SuggestionState {
  @override
  List<Object> get props => [];
}

class DataState extends SuggestionState {
  final AutoWords autoWords;

  DataState(this.autoWords);

  @override
  // TODO: implement props
  List<Object> get props => null;
}
