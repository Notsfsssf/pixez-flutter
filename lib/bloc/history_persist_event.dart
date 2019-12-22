import 'package:meta/meta.dart';
import 'package:pixez/models/illust.dart';

@immutable
abstract class HistoryPersistEvent {}

class FetchHistoryPersistEvent extends HistoryPersistEvent {}

class InsertHistoryPersistEvent extends HistoryPersistEvent {
  final Illusts illusts;

  InsertHistoryPersistEvent(this.illusts);
}

class DeleteHistoryPersistEvent extends HistoryPersistEvent {
  final int id;

  DeleteHistoryPersistEvent(this.id);
}

class DeleteAllHistoryPersistEvent extends HistoryPersistEvent {
  DeleteAllHistoryPersistEvent();
}
