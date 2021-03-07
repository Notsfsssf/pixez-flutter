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
import 'dart:convert';

UgoiraMetadataResponse ugoiraMetadataResponseFromJson(String str) =>
    UgoiraMetadataResponse.fromJson(json.decode(str));

String ugoiraMetadataResponseToJson(UgoiraMetadataResponse data) =>
    json.encode(data.toJson());

class UgoiraMetadataResponse {
  UgoiraMetadata ugoiraMetadata;

  UgoiraMetadataResponse({
    required this.ugoiraMetadata,
  });

  factory UgoiraMetadataResponse.fromJson(Map<String, dynamic> json) =>
      UgoiraMetadataResponse(
        ugoiraMetadata: UgoiraMetadata.fromJson(json["ugoira_metadata"]),
      );

  Map<String, dynamic> toJson() => {
        "ugoira_metadata": ugoiraMetadata.toJson(),
      };
}

class UgoiraMetadata {
  ZipUrls zipUrls;
  List<Frame> frames;

  UgoiraMetadata({
    required this.zipUrls,
    required this.frames,
  });

  factory UgoiraMetadata.fromJson(Map<String, dynamic> json) => UgoiraMetadata(
        zipUrls: ZipUrls.fromJson(json["zip_urls"]),
        frames: List<Frame>.from(json["frames"].map((x) => Frame.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "zip_urls": zipUrls.toJson(),
        "frames": List<dynamic>.from(frames.map((x) => x.toJson())),
      };
}

class Frame {
  String file;
  int delay;

  Frame({
    required this.file,
    required this.delay,
  });

  factory Frame.fromJson(Map<String, dynamic> json) => Frame(
        file: json["file"],
        delay: json["delay"],
      );

  Map<String, dynamic> toJson() => {
        "file": file,
        "delay": delay,
      };
}

class ZipUrls {
  String medium;

  ZipUrls({
    required this.medium,
  });

  factory ZipUrls.fromJson(Map<String, dynamic> json) => ZipUrls(
        medium: json["medium"],
      );

  Map<String, dynamic> toJson() => {
        "medium": medium,
      };
}
