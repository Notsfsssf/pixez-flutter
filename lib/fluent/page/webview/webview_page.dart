import 'dart:io';

import 'package:bot_toast/bot_toast.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:pixez/custom_tab_plugin.dart';
import 'package:pixez/er/leader.dart';
import 'package:pixez/i18n.dart';
import 'package:pixez/main.dart';
import 'package:pixez/weiss_plugin.dart';

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
    return ScaffoldPage(
      header: PageHeader(
        title: Text(""),
        commandBar: CommandBar(
          mainAxisAlignment: MainAxisAlignment.end,
          primaryItems: [
            CommandBarButton(
              icon: Icon(FluentIcons.open_in_new_window),
              onPressed: () {
                try {
                  CustomTabPlugin.launch(widget.url);
                } catch (e) {
                  BotToast.showText(text: e.toString());
                }
              },
            ),
            CommandBarButton(
              icon: Icon(FluentIcons.refresh),
              onPressed: () => _webViewController.reload(),
            )
          ],
        ),
      ),
      content: Builder(builder: (BuildContext context) {
        return Column(
          children: [
            Visibility(
              visible: progressValue < 1.0,
              child: ProgressRing(
                value: progressValue,
              ),
            ),
            Expanded(
              child: InAppWebView(
                  initialUrlRequest: URLRequest(url: WebUri(widget.url)),
                  initialSettings: InAppWebViewSettings(
                      useShouldOverrideUrlLoading: true,
                      useHybridComposition: true),
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
                          return ContentDialog(
                            title: Text(
                                "${challenge.protectionSpace.sslError?.message ?? "Ssl Cert Error"},continue?"),
                            actions: [
                              HyperlinkButton(
                                onPressed: () {
                                  Navigator.of(context).pop("cancel");
                                },
                                child: Text(I18n.of(context).cancel),
                              ),
                              HyperlinkButton(
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
                        uri.host == "accounts.pixiv.net") {
                      controller.evaluateJavascript(source: """
javascript:(function() {
 let forms = document.getElementsByTagName('form'); 
 for (let name of forms) {
    if (name['method'] === 'post' || name['method'] === 'POST') {
        name.style.display = 'none';
    }
  
}
 let list = document.getElementsByClassName("sns-button-list");
 for (let name of list) {
        name.style.display = 'none';
} 
  })()
""");
                    }
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
