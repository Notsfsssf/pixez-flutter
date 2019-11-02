import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:window_manager/window_manager.dart';

class NavigationFramework extends StatefulWidget {
  final int initIndex;
  final Widget defaultTitle;
  final List<NavigationPaneItem> items;
  final List<NavigationPaneItem> footerItems;
  final Widget? autoSuggestBox;
  final Widget? header;
  final PaneDisplayMode displayMode;

  const NavigationFramework({
    super.key,
    this.defaultTitle = const SizedBox.shrink(),
    this.items = const [],
    this.footerItems = const [],
    this.autoSuggestBox,
    this.header,
    this.initIndex = 0,
    this.displayMode = PaneDisplayMode.auto,
  });

  @override
  State<StatefulWidget> createState() => _NavigationFrameworkState();
}

class _NavigationFrameworkState extends State<NavigationFramework>
    with WindowListener {
  final GlobalKey<PixEzNavigatorState> _navigatorKey =
      GlobalKey<PixEzNavigatorState>();

  void _traverse(
    List<NavigationPaneItem> all,
    Iterable<NavigationPaneItem> items, [
    NavigationPaneItem? parent,
  ]) {
    for (final item in items) {
      item.parent = parent;
      all.add(item);
      if (item is PaneItemExpander) _traverse(all, item.items, item);
    }
  }

  @override
  void initState() {
    super.initState();
    windowManager.addListener(this);
  }

  @override
  void dispose() {
    windowManager.removeListener(this);
    super.dispose();
  }

  @override
  void onWindowFocus() {
    // 确保只调用一次
    setState(() {});
    // 做些什么
  }

  @override
  Widget build(BuildContext context) {
    PaneItem? temporary;
    final items = [...widget.items];
    if (_navigatorKey.currentState?.isTemporary ?? false) {
      items.add(PaneItemSeparator());
      items.add(
        temporary = PaneItem(
          icon: _navigatorKey.currentState?.currentIcon,
          title: _navigatorKey.currentState?.currentTitle,
          body: const SizedBox.square(),
        ),
      );
    }

    final allItems = <NavigationPaneItem>[];
    _traverse(allItems, items);
    _traverse(allItems, widget.footerItems);

    var effectiveItems = allItems
        .where((i) => i is PaneItem && i is! PaneItemAction && i.body != null)
        .cast<PaneItem>()
        .toList();

    final temporaryIndex = temporary != null
        ? effectiveItems.indexOf(temporary)
        : -1;

    int? selected =
        _navigatorKey.currentState?.currentIndex ?? widget.initIndex;
    if (selected == -1) selected = temporaryIndex;

    assert(!selected.isNegative);
    assert(selected < effectiveItems.length);

    return KeyboardListener(
      focusNode: FocusNode(),
      autofocus: true,
      child: Listener(
        child: NavigationView(
          titleBar: TitleBar(
            title:
                _navigatorKey.currentState?.currentTitle ?? widget.defaultTitle,
            onDragStarted: () => windowManager.startDragging(),
            onDoubleTap: () async {
              bool isMaximized = await windowManager.isMaximized();
              if (!isMaximized) {
                windowManager.maximize();
              } else {
                windowManager.unmaximize();
              }
            },
            onBackRequested: _onGoBackPress,
            isBackButtonEnabled: _navigatorKey.currentState?.canGoBack ?? false,
            captionControls: SizedBox(
              width: 138,
              child: WindowCaption(
                brightness: FluentTheme.of(context).brightness,
                backgroundColor: Colors.transparent,
              ),
            ),
          ),
          pane: NavigationPane(
            displayMode: widget.displayMode,
            header: widget.header,
            items: items,
            selected: selected,
            autoSuggestBox: widget.autoSuggestBox,
            footerItems: widget.footerItems,
            onChanged: (index) {
              final item = effectiveItems[index];
              final body = item.body ?? const SizedBox.shrink();

              _navigatorKey.currentState?.pushIndex(
                index: index,
                builder: (context) => body,
              );
            },
          ),
          paneBodyBuilder: (_, _) => PixEzNavigator(
            key: _navigatorKey,
            initIndex: widget.initIndex,
            temporaryIndex: temporaryIndex,
            onUpdate: () {
              try {
                setState(() {});
              } catch (e) {}
            },
            onGenerateRoute: (settings) {
              final item = effectiveItems[widget.initIndex];
              final body = item.body ?? const SizedBox.shrink();

              return _PixEzIndexRoute(
                builder: (context) => body,
                index: widget.initIndex,
              );
            },
          ),
        ),
        onPointerDown: _onPointerDown,
      ),
      onKeyEvent: _onKeyEvent,
    );
  }

  void _onPointerDown(PointerDownEvent event) {
    if (event.kind != PointerDeviceKind.mouse) return;
    switch (event.buttons) {
      // 鼠标的后退按钮
      case kBackMouseButton:
        _onGoBack();
      // case kForwardMouseButton:
      //   _onForward();
    }
  }

  void _onKeyEvent(KeyEvent event) {
    if (event is KeyUpEvent) {
      if (HardwareKeyboard.instance.isAltPressed) {
        switch (event.logicalKey) {
          // 键盘的 Alt + 左箭头
          case LogicalKeyboardKey.arrowLeft:
            _onGoBack();
          // case LogicalKeyboardKey.arrowRight:
          //   _onForward();
        }
      }
    }
  }

  void _onGoBackPress() => _onGoBack();

  void _onGoBack() => _navigatorKey.currentState?.pop();
  // void _onForward() => _navigatorKey.currentState?.forward();
}

