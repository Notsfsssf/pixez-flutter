import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Linux only.
class LoginPlugin {
  static const MethodChannel _channel = MethodChannel('com.perol.dev/login');

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

  /// Opens an embedded WebKit login view.
  /// Resolves to redirect URL string on success, or null on cancellation/close.
  static Future<String?> open(
    String url, {
    Rect? bounds,
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
        'url': url,
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
      debugPrint("LoginPlugin.open error: $e");
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
      debugPrint("LoginPlugin.updateBounds error: $e");
    }
  }

  /// Closes and destroys the WebKit view.
  static Future<void> close() async {
    try {
      await _channel.invokeMethod('close');
    } catch (e) {
      debugPrint("LoginPlugin.close error: $e");
    }
  }

  /// Navigates back.
  static Future<void> goBack() async {
    try {
      await _channel.invokeMethod('goBack');
    } catch (e) {
      debugPrint("LoginPlugin.goBack error: $e");
    }
  }

  /// Reloads current page.
  static Future<void> reload() async {
    try {
      await _channel.invokeMethod('reload');
    } catch (e) {
      debugPrint("LoginPlugin.reload error: $e");
    }
  }
}
