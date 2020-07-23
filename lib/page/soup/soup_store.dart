import 'dart:io';

import 'package:dio/dio.dart';
import 'package:mobx/mobx.dart';
import 'package:html/parser.dart' show parse;
import 'package:pixez/models/amwork.dart';
import 'package:pixez/network/api_client.dart';

part 'soup_store.g.dart';

class SoupStore = _SoupStoreBase with _$SoupStore;

abstract class _SoupStoreBase with Store {
  final dio = Dio(BaseOptions(headers: {
    HttpHeaders.acceptLanguageHeader: ApiClient.Accept_Language,
    //不同语言dom元素居然不一样
    HttpHeaders.userAgentHeader:
        'Mozilla/5.0 (iPhone; CPU iPhone OS 13_2_3 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/13.0.3 Mobile/15E148 Safari/604.1 Edg/85.0.4183.15',
    HttpHeaders.refererHeader: 'https://www.pixivision.net/zh/',
  }));
  ObservableList<AmWork> amWorks = ObservableList();
  @observable
  String description;

  @action
  fetch(String url) async {
    try {
      Response response = await dio.request(url);
      var document = parse(response.data);
      var aTags = document.getElementsByTagName('a');
      var ids = aTags
          .where((element) => element.attributes['href'].contains('https://www.pixiv.net/artworks'));
      for(var i in ids){

      }
    } catch (e) {}
    // Response response = await dio.request(url);
    // print(response.data);
    // var document = parse(response.data);
    // var workInfo = document.getElementsByClassName("am__body");
    // var nodes = workInfo.first.nodes;
    // var amWorkGtmDocument = parse(workInfo.first.innerHtml);
    // description = document
    //     .getElementsByClassName('am__description _medium-editor-text')
    //     .first
    //     .innerHtml
    //     .replaceAll('<p>', '')
    //     .replaceAll('</p>', '')
    //     .replaceAll('</br>', '')
    //     .replaceAll('<br>', '');
    // amWorks.clear();
    // for (int i = 1; i <= nodes.length; i++) {
    //   try {
    //     AmWork amWork = AmWork();
    //     var amWorkGtm = amWorkGtmDocument.getElementsByClassName(
    //         "am__work gtm__illust-collection-illusts-${i}");
    //     var infoDoc = parse(amWorkGtm.first.innerHtml)
    //         .getElementsByClassName("am__work__info");
    //     var link = infoDoc.first.getElementsByTagName("a");
    //     amWork.title = infoDoc.first
    //         .getElementsByTagName('h3')
    //         .first
    //         .getElementsByTagName('a')
    //         .first
    //         .text;
    //     amWork.user = infoDoc.first
    //         .getElementsByTagName('p')
    //         .first
    //         .getElementsByTagName('a')
    //         .first
    //         .text;
    //     amWork.userImage =
    //         infoDoc.first.getElementsByTagName('img').first.attributes['src'];
    //     amWork.userLink = link.first.attributes['href'];
    //     var mainDoc = parse(amWorkGtm.first.innerHtml)
    //         .getElementsByClassName("am__work__main");
    //     amWork.arworkLink =
    //         mainDoc.first.getElementsByTagName('a').first.attributes['href'];
    //     amWork.showImage =
    //         mainDoc.first.getElementsByTagName('img').first.attributes['src'];

    //     amWorks.add(amWork);
    //   } catch (e) {
    //     print(e);
    //     continue;
    //   }
    // }
  }

  _fetchZh(url) async {
    Response response = await dio.request(url);
    print(response.data);
    var document = parse(response.data)
        .getElementsByTagName('article')
        .first
        .getElementsByTagName('header')
        .first;
    description =
        document.getElementsByClassName('amsp__description-text').first.text;
    amWorks.clear();
    var illustCollection =
        document.getElementsByClassName('_article-illust-work');
    illustCollection.forEach((element) {
      AmWork amWork = AmWork();
      var aa = element
          .getElementsByClassName('aiwsp__title')
          .first
          .getElementsByTagName('a')
          .first;
      amWork.title = aa.text;
      amWork.arworkLink = aa.attributes['href'];
      var ua = element
          .getElementsByClassName('aiwsp__user-name')
          .first
          .getElementsByTagName('a')
          .first;
      amWork.user = ua.text;
      amWork.userLink = ua.attributes['href'];
      amWork.userImage = element
          .getElementsByClassName('aiwsp__uesr-icon')
          .first
          .getElementsByTagName('img')
          .first
          .attributes['data-src'];
      var ia = element
          .getElementsByClassName('aiwsp__main')
          .first
          .getElementsByTagName('a')
          .first;
      amWork.showImage =
          ia.getElementsByTagName('img').first.attributes['data-src'];
      amWorks.add(amWork);
    });
  }
}
