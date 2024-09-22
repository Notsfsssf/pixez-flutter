import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
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
  String startDate;
  String? endDate;

  factory BoardInfo.fromJson(Map<String, dynamic> json) =>
      _$BoardInfoFromJson(json);
  Map<String, dynamic> toJson() => _$BoardInfoToJson(this);
  
  static bool boardDataLoaded = false;
  
  static List<BoardInfo> boardList = [];

  static String path() {
    if (kDebugMode) {
      return "android.json";
    }
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
    print(path());
    final request = await Dio().get(
        'https://raw.githubusercontent.com/Notsfsssf/pixez-flutter/refs/heads/master/.github/board/${path()}');
    final list = (jsonDecode(request.data) as List)
        .map((e) => BoardInfo.fromJson(e))
        .toList();
    boardList = list;
    return list;
  }
}
