import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:webview_all_linux/webview_all_linux.dart' as wa_linux;
import 'package:webview_platform_interface/webview_platform_interface.dart' as wa_pi;
import 'package:webview_flutter_platform_interface/webview_flutter_platform_interface.dart' as wf_pi;

/// Linux platform implementation of [wf_pi.WebViewPlatform] backed by [wa_linux.LinuxWebViewPlatform].
class LinuxWebViewFlutterPlatform extends wf_pi.WebViewPlatform {
  /// Registers this implementation as the default platform instance.
  static void registerWith() {
    wf_pi.WebViewPlatform.instance = LinuxWebViewFlutterPlatform();
  }

  @override
  wf_pi.PlatformWebViewController createPlatformWebViewController(
    wf_pi.PlatformWebViewControllerCreationParams params,
  ) {
    return LinuxPlatformWebViewController(params);
  }

  @override
  wf_pi.PlatformNavigationDelegate createPlatformNavigationDelegate(
    wf_pi.PlatformNavigationDelegateCreationParams params,
  ) {
    return LinuxPlatformNavigationDelegate(params);
  }

  @override
  wf_pi.PlatformWebViewWidget createPlatformWebViewWidget(
    wf_pi.PlatformWebViewWidgetCreationParams params,
  ) {
    return LinuxPlatformWebViewWidget(params);
  }

  @override
  wf_pi.PlatformWebViewCookieManager createPlatformCookieManager(
    wf_pi.PlatformWebViewCookieManagerCreationParams params,
  ) {
    return LinuxPlatformWebViewCookieManager(params);
  }
}

class LinuxPlatformWebViewController extends wf_pi.PlatformWebViewController {
  LinuxPlatformWebViewController(super.params) : super.implementation();

  late final wa_linux.LinuxWebViewController innerController =
      wa_linux.LinuxWebViewController(
    const wa_pi.PlatformWebViewControllerCreationParams(),
  );

  @override
  Future<void> loadFile(String absoluteFilePath) {
    return innerController.loadFile(absoluteFilePath);
  }

  @override
  Future<void> loadFlutterAsset(String key) {
    return innerController.loadFlutterAsset(key);
  }

  @override
  Future<void> loadHtmlString(String html, {String? baseUrl}) {
    return innerController.loadHtmlString(html, baseUrl: baseUrl);
  }

  @override
  Future<void> loadRequest(wf_pi.LoadRequestParams params) {
    return innerController.loadRequest(
      wa_pi.LoadRequestParams(
        uri: params.uri,
        method: params.method == wf_pi.LoadRequestMethod.post
            ? wa_pi.LoadRequestMethod.post
            : wa_pi.LoadRequestMethod.get,
        headers: params.headers,
        body: params.body,
      ),
    );
  }

  @override
  Future<String?> currentUrl() => innerController.currentUrl();

  @override
  Future<bool> canGoBack() => innerController.canGoBack();

  @override
  Future<bool> canGoForward() => innerController.canGoForward();

  @override
  Future<void> goBack() => innerController.goBack();

  @override
  Future<void> goForward() => innerController.goForward();

  @override
  Future<void> reload() => innerController.reload();

  @override
  Future<void> clearCache() => innerController.clearCache();

  @override
  Future<void> clearLocalStorage() => innerController.clearLocalStorage();

  @override
  Future<void> setPlatformNavigationDelegate(
    wf_pi.PlatformNavigationDelegate handler,
  ) {
    if (handler is! LinuxPlatformNavigationDelegate) {
      throw ArgumentError(
        'Expected LinuxPlatformNavigationDelegate, got ${handler.runtimeType}',
      );
    }
    return innerController.setPlatformNavigationDelegate(handler.innerDelegate);
  }

  @override
  Future<void> runJavaScript(String javaScript) {
    return innerController.runJavaScript(javaScript);
  }

  @override
  Future<Object> runJavaScriptReturningResult(String javaScript) {
    return innerController.runJavaScriptReturningResult(javaScript);
  }

