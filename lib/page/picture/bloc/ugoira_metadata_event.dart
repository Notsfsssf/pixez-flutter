/*
 * Copyright (C) 2020. by perol_notsf, All rights reserved
 *
 * This program is free software: you can redistribute it and/or modify it under
 * the terms of the GNU General Public License as published by the Free Software
 * Foundation, either version 3 of the License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful, but WITHOUT ANY
 * WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
 * FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License along with
 * this program. If not, see <http://www.gnu.org/licenses/>.
 *
 */

import 'dart:io';

import 'package:meta/meta.dart';
import 'package:pixez/models/illust.dart';
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

class EncodeToGifEvent extends UgoiraMetadataEvent {
  final List<FileSystemEntity> listSync;
  final Illusts illust;
  final List<Frame> frames;

  EncodeToGifEvent(
    this.listSync,
    this.illust,
    this.frames,
  );
}
