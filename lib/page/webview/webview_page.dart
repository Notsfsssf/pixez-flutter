import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:pixez/er/leader.dart';
import 'package:pixez/generated/l10n.dart';
import 'package:pixez/main.dart';
import 'package:pixez/weiss_plugin.dart';
import 'package:url_launcher/url_launcher.dart';

class WebViewPage extends StatefulWidget {
  final String url;

  const WebViewPage({Key key, @required this.url}) : super(key: key);

  @override
  _WebViewPageState createState() => _WebViewPageState();
}

class _WebViewPageState extends State<WebViewPage> {
  InAppWebViewController _webViewController;
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
              onPressed: () => launch(widget.url)),
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
                  initialUrl: widget.url,
                  initialOptions: InAppWebViewGroupOptions(
                    crossPlatform: InAppWebViewOptions(
                      useShouldOverrideUrlLoading: true,
                      debuggingEnabled: kDebugMode,
                    ),
                  ),
                  onWebViewCreated: (InAppWebViewController controller) {
                    _webViewController = controller;
                  },
                  onReceivedServerTrustAuthRequest:
                      (controller, challenge) async {
                    if (_alreadyAgree) {
                      return ServerTrustAuthResponse(
                          action: ServerTrustAuthResponseAction.PROCEED);
                    }
                    final result = await showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (context) {
                          return AlertDialog(
                            title: Text("${challenge.message},continue?"),
                            actions: [
                              FlatButton(
                                onPressed: () {
                                  Navigator.of(context).pop("cancel");
                                },
                                child: Text(I18n.of(context).cancel),
                              ),
                              FlatButton(
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
                  onLoadStart:
                      (InAppWebViewController controller, String url) {},
                  onLoadStop:
                      (InAppWebViewController controller, String url) async {
                    if (!userSetting.disableBypassSni &&
                        !url.startsWith("pixiv://"))
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
                      ShouldOverrideUrlLoadingRequest
                          shouldOverrideUrlLoadingRequest) async {
                    if (shouldOverrideUrlLoadingRequest.url
                        .startsWith("pixiv://")) {
                      Leader.pushWithUri(context,
                          Uri.parse(shouldOverrideUrlLoadingRequest.url));
                      Navigator.of(context).pop();
                      return ShouldOverrideUrlLoadingAction.CANCEL;
                    }
                    return ShouldOverrideUrlLoadingAction.ALLOW;
                  }),
            ),
          ],
        );
      }),
    );
  }
}