  @override
  Future<void> addJavaScriptChannel(
    wf_pi.JavaScriptChannelParams javaScriptChannelParams,
  ) {
    return innerController.addJavaScriptChannel(
      wa_pi.JavaScriptChannelParams(
        name: javaScriptChannelParams.name,
        onMessageReceived: (wa_pi.JavaScriptMessage message) {
          javaScriptChannelParams.onMessageReceived(
            wf_pi.JavaScriptMessage(message: message.message),
          );
        },
      ),
    );
  }

  @override
  Future<void> removeJavaScriptChannel(String javaScriptChannelName) {
    return innerController.removeJavaScriptChannel(javaScriptChannelName);
  }

  @override
  Future<String?> getTitle() => innerController.getTitle();

  @override
  Future<void> scrollTo(int x, int y) => innerController.scrollTo(x, y);

  @override
  Future<void> scrollBy(int x, int y) => innerController.scrollBy(x, y);

  @override
  Future<void> setVerticalScrollBarEnabled(bool enabled) {
    return innerController.setVerticalScrollBarEnabled(enabled);
  }

  @override
  Future<void> setHorizontalScrollBarEnabled(bool enabled) {
    return innerController.setHorizontalScrollBarEnabled(enabled);
  }

  @override
  bool supportsSetScrollBarsEnabled() => true;

  @override
  Future<Offset> getScrollPosition() => innerController.getScrollPosition();

  @override
  Future<void> enableZoom(bool enabled) => innerController.enableZoom(enabled);

  @override
  Future<void> setBackgroundColor(Color color) {
    return innerController.setBackgroundColor(color);
  }

  @override
  Future<void> setJavaScriptMode(wf_pi.JavaScriptMode javaScriptMode) {
    return innerController.setJavaScriptMode(
      javaScriptMode == wf_pi.JavaScriptMode.unrestricted
          ? wa_pi.JavaScriptMode.unrestricted
          : wa_pi.JavaScriptMode.disabled,
    );
  }

  @override
  Future<void> setUserAgent(String? userAgent) {
    return innerController.setUserAgent(userAgent);
  }

  @override
  Future<String?> getUserAgent() => innerController.getUserAgent();

  @override
  Future<void> setOnConsoleMessage(
    void Function(wf_pi.JavaScriptConsoleMessage consoleMessage) onConsoleMessage,
  ) {
    return innerController.setOnConsoleMessage((wa_pi.JavaScriptConsoleMessage msg) {
      onConsoleMessage(
        wf_pi.JavaScriptConsoleMessage(
          level: wf_pi.JavaScriptLogLevel.values.byName(msg.level.name),
          message: msg.message,
        ),
      );
    });
  }

  @override
  Future<void> setOnScrollPositionChange(
    void Function(wf_pi.ScrollPositionChange scrollPositionChange)?
        onScrollPositionChange,
  ) {
    return innerController.setOnScrollPositionChange(
      onScrollPositionChange == null
          ? null
          : (wa_pi.ScrollPositionChange change) {
              onScrollPositionChange(
                wf_pi.ScrollPositionChange(change.x, change.y),
              );
            },
    );
  }

  @override
  Future<void> setOverScrollMode(wf_pi.WebViewOverScrollMode mode) {
    return innerController.setOverScrollMode(
      wa_pi.WebViewOverScrollMode.values.byName(mode.name),
    );
  }
}

class LinuxPlatformNavigationDelegate extends wf_pi.PlatformNavigationDelegate {
  LinuxPlatformNavigationDelegate(super.params) : super.implementation();

  late final wa_linux.LinuxNavigationDelegate innerDelegate =
      wa_linux.LinuxNavigationDelegate(
    const wa_pi.PlatformNavigationDelegateCreationParams(),
  );

  @override
  Future<void> setOnNavigationRequest(
    wf_pi.NavigationRequestCallback onNavigationRequest,
  ) {
    return innerDelegate.setOnNavigationRequest(
      (wa_pi.NavigationRequest request) async {
        final decision = await onNavigationRequest(
          wf_pi.NavigationRequest(
            url: request.url,
            isMainFrame: request.isMainFrame,
          ),
        );
        return decision == wf_pi.NavigationDecision.prevent
            ? wa_pi.NavigationDecision.prevent
            : wa_pi.NavigationDecision.navigate;
      },
    );
  }

