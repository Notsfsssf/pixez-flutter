import 'package:meta/meta.dart';
import 'package:pixez/models/tags.dart';

@immutable
abstract class TagHistoryEvent {}
class FetchAllTagHistoryEvent extends TagHistoryEvent{

}
class InsertTagHistoryEvent extends TagHistoryEvent{
  final TagsPersist tagsPersist;

  InsertTagHistoryEvent(this.tagsPersist);
}
class DeleteAllTagHistoryEvent extends TagHistoryEvent{
  
}