class PixEzNavigator extends StatefulWidget {
  final void Function() onUpdate;
  final int initIndex;
  final int temporaryIndex;
  final Route<dynamic>? Function(RouteSettings)? onGenerateRoute;
  static GlobalKey<PixEzNavigatorState>? _first;

  PixEzNavigator({
    super.key,
    required this.initIndex,
    required this.temporaryIndex,
    required this.onUpdate,
    this.onGenerateRoute,
  }) {
    if (key is GlobalKey<PixEzNavigatorState>)
      _first ??= key as GlobalKey<PixEzNavigatorState>;
  }

  @override
  PixEzNavigatorState createState() => PixEzNavigatorState();

  static PixEzNavigatorState of(
    BuildContext context, {
    bool rootNavigator = false,
  }) {
    PixEzNavigatorState? navigator;
    if (context case StatefulElement(:final PixEzNavigatorState state)) {
      navigator = state;
    }

    navigator = rootNavigator
        ? context.findRootAncestorStateOfType<PixEzNavigatorState>() ??
              navigator
        : navigator ?? context.findAncestorStateOfType<PixEzNavigatorState>();

    navigator ??= _first?.currentState;

    assert(() {
      if (navigator == null) {
        throw FlutterError(
          'Navigator operation requested with a context that does not include a Navigator.\n'
          'The context used to push or pop routes from the Navigator must be that of a '
          'widget that is a descendant of a Navigator widget.',
        );
      }
      return true;
    }());
    return navigator!;
  }

  static Future<T?> push<T extends Object?>(
    BuildContext context, {
    required Widget icon,
    required Widget title,
    required Widget Function(BuildContext) builder,
  }) => PixEzNavigator.of(
    context,
  ).push(icon: icon, title: title, builder: builder);

  static Future<T?> pushIndex<T extends Object?>(
    BuildContext context, {
    required int index,
    required Widget Function(BuildContext) builder,
  }) => PixEzNavigator.of(context).pushIndex(index: index, builder: builder);

  static void pop<T>(BuildContext context, [T? result]) =>
      of(context).pop(result);

  // static Future<dynamic> forward(BuildContext context) => of(context).forward();
}

class PixEzNavigatorState extends State<PixEzNavigator> {
  late final _PixEzNavigatorObserver _navigatorObserver;
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  NavigatorState get navigator => navigatorKey.currentState!;
  bool get canGoBack => navigator.canPop();
  // bool get canForward => _navigatorObserver.canForward;
  bool get isTemporary => _navigatorObserver.isTemporary;
  int get currentIndex => _navigatorObserver.currentIndex;
  Widget? get currentTitle => _navigatorObserver.currentTitle;
  Widget? get currentIcon => _navigatorObserver.currentIcon;

