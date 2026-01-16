import 'dart:io';
import 'dart:typed_data';

import 'package:bot_toast/bot_toast.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:image/image.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pixez/custom_tab_plugin.dart';
import 'package:pixez/er/leader.dart';

class SauncenaoWebview extends StatefulWidget {
  final String? path;
  const SauncenaoWebview({this.path});

  @override
  State<SauncenaoWebview> createState() => _SauncenaoWebviewState();
}

class _SauncenaoWebviewState extends State<SauncenaoWebview> {
  var _url = "https://saucenao.com/";
  var progressValue = 0.0;
  late final WebViewController _webViewController;
  String? _path;
  String? compressedPath;

  @override
  void initState() {
    _path = widget.path;
    _url = _path == null
        ? "https://saucenao.com/"
        : "https://saucenao.com/search.php";
    super.initState();
    _webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            setState(() {
              progressValue = progress / 100;
            });
          },
          onPageStarted: (String url) {},
          onPageFinished: (String url) {},
          onWebResourceError: (WebResourceError error) {},
          onNavigationRequest: (NavigationRequest request) {
            var uri = Uri.parse(request.url);
            if (uri.scheme == "pixiv") {
              Leader.pushWithUri(context, uri);
              Navigator.of(context).pop("OK");
              return NavigationDecision.prevent;
            } else if (uri.host.contains("pixiv")) {
              Leader.pushWithUri(context, uri);
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      );

    if (_path != null) {
      _loadSearch();
    } else {
      _webViewController.loadRequest(Uri.parse(_url));
    }
  }

  Future<void> _loadSearch() async {
    try {
      String host = "saucenao.com";
      Dio dio = Dio(
        BaseOptions(
          baseUrl: "https://saucenao.com",
          headers: {HttpHeaders.hostHeader: host},
        ),
      );
      // if (userSetting.disableBypassSni) {
      //   dio.options.baseUrl = "https://$host";
      // } else {
      //   dio.httpClientAdapter = await ApiClient.createCompatibleClient();
      // }
      if (compressedPath == null) {
        final tmpPath =
            "${(await getTemporaryDirectory()).path}/${DateTime.now().millisecondsSinceEpoch}.jpg";
        await File(
          tmpPath,
        ).writeAsBytes(compressImage(await File(_path!).readAsBytes()));
        compressedPath = tmpPath;
      }
      var formData = FormData();
      formData.files.addAll([
        MapEntry("file", await MultipartFile.fromFile(compressedPath!)),
      ]);

      Response response = await dio.post('/search.php', data: formData);
      String html = response.data;
      _webViewController.loadHtmlString(html, baseUrl: "https://saucenao.com/");
    } catch (e) {
      BotToast.showText(text: e.toString());
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(""),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.open_in_browser),
            onPressed: () {
              try {
                CustomTabPlugin.launch(_url);
              } catch (e) {
                BotToast.showText(text: e.toString());
              }
            },
          ),
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () => _webViewController.reload(),
          ),
        ],
      ),
      body: Builder(
        builder: (BuildContext context) {
          return Column(
            children: [
              Visibility(
                visible: progressValue < 1.0,
                child: LinearProgressIndicator(value: progressValue),
              ),
              Expanded(child: WebViewWidget(controller: _webViewController)),
            ],
          );
        },
      ),
    );
  }

  Uint8List compressImage(Uint8List originImageBytes) {
    var originImage = decodeImage(originImageBytes);
    var originWidth = originImage!.width;
    var originHeight = originImage.height;
    int newWidth, newHeight;
    if (originWidth < 720 || originHeight < 720) {
      newWidth = originWidth;
      newHeight = originHeight;
    } else if (originWidth > originHeight) {
      newHeight = 720;
      newWidth = originWidth * newHeight ~/ originHeight;
    } else {
      newWidth = 720;
      newHeight = originHeight * newWidth ~/ originWidth;
    }
    var newImage = copyResize(originImage, width: newWidth, height: newHeight);
    return encodeJpg(newImage, quality: 75);
  }
}
