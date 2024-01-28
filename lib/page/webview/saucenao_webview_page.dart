import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:pixez/custom_tab_plugin.dart';
import 'package:pixez/er/leader.dart';

class SauncenaoWebview extends StatefulWidget {
  final String? path;
  const SauncenaoWebview({this.path});

  @override
  State<SauncenaoWebview> createState() => _SauncenaoWebviewState();
}

class _SauncenaoWebviewState extends State<SauncenaoWebview> {
  final _url = "https://saucenao.com/";
  var progressValue = 0.0;
  late InAppWebViewController _webViewController;
  String? _path;
  @override
  void initState() {
    _path = widget.path;
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
}
