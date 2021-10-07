import 'dart:io';

import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:pixez/custom_tab_plugin.dart';
import 'package:pixez/er/leader.dart';
import 'package:pixez/i18n.dart';
import 'package:pixez/main.dart';
import 'package:pixez/weiss_plugin.dart';
import 'package:url_launcher/url_launcher.dart';

class WebViewPage extends StatefulWidget {
  final String url;

  const WebViewPage({Key? key, required this.url}) : super(key: key);

  @override
  _WebViewPageState createState() => _WebViewPageState();
}

class _WebViewPageState extends State<WebViewPage> {
  late InAppWebViewController _webViewController;
  bool _alreadyAgree = false;
  double progressValue = 0.0;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    WeissPlugin.stop();
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
                  CustomTabPlugin.launch(widget.url);
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
                  initialUrlRequest: URLRequest(url: Uri.parse(widget.url)),
                  initialOptions: InAppWebViewGroupOptions(
                      crossPlatform: InAppWebViewOptions(
                        useShouldOverrideUrlLoading: true,
                      ),
                      android: AndroidInAppWebViewOptions(
                        useHybridComposition: true,
                      )),
                  onWebViewCreated: (InAppWebViewController controller) {
                    _webViewController = controller;
                  },
                  onReceivedServerTrustAuthRequest:
                      (controller, challenge) async {
                    if (Platform.isIOS || _alreadyAgree) {
                      return ServerTrustAuthResponse(
                          action: ServerTrustAuthResponseAction.PROCEED);
                    }
                    final result = await showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (context) {
                          return AlertDialog(
                            title: Text(
                                "${challenge.protectionSpace.sslError?.message ?? "Ssl Cert Error"},continue?"),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop("cancel");
                                },
                                child: Text(I18n.of(context).cancel),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop("ok");
                                },
                                child: Text(I18n.of(context).ok),
                              ),
                            ],
                          );
                        });
                    if (result != "ok") {
                      Navigator.of(context).pop();
                    } else {
                      _alreadyAgree = true;
                    }
                    return ServerTrustAuthResponse(
                        action: result == "ok"
                            ? ServerTrustAuthResponseAction.PROCEED
                            : ServerTrustAuthResponseAction.CANCEL);
                  },
                  onLoadStop:
                      (InAppWebViewController controller, Uri? uri) async {
                    if (uri != null &&
                        !userSetting.disableBypassSni &&
                        uri.host == "pixiv.net")
                      controller.evaluateJavascript(
                          source:
                              "javascript:(function() {document.getElementsByClassName('signup-form__sns-btn-area')[0].style.display='none'; })()");
                  },
                  onProgressChanged: (controller, progress) {
                    setState(() {
                      progressValue = progress / 100;
                    });
                  },
                  shouldOverrideUrlLoading: (InAppWebViewController controller,
                      NavigationAction navigationAction) async {
                    if (navigationAction.request.url == null)
                      return NavigationActionPolicy.ALLOW;
                    var uri = navigationAction.request.url!;
                    if (uri.scheme == "pixiv") {
                      Leader.pushWithUri(context, uri);
                      Navigator.of(context).pop("OK");
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
}
