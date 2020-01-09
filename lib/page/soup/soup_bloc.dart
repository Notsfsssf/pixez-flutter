import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:html/parser.dart' show parse;

import './bloc.dart';

class SoupBloc extends Bloc<SoupEvent, SoupState> {
  final dio = Dio(BaseOptions(headers: {
    'user-agent':
        'Mozilla/5.0 (iPhone; CPU iPhone OS 13_2_3 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/13.0.3 Mobile/15E148 Safari/604.1',
    'referer': 'https://www.pixivision.net/zh/'
  }));

  @override
  SoupState get initialState => InitialSoupState();

  @override
  Stream<SoupState> mapEventToState(
    SoupEvent event,
  ) async* {
    if (event is FetchSoupEvent) {
      AmWork amWork = AmWork();
      Response response = await dio.request(event.url);
      print(response.data);
      var document = parse(response.data);
      var workInfo = document.getElementsByClassName("am__body");
      var nodes = workInfo.first.nodes;
      var amWorkGtmDocument = parse(workInfo.first.innerHtml);
      var description =document.getElementsByClassName('am__description _medium-editor-text').first.innerHtml.replaceAll('<p>', '').replaceAll('</p>', '').replaceAll('</br>', '').replaceAll('<br>', '');
      List<AmWork> amWorks = [];
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
      yield DataSoupState(amWorks,description);
    }
  }
}

class AmWork {
  String title;
  String user;
  String arworkLink;
  String userLink;
  String userImage;
  String showImage;
}
