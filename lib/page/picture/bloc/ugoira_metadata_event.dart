import 'package:meta/meta.dart';

@immutable
abstract class UgoiraMetadataEvent {}

class FetchUgoiraMetadataEvent extends UgoiraMetadataEvent {
  final int id;

  FetchUgoiraMetadataEvent(this.id);
}
