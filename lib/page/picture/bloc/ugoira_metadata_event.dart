import 'package:meta/meta.dart';
import 'package:pixez/models/ugoira_metadata_response.dart';

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

class UnzipUgoiraMetadataEvent extends UgoiraMetadataEvent {
  final int id;
  final UgoiraMetadataResponse ugoiraMetadataResponse;

  UnzipUgoiraMetadataEvent(this.id, this.ugoiraMetadataResponse);
}

class EncodeToGifEvent extends UgoiraMetadataEvent {}
