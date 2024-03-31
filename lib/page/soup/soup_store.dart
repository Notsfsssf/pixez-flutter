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

import 'dart:io';

import 'package:bot_toast/bot_toast.dart';
import 'package:dio/dio.dart';
import 'package:mobx/mobx.dart';
import 'package:html/parser.dart' show parse;
import 'package:pixez/main.dart';
import 'package:pixez/models/amwork.dart';
import 'package:pixez/network/api_client.dart';
import 'package:html/dom.dart';

part 'soup_store.g.dart';

class SoupStore = _SoupStoreBase with _$SoupStore;

abstract class _SoupStoreBase with Store {
  final dio = Dio(BaseOptions(headers: {
    HttpHeaders.acceptLanguageHeader:
        userSetting.languageNum < 5 ? ApiClient.Accept_Language : "en-US",
    'user-agent':
        'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/85.0.4183.26 Safari/537.36 Edg/85.0.564.13',
    HttpHeaders.refererHeader: 'https://www.pixivision.net/zh/',
  }));

  ObservableList<AmWork> amWorks = ObservableList();

  @observable
  String? description;

  @action
  fetch(String url) async {
    try {
      if (userSetting.languageNum == 0 || userSetting.languageNum >= 5) {
        _fetchEn(url);
      } else {
        _fetchCNTW(url);
      }
    } on DioException {
      BotToast.showText(text: "404 NOT FOUND");
    } catch (e) {}
  }

  _fetchEn(url) async {
    Response response = await dio.request(url);
    var document = parse(response.data);
    amWorks.clear();

    var nodes = document
        .getElementsByTagName("article")
        .first
        .getElementsByClassName('am__body')
        .first
        .children;

    Element workInfo;
    if (nodes.first.attributes['class']!.contains('_feature')) {
      // feature article body
      nodes = nodes.first.children;
      description = '';
    } else {
      workInfo = document
          .getElementsByTagName("article")
          .first
          .getElementsByTagName('header')
          .first;
      description = workInfo.toTargetString();
    }

    for (var value in nodes) {
      try {
        if (!value.attributes['class']!.contains('illust')) {
          continue;
        }
        AmWork amWork = AmWork();
        for (var aa in value.getElementsByTagName('a')) {
          var a = aa.attributes['href'];
          var segments = Uri.parse(a!).pathSegments;
          if (a.startsWith('https') &&
              segments.length > 2 &&
              segments[segments.length - 2] == 'artworks') {
            amWork.arworkLink = a;
            amWork.showImage =
                value.getElementsByTagName('img')[1].attributes['src']!;
            amWork.title = value.getElementsByTagName('h3').first.text;
          } else if (a.startsWith('https') &&
              segments.length > 2 &&
              segments[segments.length - 2] == 'users') {
            amWork.userLink = a;
            amWork.user = value.getElementsByTagName('p').first.text;
            amWork.userImage =
                value.getElementsByTagName('img').first.attributes['src']!;
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
    amWorks.clear();

    var nodes = document
        .getElementsByTagName("article")
        .first
        .getElementsByClassName('am__body')
        .first
        .children;

    Element workInfo;
    if (nodes.first.attributes['class']!.contains('_feature')) {
      // feature article body
      nodes = nodes.first.children;
      description = '';
    } else {
      workInfo = document
          .getElementsByTagName("article")
          .first
          .getElementsByTagName('header')
          .first;
      description = workInfo.toTargetString();
    }

    for (var value in nodes) {
      try {
        if (!value.attributes['class']!.contains('illust')) {
          continue;
        }
        AmWork amWork = AmWork();
        for (var aa in value.getElementsByTagName('a')) {
          var a = aa.attributes['href']!;
          if (a.contains('https://www.pixiv.net/artworks')) {
            amWork.arworkLink = a;
            amWork.showImage =
                value.getElementsByTagName('img')[1].attributes['src']!;
            amWork.title = value.getElementsByTagName('h3').first.text;
          } else if (a.contains('https://www.pixiv.net/users')) {
            amWork.userLink = a;
            amWork.user = value.getElementsByTagName('p').first.text;
            amWork.userImage =
                value.getElementsByTagName('img').first.attributes['src']!;
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

extension ElementExt on Element {
  String toTargetString() {
    return this
        .getElementsByTagName('p')
        .map((e) => e.text)
        .toList()
        .toString()
        .replaceAll('[', '')
        .replaceAll(']', '')
        .replaceAll(',', '');
  }
}
