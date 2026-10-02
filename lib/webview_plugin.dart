import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Linux only.
class WebviewPlugin {
  static const MethodChannel _channel = MethodChannel('com.perol.dev/webview');

  static void Function(double progress)? onProgress;
  static void Function(String title)? onTitle;
  static void Function(String url)? onUrlChanged;

  static bool _initialized = false;

  static void _ensureInitialized() {
    if (_initialized) return;
    _initialized = true;
    _channel.setMethodCallHandler((call) async {
      switch (call.method) {
        case 'onProgress':
          final progress = (call.arguments as num?)?.toDouble() ?? 0.0;
          onProgress?.call(progress);
          break;
        case 'onTitle':
          final title = call.arguments as String? ?? '';
          onTitle?.call(title);
          break;
        case 'onUrlChanged':
          final url = call.arguments as String? ?? '';
          onUrlChanged?.call(url);
          break;
      }
    });
  }

  /// Opens an embedded WebKit view.
  /// If [url] is provided, loads the URL.
  /// If [html] is provided, loads the HTML string with optional [baseUrl].
  /// If [handlePixivLogin] is true, resolves to redirect URL string on login success.
  /// Resolves to redirect URL string on success, or null on cancellation/close.
  static Future<String?> open({
    String? url,
    String? html,
    String? baseUrl,
    Rect? bounds,
    bool handlePixivLogin = false,
    void Function(double progress)? progressCallback,
    void Function(String title)? titleCallback,
    void Function(String url)? urlCallback,
  }) async {
    _ensureInitialized();
    onProgress = progressCallback;
    onTitle = titleCallback;
    onUrlChanged = urlCallback;

    try {
      final Map<String, dynamic> args = {
        if (url != null) 'url': url,
        if (html != null) 'html': html,
        if (baseUrl != null) 'baseUrl': baseUrl,
        'handlePixivLogin': handlePixivLogin,
        if (bounds != null) ...{
          'x': bounds.left,
          'y': bounds.top,
          'width': bounds.width,
          'height': bounds.height,
        },
      };
      final result = await _channel.invokeMethod<String>('open', args);
      return result;
    } catch (e) {
      debugPrint("WebviewPlugin.open error: $e");
      return null;
    } finally {
      onProgress = null;
      onTitle = null;
      onUrlChanged = null;
    }
  }

  /// Updates the position and size of the WebKit view.
  static Future<void> updateBounds(Rect bounds) async {
    try {
      await _channel.invokeMethod('updateBounds', {
        'x': bounds.left,
        'y': bounds.top,
        'width': bounds.width,
        'height': bounds.height,
      });
    } catch (e) {
      debugPrint("WebviewPlugin.updateBounds error: $e");
    }
  }

  /// Loads a new URL in the current WebKit view.
  static Future<void> loadUrl(String url) async {
    try {
      await _channel.invokeMethod('loadUrl', {'url': url});
    } catch (e) {
      debugPrint("WebviewPlugin.loadUrl error: $e");
    }
  }

  /// Loads an HTML string in the current WebKit view.
  static Future<void> loadHtml(String html, {String? baseUrl}) async {
    try {
      await _channel.invokeMethod('loadHtml', {
        'html': html,
        if (baseUrl != null) 'baseUrl': baseUrl,
      });
    } catch (e) {
      debugPrint("WebviewPlugin.loadHtml error: $e");
    }
  }

  /// Closes and destroys the WebKit view.
  static Future<void> close() async {
    try {
      await _channel.invokeMethod('close');
    } catch (e) {
      debugPrint("WebviewPlugin.close error: $e");
    }
  }

  /// Navigates back.
  static Future<void> goBack() async {
    try {
      await _channel.invokeMethod('goBack');
    } catch (e) {
      debugPrint("WebviewPlugin.goBack error: $e");
    }
  }

  /// Reloads current page.
  static Future<void> reload() async {
    try {
      await _channel.invokeMethod('reload');
    } catch (e) {
      debugPrint("WebviewPlugin.reload error: $e");
    }
  }
}