  @override
  Future<void> setOnPageStarted(wf_pi.PageEventCallback onPageStarted) {
    return innerDelegate.setOnPageStarted(onPageStarted);
  }

  @override
  Future<void> setOnPageFinished(wf_pi.PageEventCallback onPageFinished) {
    return innerDelegate.setOnPageFinished(onPageFinished);
  }

  @override
  Future<void> setOnProgress(wf_pi.ProgressCallback onProgress) {
    return innerDelegate.setOnProgress(onProgress);
  }

  @override
  Future<void> setOnWebResourceError(
    wf_pi.WebResourceErrorCallback onWebResourceError,
  ) {
    return innerDelegate.setOnWebResourceError(
      (wa_pi.WebResourceError error) {
        onWebResourceError(
          wf_pi.WebResourceError(
            errorCode: error.errorCode,
            description: error.description,
            errorType: error.errorType != null
                ? wf_pi.WebResourceErrorType.values.asNameMap()[error.errorType!.name]
                : null,
            isForMainFrame: error.isForMainFrame,
            url: error.url,
          ),
        );
      },
    );
  }

  @override
  Future<void> setOnUrlChange(wf_pi.UrlChangeCallback onUrlChange) {
    return innerDelegate.setOnUrlChange((wa_pi.UrlChange change) {
      onUrlChange(wf_pi.UrlChange(url: change.url));
    });
  }

  @override
  Future<void> setOnHttpError(wf_pi.HttpResponseErrorCallback onHttpError) {
    return innerDelegate.setOnHttpError((wa_pi.HttpResponseError error) {
      onHttpError(
        wf_pi.HttpResponseError(
          request: error.request != null
              ? wf_pi.WebResourceRequest(
                  uri: error.request!.uri,
                )
              : null,
          response: error.response != null
              ? wf_pi.WebResourceResponse(
                  uri: error.response!.uri,
                  statusCode: error.response!.statusCode,
                  headers: error.response!.headers,
                )
              : null,
        ),
      );
    });
  }
}

class LinuxPlatformWebViewWidget extends wf_pi.PlatformWebViewWidget {
  LinuxPlatformWebViewWidget(super.params) : super.implementation();

  @override
  Widget build(BuildContext context) {
    final controller = params.controller;
    if (controller is! LinuxPlatformWebViewController) {
      throw ArgumentError(
        'Expected LinuxPlatformWebViewController, got ${controller.runtimeType}',
      );
    }
    return wa_linux.LinuxWebViewWidget(
      wa_pi.PlatformWebViewWidgetCreationParams(
        controller: controller.innerController,
        layoutDirection: params.layoutDirection,
        gestureRecognizers: params.gestureRecognizers,
      ),
    ).build(context);
  }
}

class LinuxPlatformWebViewCookieManager
    extends wf_pi.PlatformWebViewCookieManager {
  LinuxPlatformWebViewCookieManager(super.params) : super.implementation();

  late final wa_linux.LinuxWebViewCookieManager _manager =
      wa_linux.LinuxWebViewCookieManager(
    const wa_pi.PlatformWebViewCookieManagerCreationParams(),
  );

  @override
  Future<bool> clearCookies() => _manager.clearCookies();

  @override
  Future<void> setCookie(wf_pi.WebViewCookie cookie) {
    return _manager.setCookie(
      wa_pi.WebViewCookie(
        name: cookie.name,
        value: cookie.value,
        domain: cookie.domain,
        path: cookie.path,
      ),
    );
  }

  @override
  Future<List<wf_pi.WebViewCookie>> getCookies(Uri url) async {
    final cookies = await _manager.getCookies(url);
    return cookies
        .map(
          (c) => wf_pi.WebViewCookie(
            name: c.name,
            value: c.value,
            domain: c.domain,
            path: c.path,
          ),
        )
        .toList();
  }
}
