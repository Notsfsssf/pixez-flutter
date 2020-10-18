import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:pixez/constants.dart';

enum Result { yes, no, timeout }

class Updater {
  static Result result = Result.timeout;

  static Future<Result> check() async {
    if (Constants.isGooglePlay) return Result.no;
    final result = await compute(checkUpdate, "");
    Updater.result = result;
    return result;
  }
}

Future<Result> checkUpdate(String arg) async {
  print("check for update ============");
  try {
    Response response =
        await Dio(BaseOptions(baseUrl: 'https://api.github.com'))
            .get('/repos/Notsfsssf/pixez-flutter/releases/latest');
    String tagName = response.data['tag_name'];
    print("tagName:$tagName ");
    List<String> remoteList = tagName.split(".");
    List<String> localList = Constants.tagName.split(".");
    for (int i = 0; i < remoteList.length - 1; i++) {}
  } catch (e) {
    print(e);
    return Result.timeout;
  }
  return Result.no;
}
