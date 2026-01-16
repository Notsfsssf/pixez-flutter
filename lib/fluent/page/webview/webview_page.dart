import 'package:bot_toast/bot_toast.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:pixez/custom_tab_plugin.dart';
import 'package:pixez/er/leader.dart';
import 'package:pixez/main.dart';
import 'package:pixez/weiss_plugin.dart';

class WebViewPage extends StatefulWidget {
  final String url;

  const WebViewPage({Key? key, required this.url}) : super(key: key);

  @override
  _WebViewPageState createState() => _WebViewPageState();
}

class _WebViewPageState extends State<WebViewPage> {
  late final WebViewController _webViewController;
  double progressValue = 0.0;

  @override
  void initState() {
    super.initState();
    _webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            setState(() => progressValue = progress / 100);
          },
          onPageStarted: (String url) {},
          onPageFinished: (String url) async {
            final uri = Uri.parse(url);
            if (!userSetting.disableBypassSni &&
                uri.host == "accounts.pixiv.net") {
              _webViewController.runJavaScript("""
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
          onWebResourceError: (WebResourceError error) {},
          onNavigationRequest: (NavigationRequest request) {
            var uri = Uri.parse(request.url);
            if (uri.scheme == "pixiv") {
              Leader.pushWithUri(context, uri);
              Navigator.of(context).pop("OK");
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.url));
  }

  @override
  void dispose() {
    super.dispose();
    WeissPlugin.stop();
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldPage(
      header: Row(
        children: [
          IconButton(
            icon: Icon(FluentIcons.open_in_new_window),
            onPressed: () {
              try {
                CustomTabPlugin.launch(widget.url);
              } catch (e) {
                BotToast.showText(text: e.toString());
              }
            },
          ),
          IconButton(
            icon: Icon(FluentIcons.refresh),
            onPressed: () => _webViewController.reload(),
          ),
          SizedBox(width: 8.0),
          Visibility(
            visible: progressValue < 1.0,
            child: ProgressBar(value: progressValue * 100),
          ),
        ],
      ),
      content: WebViewWidget(controller: _webViewController),
    );
  }
}
