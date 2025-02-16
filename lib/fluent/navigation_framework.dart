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

class _NavigationFrameworkState extends State<NavigationFramework> {
  late PixEzNavigator _navigator;

  @override
  void initState() {
    super.initState();
    final (temporaryIndex, skipIndexes) = _calcTemporaryIndex();
    _navigator = PixEzNavigator(
      initIndex: widget.initIndex,
      temporaryIndex: temporaryIndex,
      skipIndexes: skipIndexes,
      onUpdate: () => setState(() {}),
    );
  }

  @override
  Widget build(BuildContext context) {
    final items = [...widget.items];
    final temporaryItem = _navigator.currentTemporary;
    if (temporaryItem != null) {
      items.add(PaneItemSeparator());
      items.add(PaneItem(
        icon: temporaryItem.icon,
        title: temporaryItem.title,
        body: Navigator(
          observers: [_navigator],
          onGenerateRoute: (settings) {
            return FluentPageRoute(
              builder: (context) => const SizedBox.shrink(),
              settings: settings,
            );
          },
        ),
      ));
    }
    return KeyboardListener(
      focusNode: FocusNode(),
      autofocus: true,
      child: Listener(
        child: NavigationView(
          appBar: NavigationAppBar(
            height: 40.0,
            leading: Row(
              children: [
                Tooltip(
                  message: '后退',
                  child: PaneItem(
                    icon: const Icon(FluentIcons.back, size: 14.0),
                    body: const SizedBox.shrink(),
                    enabled: _navigator.canGoBack,
                  ).build(
                    context,
                    false,
                    _onGoBackPress,
                    displayMode: PaneDisplayMode.compact,
                  ),
                ),
                if (_navigator.canForward)
                  Tooltip(
                    message: '前进',
                    child: PaneItem(
                      icon: const Icon(FluentIcons.forward, size: 14.0),
                      body: const SizedBox.shrink(),
                    ).build(
                      context,
                      false,
                      _onForward,
                      displayMode: PaneDisplayMode.compact,
                    ),
                  ),
              ],
            ),
            title: DragToMoveArea(
              child: Align(
                // 垂直居中文字
                alignment: AlignmentDirectional.centerStart,
                child: _navigator.currentTemporary?.title ?? widget.defaultTitle,
              ),
            ),
            actions: SizedBox(
              width: 138,
              height: 40.0,
              child: WindowCaption(
                brightness: FluentTheme.of(context).brightness,
                backgroundColor: Colors.transparent,
              ),
            ),
          ),
          pane: NavigationPane(
            displayMode: widget.displayMode,
            header: widget.header,
            selected: _navigator.currentIndex,
            autoSuggestBox: widget.autoSuggestBox,
            items: items,
            footerItems: widget.footerItems,
            onChanged: _navigator.pushIndex,
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
      case kForwardMouseButton:
        _onForward();
    }
  }

  void _onKeyEvent(KeyEvent event) {
    if (event is KeyUpEvent) {
      if (HardwareKeyboard.instance.isAltPressed) {
        switch (event.logicalKey) {
          // 键盘的 Alt + 左箭头
          case LogicalKeyboardKey.arrowLeft:
            _onGoBack();
          case LogicalKeyboardKey.arrowRight:
            _onForward();
        }
      }
    }
  }

  void _onGoBackPress() => _onGoBack();

  void _onGoBack() => _navigator.pop();
  void _onForward() => _navigator.forward();

  (int temporaryIndex, List<int> skipIndexes) _calcTemporaryIndex() {
    var temporaryIndex = 0;
    List<int> skipIndexes = [];

    void calc(List<NavigationPaneItem> items) {
      items.forEach((item) {
        temporaryIndex++;
        if (item is PaneItemExpander) {
          skipIndexes.add(temporaryIndex - 1);
          calc(item.items);
        }
      });
    }

    calc(widget.items);
    return (temporaryIndex, skipIndexes);
  }
}

class PixEzNavigator extends NavigatorObserver {
  static late PixEzNavigator instance;

  final int temporaryIndex;
  final List<int> skipIndexes;
  final List<_PixEzNavigatableItem> _histories = [];
  final List<_PixEzNavigatableItem> _forward = [];
  final void Function() onUpdate;

  PixEzNavigator({
    required int initIndex,
    required this.temporaryIndex,
    required this.skipIndexes,
    required this.onUpdate,
  }) {
    instance = this;
    _histories.add(_PixEzNavigatableItem.index(initIndex));
  }

  /// 决定窗口左上角后退按钮是否允许用户点击
  bool get canGoBack => _histories.length > 1;
  bool get canForward => _forward.isNotEmpty;

  /// 当前的页面
  _PixEzNavigatableItem get current => _histories.last;

  /// 当前的临时页面 如果不是临时页面则为 null
  _PixEzTemporaryNavigatableItem? get currentTemporary {
    if (current is _PixEzTemporaryNavigatableItem)
      return current as _PixEzTemporaryNavigatableItem;
    return null;
  }

  /// 当前页面索引
  int get currentIndex {
    assert(_histories.isNotEmpty);

    final item = current;
    return item is _PixEzIndexableNavigatableItem ? item.index : temporaryIndex;
  }

  Future<T?> pushRoute<T extends Object?>({
    required Widget icon,
    required Widget title,
    required Widget page,
  }) async {
    final builder = (BuildContext context) => page;
    final item = _PixEzNavigatableItem.temporary(
      icon: icon,
      title: title,
      page: builder,
    );
    final previous = _histories.last;
    _histories.add(item);
    _forward.clear();
    onUpdate();

    await Future.delayed(Duration(milliseconds: 50));
    assert(navigator != null);

    if (previous is _PixEzIndexableNavigatableItem)
      // 消除默认的空白页
      return await navigator!.pushAndRemoveUntil(
        FluentPageRoute(builder: builder),
        (route) => false,
      );
    else
      return await navigator!.push(FluentPageRoute(builder: builder));
  }

  void pushIndex(int index) {
    if (skipIndexes.contains(index)) return;
    if (currentTemporary != null && index > temporaryIndex) index--;

    _histories.add(_PixEzNavigatableItem.index(index));
    _forward.clear();
    onUpdate();
  }

  Future<void> forward() async {
    if (!canForward) return;

    final previous = _histories.last;
    final item = _forward.removeLast();
    _histories.add(item);
    onUpdate();

    if (item is _PixEzTemporaryNavigatableItem) {
      await Future.delayed(Duration(milliseconds: 50));
      assert(navigator != null);

      if (previous is _PixEzIndexableNavigatableItem)
        // 消除默认的空白页
        await navigator!.pushAndRemoveUntil(
          FluentPageRoute(builder: item.page),
          (route) => false,
        );
      else
        await navigator!.push(FluentPageRoute(builder: item.page));
    }
  }

  Future<void> pop() async {
    if (!canGoBack) return;

    // 移出历史
    final current = _histories.removeLast();
    _forward.add(current);
    onUpdate();

    final latest = _histories.last;

    if (latest is _PixEzTemporaryNavigatableItem) {
      await Future.delayed(Duration(milliseconds: 50));
      assert(navigator != null);

      switch (current) {
        case _PixEzIndexableNavigatableItem():
          // 此时应该 replace 进去
          await navigator!.pushAndRemoveUntil(
            FluentPageRoute(builder: latest.page),
            (route) => false,
          );

        case _PixEzTemporaryNavigatableItem():
          // 此时判断能否 pop
          // 如果不能 pop 则 replace 进去
          if (!await navigator!.maybePop()) {
            await navigator!.pushAndRemoveUntil(
              FluentPageRoute(builder: latest.page),
              (route) => false,
            );
          }
      }
    }
  }
}

abstract class _PixEzNavigatableItem {
  _PixEzNavigatableItem();
  factory _PixEzNavigatableItem.index(int index) =>
      _PixEzIndexableNavigatableItem(index: index);
  factory _PixEzNavigatableItem.temporary({
    required Widget icon,
    required Widget title,
    required Widget Function(BuildContext) page,
  }) =>
      _PixEzTemporaryNavigatableItem(
        icon: icon,
        title: title,
        page: page,
      );
}

class _PixEzIndexableNavigatableItem extends _PixEzNavigatableItem {
  final int index;
  _PixEzIndexableNavigatableItem({
    required this.index,
  });
}

class _PixEzTemporaryNavigatableItem extends _PixEzNavigatableItem {
  final Widget icon;
  final Widget title;
  final Widget Function(BuildContext) page;

  _PixEzTemporaryNavigatableItem({
    required this.icon,
    required this.title,
    required this.page,
  });
}
