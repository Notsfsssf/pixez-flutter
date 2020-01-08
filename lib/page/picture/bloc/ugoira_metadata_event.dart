import 'package:meta/meta.dart';

@immutable
abstract class UgoiraMetadataEvent {}

class FetchUgoiraMetadataEvent extends UgoiraMetadataEvent {
  final int id;

  FetchUgoiraMetadataEvent(this.id);
}
class ProgressUgoiraMetadataEvent extends UgoiraMetadataEvent {
  final int count;
  final int total;

  ProgressUgoiraMetadataEvent(this.count, this.total);
}