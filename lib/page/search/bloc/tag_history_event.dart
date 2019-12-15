import 'package:meta/meta.dart';

@immutable
abstract class TagHistoryEvent {}
class FetchAllTagHistoryEvent extends TagHistoryEvent{

}
class DeleteAllTagHistoryEvent extends TagHistoryEvent{
  
}