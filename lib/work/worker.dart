import 'dart:collection';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pixez/component/pixiv_image.dart';
import 'package:pixez/models/illust.dart';

class Worker {
  Map<String, Illusts> map = Map();
  Dio dio = Dio(BaseOptions(headers: PixivHeader));
  Queue queue = Queue();
  Future<String> enque(String fileName, url, Illusts illusts) async {
    queue.add(Task(fileName, url, illusts));
    Directory tempPath = await getTemporaryDirectory();
    await dio.download(url, '$tempPath' + Platform.pathSeparator + fileName,
        onReceiveProgress: (start, end) {});
  }
}

class Task {
  final String fileName;
  final String url;
  final Illusts illusts;

  Task(this.fileName, this.url, this.illusts);
}
