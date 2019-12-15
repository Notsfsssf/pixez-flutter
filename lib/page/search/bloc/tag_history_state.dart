import 'package:meta/meta.dart';
import 'package:pixez/models/tags.dart';

@immutable
abstract class TagHistoryState {}

class InitialTagHistoryState extends TagHistoryState {}

class TagHistoryDataState extends TagHistoryState {
  final List<TagsPersist> tagsPersistList;

  TagHistoryDataState(this.tagsPersistList);
}
