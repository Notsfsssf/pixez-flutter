import 'dart:async';
import 'dart:io';

import 'package:webview_all/webview_all.dart';
import 'package:webview_all_linux/webview_all_linux.dart';
import 'package:webview_all_windows/webview_all_windows.dart';

export 'package:webview_all/webview_all.dart';

// Native desktop initialization can finish after its page has been closed.
Future<void> initializeWebViewController(
  WebViewController controller, {
  required bool Function() isActive,
  NavigationDelegate? navigationDelegate,
  String? userAgent,
  required Future<void> Function() load,
}) async {
  try {
    if (!isActive()) return;
    await controller.setJavaScriptMode(JavaScriptMode.unrestricted);
    if (!isActive()) return;
    if (navigationDelegate != null) {
      await controller.setNavigationDelegate(navigationDelegate);
    }
    if (!isActive()) return;
    if (userAgent != null) await controller.setUserAgent(userAgent);
    if (!isActive()) return;
    await load();
  } catch (_) {
    // Errors from a live page remain visible; a closed page cancels its work.
    if (isActive()) rethrow;
  }
}

// Preserve the session isolation used by the former Linux LoginPlugin.
WebViewController createLoginWebViewController() {
  if (Platform.isLinux) {
    return WebViewController.fromPlatformCreationParams(
      const LinuxWebViewControllerCreationParams(
        incognito: true,
        developerExtrasEnabled: true,
      ),
    );
  }
  return WebViewController();
}

Uri? pixivLoginRedirect(Uri uri) {
  if (uri.scheme == 'pixiv') return uri;
  if (uri.scheme == 'https' &&
      uri.host == 'app-api.pixiv.net' &&
      uri.path == '/web/v1/users/auth/pixiv/callback') {
    return Uri(
      scheme: 'pixiv',
      host: 'account',
      path: '/login',
      query: uri.query,
    );
  }
  return null;
}

// Desktop controllers retain native resources after their widget is removed.
void disposeWebViewController(WebViewController? controller) {
  final platform = controller?.platform;
  if (platform is WindowsWebViewController) {
    unawaited(platform.dispose());
  } else if (platform is LinuxWebViewController) {
    unawaited(platform.dispose());
  }
}
