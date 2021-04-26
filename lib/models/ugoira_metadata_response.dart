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
import 'package:json_annotation/json_annotation.dart';

part 'ugoira_metadata_response.g.dart';

@JsonSerializable()
class UgoiraMetadataResponse {
  @JsonKey(name: 'ugoira_metadata')
  UgoiraMetadata ugoiraMetadata;

  UgoiraMetadataResponse({
    required this.ugoiraMetadata,
  });

  factory UgoiraMetadataResponse.fromJson(Map<String, dynamic> json) =>
      _$UgoiraMetadataResponseFromJson(json);

  Map<String, dynamic> toJson() => _$UgoiraMetadataResponseToJson(this);
}

@JsonSerializable()
class UgoiraMetadata {
  @JsonKey(name: 'zip_urls')
  ZipUrls zipUrls;
  List<Frame> frames;

  UgoiraMetadata({
    required this.zipUrls,
    required this.frames,
  });

  factory UgoiraMetadata.fromJson(Map<String, dynamic> json) =>
      _$UgoiraMetadataFromJson(json);

  Map<String, dynamic> toJson() => _$UgoiraMetadataToJson(this);
}

@JsonSerializable()
class Frame {
  String file;
  int delay;

  Frame({
    required this.file,
    required this.delay,
  });

  factory Frame.fromJson(Map<String, dynamic> json) => _$FrameFromJson(json);

  Map<String, dynamic> toJson() => _$FrameToJson(this);
}

@JsonSerializable()
class ZipUrls {
  String medium;

  ZipUrls({
    required this.medium,
  });

  factory ZipUrls.fromJson(Map<String, dynamic> json) =>
      _$ZipUrlsFromJson(json);

  Map<String, dynamic> toJson() => _$ZipUrlsToJson(this);
}
