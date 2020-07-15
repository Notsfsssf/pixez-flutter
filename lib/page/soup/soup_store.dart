import 'dart:io';

import 'package:dio/dio.dart';
import 'package:mobx/mobx.dart';
import 'package:html/parser.dart' show parse;
import 'package:pixez/models/amwork.dart';
part 'soup_store.g.dart';

class SoupStore = _SoupStoreBase with _$SoupStore;

abstract class _SoupStoreBase with Store {
  final dio = Dio(BaseOptions(headers: {
    'user-agent':
        'Mozilla/5.0 (iPhone; CPU iPhone OS 13_2_3 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/13.0.3 Mobile/15E148 Safari/604.1',
    HttpHeaders.refererHeader: 'https://www.pixivision.net/zh/',
  }));
  ObservableList<AmWork> amWorks = ObservableList();
  @observable
  String description;
  @action
  fetch(String url) async {
    Response response = await dio.request(url);
    print(response.data);
    var document = parse(response.data);
    var workInfo = document.getElementsByClassName("am__body");
    var nodes = workInfo.first.nodes;
    var amWorkGtmDocument = parse(workInfo.first.innerHtml);
    description = document
        .getElementsByClassName('am__description _medium-editor-text')
        .first
        .innerHtml
        .replaceAll('<p>', '')
        .replaceAll('</p>', '')
        .replaceAll('</br>', '')
        .replaceAll('<br>', '');
    amWorks.clear();
    for (int i = 1; i <= nodes.length; i++) {
      try {
        AmWork amWork = AmWork();
        var amWorkGtm = amWorkGtmDocument.getElementsByClassName(
            "am__work gtm__illust-collection-illusts-${i}");
        var infoDoc = parse(amWorkGtm.first.innerHtml)
            .getElementsByClassName("am__work__info");
        var link = infoDoc.first.getElementsByTagName("a");
        amWork.title = infoDoc.first
            .getElementsByTagName('h3')
            .first
            .getElementsByTagName('a')
            .first
            .text;
        amWork.user = infoDoc.first
            .getElementsByTagName('p')
            .first
            .getElementsByTagName('a')
            .first
            .text;
        amWork.userImage =
            infoDoc.first.getElementsByTagName('img').first.attributes['src'];
        amWork.userLink = link.first.attributes['href'];
        var mainDoc = parse(amWorkGtm.first.innerHtml)
            .getElementsByClassName("am__work__main");
        amWork.arworkLink =
            mainDoc.first.getElementsByTagName('a').first.attributes['href'];
        amWork.showImage =
            mainDoc.first.getElementsByTagName('img').first.attributes['src'];

        amWorks.add(amWork);
      } catch (e) {
        print(e);
        continue;
      }
    }
  }
}
