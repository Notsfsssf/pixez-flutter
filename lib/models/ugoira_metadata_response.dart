import 'dart:convert';

UgoiraMetadataResponse ugoiraMetadataResponseFromJson(String str) =>
    UgoiraMetadataResponse.fromJson(json.decode(str));

String ugoiraMetadataResponseToJson(UgoiraMetadataResponse data) =>
    json.encode(data.toJson());

class UgoiraMetadataResponse {
  UgoiraMetadata ugoiraMetadata;

  UgoiraMetadataResponse({
    this.ugoiraMetadata,
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
    this.zipUrls,
    this.frames,
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
    this.file,
    this.delay,
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
    this.medium,
  });

  factory ZipUrls.fromJson(Map<String, dynamic> json) => ZipUrls(
        medium: json["medium"],
      );

  Map<String, dynamic> toJson() => {
        "medium": medium,
      };
}
