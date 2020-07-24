import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:mobx/mobx.dart';
import 'package:html/parser.dart' show parse;
import 'package:pixez/main.dart';
import 'package:pixez/models/amwork.dart';
import 'package:pixez/network/api_client.dart';

part 'soup_store.g.dart';

class SoupStore = _SoupStoreBase with _$SoupStore;

abstract class _SoupStoreBase with Store {
  final dio = Dio(BaseOptions(headers: {
    HttpHeaders.acceptLanguageHeader: ApiClient.Accept_Language,
    'user-agent':
        'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/85.0.4183.26 Safari/537.36 Edg/85.0.564.13',
    HttpHeaders.refererHeader: 'https://www.pixivision.net/zh/',
  }));
  ObservableList<AmWork> amWorks = ObservableList();
  @observable
  String description;

  @action
  fetch(String url) async {
    if(userSetting.languageNum==0){
      _fetchEn(url);
    }else{
      _fetchCNTW(url);
    }
  }
  _fetchEn(url) async{
    Response response = await dio.request(url);
    var document = parse(response.data);
    var workInfo = document
        .getElementsByTagName("article")
        .first
        .getElementsByTagName('header');
    var nodes = document
        .getElementsByTagName("article")
        .first
        .getElementsByClassName('am__body')
        .first
        .children;
    description = workInfo.first
        .getElementsByTagName('p')
        .map((e) => e.text)
        .toList()
        .toString()
        .replaceAll('[', '')
        .replaceAll(']', '')
        .replaceAll(',', '');
    amWorks.clear();
    for (var value in nodes) {
      try {
        if (!value.attributes['class'].contains('illust')) {
          continue;
        }
        AmWork amWork = AmWork();
        for (var aa in value.getElementsByTagName('a')) {
          var a = aa.attributes['href'];
          var segments = Uri.parse(a).pathSegments;
          if (a.startsWith('https')&&segments.length>2&&segments[segments.length-2]=='artworks') {
            amWork.arworkLink = a;
            amWork.showImage =
            value.getElementsByTagName('img')[1].attributes['src'];
            amWork.title = value.getElementsByTagName('h3').first.text;
          }
          if (a.startsWith('https')&&segments.length>2&&segments[segments.length-2]=='users') {
            amWork.userLink = a;
            amWork.user = value.getElementsByTagName('p').first.text;
            amWork.userImage =
            value.getElementsByTagName('img').first.attributes['src'];
          }
        }
        if (amWork.userLink == null || amWork.arworkLink == null) {
          continue;
        }
        amWorks.add(amWork);
      } catch (e) {
        print(e);
      }
    }
  }
  _fetchCNTW(url) async {
    Response response = await dio.request(url);
    var document = parse(response.data);
    var workInfo = document
        .getElementsByTagName("article")
        .first
        .getElementsByTagName('header');
    var nodes = document
        .getElementsByTagName("article")
        .first
        .getElementsByClassName('am__body')
        .first
        .children;
    description = workInfo.first
        .getElementsByTagName('p')
        .map((e) => e.text)
        .toList()
        .toString()
        .replaceAll('[', '')
        .replaceAll(']', '')
        .replaceAll(',', '');
    amWorks.clear();
    for (var value in nodes) {
      try {
        if (!value.attributes['class'].contains('illust')) {
          continue;
        }
        AmWork amWork = AmWork();
        for (var aa in value.getElementsByTagName('a')) {
          var a = aa.attributes['href'];
          if (a.contains('https://www.pixiv.net/artworks')) {
            amWork.arworkLink = a;
            amWork.showImage =
                value.getElementsByTagName('img')[1].attributes['src'];
            amWork.title = value.getElementsByTagName('h3').first.text;
          }
          if (a.contains('https://www.pixiv.net/users')) {
            amWork.userLink = a;
            amWork.user = value.getElementsByTagName('p').first.text;
            amWork.userImage =
                value.getElementsByTagName('img').first.attributes['src'];
          }
        }
        if (amWork.userLink == null || amWork.arworkLink == null) {
          continue;
        }
        amWorks.add(amWork);
      } catch (e) {
        print(e);
      }
    }
  }
}
