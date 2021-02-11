import 'dart:async';
import 'dart:io';

import 'package:dio/adapter.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:http_interceptor/http_interceptor.dart';
import 'package:pixez/er/leader.dart';
import 'package:pixez/er/lprinter.dart';
import 'package:pixez/network/api_client.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:http/http.dart' as http;

class MyProxyHttpOverride extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext context) {
    return super.createHttpClient(context)
      ..findProxy = (uri) {
        return "PROXY localhost:8089;";
      }
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

class WebViewPage extends StatefulWidget {
  final String url;

  const WebViewPage({Key key, this.url}) : super(key: key);

  @override
  _WebViewPageState createState() => _WebViewPageState();
}

class _WebViewPageState extends State<WebViewPage> {
  final Completer<WebViewController> _controller =
      Completer<WebViewController>();

  @override
  void initState() {
    // initProxy();
    // initClient();
    super.initState();
    if (Platform.isAndroid) WebView.platform = SurfaceAndroidWebView();
  }

  initProxy() {
    Dio dio = Dio();
    (dio.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate =
        (client) {
      HttpClient httpClient = new HttpClient();
      httpClient.badCertificateCallback =
          (X509Certificate cert, String host, int port) {
        return true;
      };
      return httpClient;
    };
    HttpServer.bind(InternetAddress.loopbackIPv4, 8089).then((server) {
      server.listen((request) {
        LPrinter.d(request.uri.toString());
        request.response.write("obj");
        request.response.close();
        return;
        Map he = Map();
        request.headers.forEach((name, values) {
          he[name] = values.last;
        });
        request.last;
        dio.request(request.uri.path,
            options: Options(
              method: request.method,
              headers: he,
            ));
        // request.response.write(obj)
      });
    });
  }

  WebViewController _webViewController;
  initClient() {
    HttpOverrides.global = MyProxyHttpOverride();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(''),
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.open_in_browser),
              onPressed: () => launch(widget.url)),
          IconButton(
              icon: Icon(Icons.refresh),
              onPressed: () => _webViewController.reload())
        ],
      ),
      body: Builder(builder: (BuildContext context) {
        return WebView(
          initialUrl: widget.url,
          javascriptMode: JavascriptMode.unrestricted,
          onWebViewCreated: (WebViewController webViewController) {
            _webViewController = webViewController;
            _controller.complete(webViewController);
          },
          javascriptChannels: <JavascriptChannel>[].toSet(),
          navigationDelegate: (NavigationRequest request) {
            if (request.url.startsWith("pixiv:")) {
              Leader.pushWithUri(context, Uri.parse(request.url));
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
          onPageStarted: (String url) {},
          onPageFinished: (String url) {},
        );
      }),
    );
  }
}
