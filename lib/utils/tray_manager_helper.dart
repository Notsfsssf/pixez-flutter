import 'dart:io';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:pixez/main.dart';
import 'package:pixez/src/generated/i18n/app_localizations.dart';
import 'package:tray_manager/tray_manager.dart';
import 'package:window_manager/window_manager.dart';

class TrayManagerHelper with WindowListener {
  TrayManagerHelper._();

  static final TrayManagerHelper instance = TrayManagerHelper._();

  TrayIcon? _trayIcon;
  Menu? _menu;
  MenuItem? _showWindowItem;
  MenuItem? _exitItem;

  bool _isInitialized = false;

  String _getString(
    String Function(AppLocalizations l10n) getter,
    String fallback,
  ) {
    try {
      final locale = userSetting.locale is Locale
          ? (userSetting.locale as Locale)
          : PlatformDispatcher.instance.locale;
      return getter(lookupAppLocalizations(locale));
    } catch (_) {
      return fallback;
    }
  }

  /// 更新托盘菜单语言文本
  void updateMenuLabels() {
    _showWindowItem?.label = _getString((l) => l.show_window, 'Show Window');
    _exitItem?.label = _getString((l) => l.exit_pixez, 'Exit PixEz');
  }

  /// 初始化托盘管理器与窗口监听
  Future<void> init() async {
    if (!Platform.isWindows && !Platform.isMacOS && !Platform.isLinux) {
      return;
    }
    if (_isInitialized) return;

    try {
      await windowManager.ensureInitialized();

      _trayIcon = TrayIcon.create();
      if (_trayIcon == null) {
        debugPrint('[TrayManager] Failed to create TrayIcon, tray not supported');
        return;
      }

      // 设置托盘图标
      final image = ImageAsset.fromAsset('assets/images/icon.png');
      if (image != null) {
        _trayIcon!.icon = image;
      }
      _trayIcon!.setTooltip('PixEz');
      // TODO: 统一为 rightClicked
      if (Platform.isLinux) {
        _trayIcon!.setContextMenuTrigger(ContextMenuTrigger.clicked);
      } else {
        _trayIcon!.setContextMenuTrigger(ContextMenuTrigger.rightClicked);
      }

      // 创建上下文菜单
      _menu = Menu.create();
      _showWindowItem = MenuItem.createWithLabelAndType(
        _getString((l) => l.show_window, 'Show Window'),
        MenuItemType.normal,
      );
      _showWindowItem?.addListener((event) {
        if (event is MenuItemClickedEvent) {
          showWindow();
        }
      });

      _exitItem = MenuItem.createWithLabelAndType(
        _getString((l) => l.exit_pixez, 'Exit PixEz'),
        MenuItemType.normal,
      );
      _exitItem?.addListener((event) {
        if (event is MenuItemClickedEvent) {
          exitApp();
        }
      });

      if (_menu != null) {
        if (_showWindowItem != null) {
          _menu!.addItem(_showWindowItem);
        }
        _menu!.addSeparator();
        if (_exitItem != null) {
          _menu!.addItem(_exitItem);
        }
        _trayIcon!.setContextMenu(_menu);
      }

      // 监听托盘图标点击（Windows/macOS）
      _trayIcon!.addListener((event) {
        if (event is TrayIconClickedEvent) {
          toggleWindow();
        }
      });

      _trayIcon!.setVisible(true);

      // 托盘组件成功初始化后，才接管窗口关闭拦截，避免托盘不可用时形成幽灵进程
      windowManager.addListener(this);
      await windowManager.setPreventClose(true);

      _isInitialized = true;
      debugPrint('[TrayManager] TrayManager initialized successfully');
    } catch (e, stack) {
      debugPrint('[TrayManager] Initialization error: $e\n$stack');
      dispose();
      try {
        await windowManager.setPreventClose(false);
      } catch (_) {}
    }
  }

  /// 显示窗口并置顶
  Future<void> showWindow() async {
    try {
      if (await windowManager.isMinimized()) {
        await windowManager.restore();
      }
      if (!await windowManager.isVisible()) {
        await windowManager.show();
      }
      await windowManager.focus();
    } catch (e) {
      debugPrint('[TrayManager] showWindow error: $e');
    }
  }

  /// 隐藏窗口
  Future<void> hideWindow() async {
    try {
      await windowManager.hide();
    } catch (e) {
      debugPrint('[TrayManager] hideWindow error: $e');
    }
  }

  /// 切换窗口显示/隐藏状态
  Future<void> toggleWindow() async {
    try {
      final isMinimized = await windowManager.isMinimized();
      final isVisible = await windowManager.isVisible();
      final isFocused = await windowManager.isFocused();

      // 窗口处于最小化、未显示、或者未获得焦点，唤出并置顶
      if (isMinimized || !isVisible || !isFocused) {
        await showWindow();
      } else {
        await hideWindow();
      }
    } catch (e) {
      debugPrint('[TrayManager] toggleWindow error: $e');
    }
  }

  /// 退出应用
  Future<void> exitApp() async {
    try {
      dispose();
      await windowManager.setPreventClose(false);
      await windowManager.destroy();
    } catch (e) {
      debugPrint('[TrayManager] exitApp error: $e');
    } finally {
      exit(0);
    }
  }

  @override
  void onWindowClose() async {
    if (userSetting.minimizeOnExit) {
      await hideWindow();
    } else {
      await exitApp();
    }
  }

  /// 释放托盘资源
  void dispose() {
    windowManager.removeListener(this);
    _trayIcon?.dispose();
    _trayIcon = null;
    _menu?.dispose();
    _menu = null;
    _showWindowItem?.dispose();
    _showWindowItem = null;
    _exitItem?.dispose();
    _exitItem = null;
    _isInitialized = false;
  }
}
