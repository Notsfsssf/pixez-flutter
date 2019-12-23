import 'package:meta/meta.dart';
import 'package:pixez/models/illust.dart';

@immutable
abstract class IllustPersistEvent {}
class FetchIllustPersistEvent extends IllustPersistEvent {}

class InsertIllustPersistEvent extends IllustPersistEvent {
  final Illusts illusts;

  InsertIllustPersistEvent(this.illusts);
}

class DeleteIllustPersistEvent extends IllustPersistEvent {
  final int id;

  DeleteIllustPersistEvent(this.id);
}

class DeleteAllIllustPersistEvent extends IllustPersistEvent {
  DeleteAllIllustPersistEvent();
}