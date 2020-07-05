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

import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
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

  Future findImage({String path}) async {
    results.clear();

    if (path == null)
      path = (await picker.getImage(source: ImageSource.gallery))?.path;
    if (path == null) return;
    var formData = FormData();
    formData.files.addAll([
      MapEntry(
        "file",
        MultipartFile.fromFileSync(path),
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
