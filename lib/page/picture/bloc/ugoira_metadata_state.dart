import 'dart:io';

import 'package:meta/meta.dart';
import 'package:pixez/models/ugoira_metadata_response.dart';

@immutable
abstract class UgoiraMetadataState {}

class InitialUgoiraMetadataState extends UgoiraMetadataState {}

class DataUgoiraMetadataState extends UgoiraMetadataState {
  final UgoiraMetadataResponse ugoiraMetadataResponse;

  DataUgoiraMetadataState(this.ugoiraMetadataResponse);
}

class DownLoadProgressState extends UgoiraMetadataState {
  final int count;
  final int total;

  DownLoadProgressState(this.count, this.total);
}

class PlayUgoiraMetadataState extends UgoiraMetadataState {
  List<FileSystemEntity> listSync;
  List<Frame> frames;

  PlayUgoiraMetadataState(this.listSync, this.frames);
}
