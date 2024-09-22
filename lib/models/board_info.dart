import 'dart:io';

import 'package:dio/dio.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:pixez/constants.dart';

part 'board_info.g.dart';

@JsonSerializable()
class BoardInfo {
  BoardInfo({
    required this.title,
    required this.content,
    required this.startDate,
    required this.endDate,
  });

  String title;
  String content;
  int startDate;
  int? endDate;

  factory BoardInfo.fromJson(Map<String, dynamic> json) =>
      _$BoardInfoFromJson(json);
  Map<String, dynamic> toJson() => _$BoardInfoToJson(this);

  static String path() {
    if (Platform.isAndroid) {
      if (Constants.isGooglePlay) {
        return "android_play.json";
      }
      return "android.json";
    } else if (Platform.isIOS) {
      return "ios.json";
    }
    return "";
  }

  static Future<List<BoardInfo>> load() async {
    final request = await Dio().get(
        'https://raw.githubusercontent.com/Notsfsssf/pixez-flutter/refs/heads/master/.github/board/${path()}');
    final list =
        (request.data as List).map((e) => BoardInfo.fromJson(e)).toList();
    return list;
  }
}
