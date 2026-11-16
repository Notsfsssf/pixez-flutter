import 'dart:io';

import 'package:flutter/services.dart';
import 'package:window_manager/window_manager.dart';

/// Native macOS window full screen for image viewers. SystemChrome's
/// immersive mode, which the touch viewers use, does nothing on macOS.
/// Without the window_manager channel (tests, other hosts) it is a no-op.
class WindowFullScreen {
  static Future<bool> get isActive async {
    if (!Platform.isMacOS) return false;
    try {
      return await windowManager.isFullScreen();
    } on MissingPluginException {
      return false;
    }
  }

  static Future<void> set(bool value) async {
    if (!Platform.isMacOS) return;
    try {
      if (await windowManager.isFullScreen() != value) {
        await windowManager.setFullScreen(value);
      }
    } on MissingPluginException {
      // Nothing to change.
    }
  }

  /// Returns the new state.
  static Future<bool> toggle() async {
    final value = !await isActive;
    await set(value);
    return value;
  }
}
