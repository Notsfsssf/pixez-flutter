import 'dart:async';

import 'package:dio/dio.dart';
import 'package:html/parser.dart' show parse;
import 'package:image_picker/image_picker.dart';
import 'package:mobx/mobx.dart';

part 'sauce_store.g.dart';

class SauceStore = SauceStoreBase with _$SauceStore;

abstract class SauceStoreBase with Store {
  Dio dio = Dio(BaseOptions(baseUrl: "https://saucenao.com"));
  ObservableList<int> results = ObservableList();
  final picker = ImagePicker();
  StreamController _streamController;
  ObservableStream observableStream;

  SauceStoreBase() {
    _streamController = StreamController();
    observableStream =
        ObservableStream(_streamController.stream.asBroadcastStream());
  }

  @override
  void dispose() async {
    await _streamController?.close();
  }

  Future findImage() async {
    results.clear();
    final pickedFile = await picker.getImage(source: ImageSource.gallery);

    var formData = FormData();
    formData.files.addAll([
      MapEntry(
        "file",
        MultipartFile.fromFileSync(pickedFile.path),
      ),
    ]);
    Response response = await dio.post('/search.php', data: formData);
    var document = parse(response.data);
    document.querySelectorAll('a').forEach((element) {
      var link = element.attributes['href'];
      if (link != null) {
        bool need = link.startsWith('https://www.pixiv.net') &&
            link.contains('illust_id');
        if (need) {
          var result = Uri.parse(link).queryParameters['illust_id'];
          if (result != null) {
            try {
              results.add(int.parse(result));
            } catch (e) {}
          }
        }
      }
    });
    _streamController.add(1);
  }
}
