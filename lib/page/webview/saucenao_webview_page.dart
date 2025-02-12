import 'dart:io';
import 'dart:typed_data';

import 'package:bot_toast/bot_toast.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:image/image.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pixez/custom_tab_plugin.dart';
import 'package:pixez/er/leader.dart';
import 'package:pixez/main.dart';
import 'package:pixez/network/api_client.dart';

class SauncenaoWebview extends StatefulWidget {
  final String? path;
  const SauncenaoWebview({this.path});

  @override
  State<SauncenaoWebview> createState() => _SauncenaoWebviewState();
}

class _SauncenaoWebviewState extends State<SauncenaoWebview> {
  var _url = "https://saucenao.com/";
  var progressValue = 0.0;
  late InAppWebViewController _webViewController;
  String? _path;
  String? compressedPath;
  @override
  void initState() {
    _path = widget.path;
    _url = _path == null
        ? "https://saucenao.com/"
        : "https://saucenao.com/search.php";
    super.initState();
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
              }),
          IconButton(
              icon: Icon(Icons.refresh),
              onPressed: () => _webViewController.reload())
        ],
      ),
      body: Builder(builder: (BuildContext context) {
        return Column(
          children: [
            Visibility(
              visible: progressValue < 1.0,
              child: LinearProgressIndicator(
                value: progressValue,
              ),
            ),
            Expanded(
              child: InAppWebView(
                  initialUrlRequest: URLRequest(url: WebUri(_url)),
                  initialSettings: InAppWebViewSettings(
                      useShouldOverrideUrlLoading: true,
                      useShouldInterceptRequest: true,
                      useHybridComposition: true),
                  onWebViewCreated: (InAppWebViewController controller) {
                    _webViewController = controller;
                    // _webViewController.postUrl(url: url, postData: postData)
                  },
                  onLoadStop:
                      (InAppWebViewController controller, Uri? uri) async {},
                  onProgressChanged: (controller, progress) {
                    setState(() {
                      progressValue = progress / 100;
                    });
                  },
                  shouldInterceptRequest: _path != null
                      ? (controller, request) async {
                          try {
                            if (request.url.path == "/search.php") {
                              String host = "saucenao.com";
                              Dio dio = Dio(BaseOptions(
                                  baseUrl: "https://saucenao.com",
                                  headers: {HttpHeaders.hostHeader: host}));
                              if (userSetting.disableBypassSni) {
                                dio.options.baseUrl = "https://$host";
                              } else {
                                dio.httpClientAdapter =
                                    await ApiClient.createCompatibleClient();
                              }
                              if (compressedPath == null) {
                                final tmpPath =
                                    "${(await getTemporaryDirectory()).path}/${DateTime.now().millisecondsSinceEpoch}.jpg";
                                await File(tmpPath).writeAsBytes(compressImage(
                                    await File(_path!).readAsBytes()));
                                compressedPath = tmpPath;
                              }
                              var formData = FormData();
                              formData.files.addAll([
                                MapEntry(
                                    "file",
                                    await MultipartFile.fromFile(
                                        compressedPath!)),
                              ]);

                              Response response =
                                  await dio.post('/search.php', data: formData);
                              String html = response.data;
                              WebResourceResponse webResourceResponse =
                                  WebResourceResponse(
                                      statusCode: 200,
                                      data: Uint8List.fromList(html.codeUnits),
                                      headers: {"Content-Type": "text/html"});
                              return webResourceResponse;
                            }
                          } catch (e) {
                            print(e);
                          }
                          return null;
                        }
                      : null,
                  shouldOverrideUrlLoading: (InAppWebViewController controller,
                      NavigationAction navigationAction) async {
                    if (navigationAction.request.url == null)
                      return NavigationActionPolicy.ALLOW;
                    var uri = navigationAction.request.url!;
                    if (uri.scheme == "pixiv") {
                      Leader.pushWithUri(context, uri);
                      Navigator.of(context).pop("OK");
                      return NavigationActionPolicy.CANCEL;
                    } else if (uri.host.contains("pixiv")) {
                      Leader.pushWithUri(context, uri);
                      return NavigationActionPolicy.CANCEL;
                    }
                    return NavigationActionPolicy.ALLOW;
                  }),
            ),
          ],
        );
      }),
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
