import 'dart:io';

import 'package:bot_toast/bot_toast.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:pixez/utils/webview.dart';
import 'package:pixez/custom_tab_plugin.dart';
import 'package:pixez/er/leader.dart';
import 'package:pixez/fluent/navigation_framework.dart';
import 'package:pixez/main.dart';
import 'package:pixez/weiss_plugin.dart';

class WebViewPage extends StatefulWidget {
  final String url;
  final bool returnRedirectUrl;

  const WebViewPage({
    Key? key,
    required this.url,
    this.returnRedirectUrl = false,
  }) : super(key: key);

  @override
  _WebViewPageState createState() => _WebViewPageState();
}

class _WebViewPageState extends State<WebViewPage> with RouteAware {
  late final WebViewController _webViewController;
  double progressValue = 0.0;
  RouteObserver<ModalRoute<dynamic>>? _routeObserver;
  ModalRoute<dynamic>? _subscribedRoute;
  bool _loginClosed = false;
  bool _controllerDisposed = false;
  bool _redirectHandled = false;

  bool get _isLinuxLogin => Platform.isLinux && widget.returnRedirectUrl;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isLinuxLogin) return;
    final route = ModalRoute.of(context);
    if (route != null && route != _subscribedRoute) {
      _routeObserver?.unsubscribe(this);
      _routeObserver = PixEzNavigator.routeObserverOf(context);
      _routeObserver?.subscribe(this, route);
      _subscribedRoute = route;
    }
  }

  @override
  void didPushNext() {
    if (!_isLinuxLogin) return;
    // The old Linux login closed its private session when switching pages.
    _loginClosed = true;
    _disposeController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final route = _subscribedRoute;
      if (route != null && route.isActive) {
        route.navigator?.removeRoute(route);
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _webViewController = widget.returnRedirectUrl
        ? createLoginWebViewController()
        : WebViewController();
    initializeWebViewController(
      _webViewController,
      isActive: () => mounted && !_loginClosed,
      navigationDelegate: NavigationDelegate(
        onProgress: (int progress) {
          if (!mounted || _loginClosed) return;
          setState(() => progressValue = progress / 100);
        },
        onPageStarted: (String url) {},
        onPageFinished: (String url) async {
          if (!mounted || _loginClosed) return;
          final uri = Uri.parse(url);
          // The login-result route keeps the forms used by the former
          // native Linux login page.
          if (!widget.returnRedirectUrl &&
              userSetting.oauthNetworkMode.usesCompatibleConnection &&
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
        onUrlChange: _isLinuxLogin
            ? (change) => _handleRedirect(change.url)
            : null,
        onWebResourceError: (WebResourceError error) {
          if (_isLinuxLogin && error.isForMainFrame != false) {
            _handleRedirect(error.url);
          }
        },
        onNavigationRequest: (NavigationRequest request) {
          if (!mounted || _loginClosed) return NavigationDecision.prevent;
          if (widget.returnRedirectUrl &&
              ModalRoute.of(context)?.isCurrent == false) {
            return NavigationDecision.prevent;
          }
          if (_handleRedirect(request.url)) {
            return NavigationDecision.prevent;
          }
          return NavigationDecision.navigate;
        },
      ),
      userAgent: _isLinuxLogin
          ? 'Mozilla/5.0 (X11; Linux x86_64) '
                'AppleWebKit/537.36 (KHTML, like Gecko) '
                'Chrome/128.0.0.0 Safari/537.36'
          : null,
      load: () => _webViewController.loadRequest(Uri.parse(widget.url)),
    );
  }

  bool _handleRedirect(String? url) {
    if (!mounted || _loginClosed || url == null) return false;
    if (widget.returnRedirectUrl &&
        ModalRoute.of(context)?.isCurrent == false) {
      return false;
    }
    final parsed = Uri.tryParse(url);
    if (parsed == null) return false;
    if (!widget.returnRedirectUrl && parsed.scheme != 'pixiv') return false;
    final redirect = widget.returnRedirectUrl
        ? pixivLoginRedirect(parsed)
        : parsed;
    if (redirect == null) return false;
    if (_redirectHandled) return true;
    _redirectHandled = true;
    if (widget.returnRedirectUrl) {
      Navigator.of(context).pop(redirect.toString());
    } else {
      Leader.pushWithUri(context, redirect);
      Navigator.of(context).pop("OK");
    }
    return true;
  }

  void _disposeController() {
    if (_controllerDisposed) return;
    _controllerDisposed = true;
    disposeWebViewController(_webViewController);
  }

  @override
  void dispose() {
    _loginClosed = true;
    _routeObserver?.unsubscribe(this);
    _disposeController();
    if (Platform.isAndroid) WeissPlugin.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldPage(
      header: Row(
        children: [
          if (widget.returnRedirectUrl)
            IconButton(
              icon: const Icon(FluentIcons.back),
              onPressed: () async {
                if (await _webViewController.canGoBack() && mounted) {
                  await _webViewController.goBack();
                }
              },
            ),
          IconButton(
            icon: Icon(WindowsIcons.open_in_new_window),
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
          Expanded(
            child: Visibility(
              visible: progressValue < 1.0,
              child: ProgressBar(value: progressValue * 100),
            ),
          ),
        ],
      ),
      content: WebViewWidget(controller: _webViewController),
    );
  }
}