  @override
  void initState() {
    super.initState();

    _navigatorObserver = _PixEzNavigatorObserver(
      initIndex: widget.initIndex,
      onUpdate: widget.onUpdate,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Navigator(
      key: navigatorKey,
      observers: [_navigatorObserver],
      onGenerateRoute: widget.onGenerateRoute,
    );
  }

  Future<T?> push<T extends Object?>({
    required Widget icon,
    required Widget title,
    required Widget Function(BuildContext) builder,
  }) => navigator.push(
    PixEzPageRoute.temporary<T>(builder: builder, icon: icon, title: title),
  );

  Future<T?> pushIndex<T extends Object?>({
    required int index,
    required Widget Function(BuildContext) builder,
  }) async {
    if (isTemporary &&
        widget.temporaryIndex >= 0 &&
        widget.temporaryIndex < index)
      index--;

    return await navigator.push(
      PixEzPageRoute.index<T>(builder: builder, index: index),
    );
  }

  void pop<T>([T? result]) {
    if (navigator.canPop()) navigator.pop(result);
  }

  // Future<dynamic> forward() => _navigatorObserver.forward();
}

class _PixEzNavigatorObserver extends NavigatorObserver {
  late int _cacheIndex;
  Widget? _cacheTitle = null;
  Widget? _cacheIcon = null;

  final void Function() onUpdate;
  // final List<Route<dynamic>> _forward = [];

  /// 当前的页面
  Route<dynamic>? _current = null;

  _PixEzNavigatorObserver({required int initIndex, required this.onUpdate}) {
    _cacheIndex = initIndex;
  }

  bool get canGoBack => navigator?.canPop() ?? false;
  // bool get canForward => _forward.isNotEmpty;
  bool get isTemporary => _current is! _PixEzIndexRoute;

  /// 当前页面索引 (模态对话框不更新此值)
  int get currentIndex => _cacheIndex;

  /// 临时页面标题
  Widget? get currentTitle => _cacheTitle;

  /// 临时页面图标
  Widget? get currentIcon => _cacheIcon;

  // Future<dynamic> forward() async {
  //   if (_forward.isEmpty) return null;

  //   final item = _forward.removeLast();

  //   return await navigator?.push(item);
  // }

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);

    // 记录当前页面
    _current = route;

    // 清除前进列表
    // _forward.clear();

    // 更新当前页面索引
    _updateIndex(route);
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPop(route, previousRoute);

    // 记录前进列表
    // if (previousRoute != null) _forward.add(route);

    // 记录当前页面
    _current = previousRoute;

    // 更新当前页面索引
    _updateIndex(previousRoute);
  }

  void _updateIndex(Route<dynamic>? route) {
    if (route is _PixEzTemporaryRoute) {
      _cacheIndex = -1;
      _cacheTitle = route.title;
      _cacheIcon = route.icon;
    } else if (route is _PixEzIndexRoute) {
      _cacheIndex = route.index;
      _cacheTitle = null;
      _cacheIcon = null;
    }

    // 通知更新
    onUpdate();
  }
}

class PixEzPageRoute<T> extends FluentPageRoute<T> {
  PixEzPageRoute({required super.builder});

  bool get isTemporary => this is _PixEzTemporaryRoute;

  static PixEzPageRoute<T> index<T>({
    required Widget Function(BuildContext) builder,
    required int index,
  }) => _PixEzIndexRoute<T>(builder: builder, index: index);

  static PixEzPageRoute<T> temporary<T>({
    required Widget Function(BuildContext) builder,
    required Widget icon,
    required Widget title,
  }) => _PixEzTemporaryRoute<T>(builder: builder, icon: icon, title: title);
}

class _PixEzIndexRoute<T> extends PixEzPageRoute<T> {
  final int index;
  _PixEzIndexRoute({required super.builder, required this.index});
}

class _PixEzTemporaryRoute<T> extends PixEzPageRoute<T> {
  final Widget icon;
  final Widget title;
  _PixEzTemporaryRoute({
    required super.builder,
    required this.icon,
    required this.title,
  });
}
