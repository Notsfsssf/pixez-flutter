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

import 'package:flutter/material.dart';
import 'package:pixez/models/spotlight_response.dart';
import 'package:pixez/page/picture/illust_page.dart';
import 'package:pixez/page/user/users_page.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebViewSpotlightPage extends StatefulWidget {
  final String url;
  final SpotlightArticle spotlight;

  const WebViewSpotlightPage({Key key, @required this.url, this.spotlight})
      : super(key: key);

  @override
  _WebViewSpotlightPageState createState() => _WebViewSpotlightPageState();
}

class _WebViewSpotlightPageState extends State<WebViewSpotlightPage> {
//  if (state.type == WebViewState.shouldStart) {
//  if (state.url.contains('d.pixiv.org') ||
//  state.url.contains('platform.twitter.com') ||
//  state.url.contains('connect.facebook.net') ||
//  state.url.contains('www.google-analytics.com')) {
//  flutterWebViewPlugin.stopLoading();
//  }
//  }
  @override
  void initState() {

    super.initState();
  }

  @override
  void dispose() {

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Builder(builder: (context) {
        return WebView(
          javascriptMode: JavascriptMode.disabled,
          navigationDelegate: (NavigationRequest request) {
            var url = request.url;
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
              return NavigationDecision.prevent;
            }
            debugPrint(url);
            return NavigationDecision.navigate;
          },
          onWebViewCreated: (WebViewController webViewController) {
            webViewController.loadUrl(widget.url);
          },
        );
      }),
    );
  }
}
