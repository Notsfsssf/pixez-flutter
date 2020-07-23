/*
 * Copyright (C) 2020. by perol_notsf, All rights reserved
 *
 * This program is free software: you can redistribute it and/or modify it under
 * the terms of the GNU General Public License as published by the Free Software
 * Foundation, either version 3 of the License, or (at your option) any later version.
 *
 *  This program is distributed in the hope that it will be useful, but WITHOUT ANY
 *  WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
 *  FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License along with
 *  this program. If not, see <http://www.gnu.org/licenses/>.
 */

import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:pixez/main.dart';
import 'package:pixez/models/spotlight_response.dart';
import 'package:pixez/network/api_client.dart';
import 'package:pixez/page/picture/illust_page.dart';
import 'package:pixez/page/user/users_page.dart';

class WebViewSpotlightPage extends StatefulWidget {
  final String url;
  final SpotlightArticle spotlight;

  const WebViewSpotlightPage({Key key, @required this.url, this.spotlight})
      : super(key: key);

  @override
  _WebViewSpotlightPageState createState() => _WebViewSpotlightPageState();
}

class _WebViewSpotlightPageState extends State<WebViewSpotlightPage> {
  @override
  void initState() {
    super.initState();
  }

  Future<void> _navigate(String url) async {
    if (url.startsWith("https://www.pixiv.net")) {
      var segments = Uri.parse(url).pathSegments;
      var target = segments[1];
      if (target == 'artworks') {
        Navigator.of(context).push(MaterialPageRoute(
            builder: (_) => IllustPage(
                  id: int.parse(segments.last),
                )));
      }
      if (target == 'users') {
        Navigator.of(context).push(MaterialPageRoute(
            builder: (_) => UsersPage(
                  id: int.parse(segments.last),
                )));
      }
    }
    debugPrint(url);
  }

  @override
  void dispose() {
    super.dispose();
  }

  InAppWebViewController controller;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      extendBodyBehindAppBar: true,
      extendBody: true,
      body: InAppWebView(

        initialUrl: widget.url,
        initialHeaders: {
          HttpHeaders.acceptLanguageHeader: ApiClient.Accept_Language,
          HttpHeaders.userAgentHeader:
              'Mozilla/5.0 (iPhone; CPU iPhone OS 13_2_3 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/13.0.3 Mobile/15E148 Safari/604.1 Edg/85.0.4183.15',
        },
        initialOptions: InAppWebViewGroupOptions(
            crossPlatform: InAppWebViewOptions(
              debuggingEnabled: true,
              useShouldOverrideUrlLoading: true,
              useShouldInterceptFetchRequest: true,

            ),
            ios: IOSInAppWebViewOptions(
              sharedCookiesEnabled: false
            ),
            android: AndroidInAppWebViewOptions(
                thirdPartyCookiesEnabled:false,
                useShouldInterceptRequest: !userSetting.disableBypassSni)),
        onLoadStart: (InAppWebViewController controller, String url) {},
        onLoadStop: (InAppWebViewController controller, String url) async {},
        onLoadError: (InAppWebViewController controller, String url, int code,
            String message) {
          debugPrint(message);
        },
        shouldInterceptFetchRequest: (controller, request) {
          String url = request.url;
          if (url.contains('d.pixiv.org') ||
              url.contains('platform.twitter.com') ||
              url.contains('connect.facebook.net') ||
              url.contains('www.google-analytics.com')) {
            return Future<FetchRequest>(() {
              return FetchRequest(url: 'http://127.0.0.1'); //直接撞墙出错，减少无用js加载时间
            });
          }
          return Future<FetchRequest>(() {
            return request;
          });
        },
        shouldOverrideUrlLoading: (InAppWebViewController controller,
            ShouldOverrideUrlLoadingRequest
                shouldOverrideUrlLoadingRequest) async {
          debugPrint(shouldOverrideUrlLoadingRequest.url);
          if (Platform.isAndroid ||
              shouldOverrideUrlLoadingRequest.iosWKNavigationType ==
                  IOSWKNavigationType.LINK_ACTIVATED) {
            var url = shouldOverrideUrlLoadingRequest.url;
            if (url.startsWith("https://www.pixiv.net")) {
              var segments = Uri.parse(url).pathSegments;
              var target = segments[segments.length - 2];
              if (target == 'artworks') {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) => IllustPage(
                          id: int.parse(segments.last),
                        )));
              }
              if (target == 'users') {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) => UsersPage(
                          id: int.parse(segments.last),
                        )));
              }
            }
            return ShouldOverrideUrlLoadingAction.CANCEL;
          }
          if (!shouldOverrideUrlLoadingRequest.url.startsWith("https") ||
              shouldOverrideUrlLoadingRequest.url.contains('weibo.com')) {
            return ShouldOverrideUrlLoadingAction.CANCEL;
          }
          return ShouldOverrideUrlLoadingAction.ALLOW;
        },
        androidShouldInterceptRequest: (InAppWebViewController controller,
            WebResourceRequest request) async {
          String url = request.url;
          if (url.contains('d.pixiv.org') ||
              url.contains('platform.twitter.com') ||
              url.contains('connect.facebook.net') ||
              url.contains('pixon.ads-pixiv.net')||
              url.contains('www.google-analytics.com')) {
            return WebResourceResponse(
                contentType: "application/javascript", data: Uint8List(0));
          }
          Response<List<int>> response = await Dio().get(request.url,
              options: Options(
                  headers: request.headers, responseType: ResponseType.bytes));
          return WebResourceResponse(data: response.data);
        },
        onProgressChanged:
            (InAppWebViewController controller, int progress) async {
          if (progress >= 100) {
            try {
              var data = await controller.evaluateJavascript(source: """
var a=document.getElementsByClassName('fbbsp__inner')[0];
var b=document.getElementsByClassName('gnvsp__inner')[0];
var c=document.getElementsByTagName('section')[0];
var d=document.getElementsByClassName('amsp__related-articles')[0];
a.parentElement.removeChild(a);
b.parentElement.removeChild(b);
c.parentElement.removeChild(c);
d.parentElement.removeChild(d);
var h =document.getElementsByTagName('header')[0];
h.parentElement.removeChild(h);
  """);
            } catch (e) {}
          }
        },
      ),
    );
  }
}
