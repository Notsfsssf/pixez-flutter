import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:pixez/constants.dart';
import 'package:pixez/er/lprinter.dart';

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
  LPrinter.d("check for update ============");
  try {
    Response response =
        await Dio(BaseOptions(baseUrl: 'https://api.github.com'))
            .get('/repos/Notsfsssf/pixez-flutter/releases/latest');
    String tagName = response.data['tag_name'];
    print("tagName:$tagName ");
    if (tagName != Constants.tagName) {
      List<String> remoteList = tagName.split(".");
      List<String> localList = Constants.tagName.split(".");
      if (remoteList.length != localList.length) return Result.yes;
      for (var i = 0; i < remoteList.length - 1; i++) {
        int r = int.tryParse(remoteList[i]) ?? 0;
        int l = int.tryParse(localList[i]) ?? 0;
        if (r > l) return Result.yes;
      }
    }
  } catch (e) {
    print(e);
    return Result.timeout;
  }
  return Result.no;
}
