import 'package:meta/meta.dart';

@immutable
abstract class IllustRelatedEvent {}
class FetchRelatedEvent extends IllustRelatedEvent {
  final int id;

  FetchRelatedEvent(this.id);
}