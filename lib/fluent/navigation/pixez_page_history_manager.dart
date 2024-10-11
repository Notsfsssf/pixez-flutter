import 'package:fluent_ui/fluent_ui.dart';

class PixEzPageHistoryManager extends NavigatorObserver {
  static late _PixEzNavigatorObserver observer;
  static FloatPixEzPageHistoryItem? get current => observer.current;
  static bool get canGoBack => observer.canGoBack;
  static int get currentIndex => observer.currentIndex;
  static Future<T?> pushRoute<T extends Object?>({
    required Widget icon,
    required Widget title,
    required Widget page,
  }) =>
      observer.pushRoute(
        icon: icon,
        title: title,
        page: page,
      );
  static void pushIndex(int index) => observer.pushIndex(index);
  static void pop() => observer.pop();

  static void init({
    required int initIndex,
    required List<int> skipIndexes,
    required int floatIndex,
    required Function() refresh,
  }) =>
      observer = _PixEzNavigatorObserver(
        initIndex: initIndex,
        floatIndex: floatIndex,
        skipIndexes: skipIndexes,
        refresh: refresh,
      );
}

abstract class PixEzPageHistoryItem {}

class FixedPixEzPageHistoryItem extends PixEzPageHistoryItem {
  final int index;

  FixedPixEzPageHistoryItem({
    required this.index,
  });
}

class FloatPixEzPageHistoryItem extends PixEzPageHistoryItem {
  final Widget icon;
  final Widget title;
  final Widget Function(BuildContext context) page;

  FloatPixEzPageHistoryItem({
    required this.icon,
    required this.title,
    required this.page,
  });
}

class _PixEzNavigatorObserver extends NavigatorObserver {
  final int floatIndex;
  final List<int> skipIndexes;
  final Function() refresh;
  final List<PixEzPageHistoryItem> _histories =
      List<PixEzPageHistoryItem>.empty(growable: true);

  _PixEzNavigatorObserver({
    required int initIndex,
    required this.floatIndex,
    required this.skipIndexes,
    required this.refresh,
  }) {
    _histories.add(FixedPixEzPageHistoryItem(
      index: initIndex,
    ));
  }

  /// 当前的页面
  FloatPixEzPageHistoryItem? get current {
    if (_histories.isEmpty) return null;

    if (_histories.last is FloatPixEzPageHistoryItem)
      return _histories.last as FloatPixEzPageHistoryItem;

    return null;
  }

  /// 决定窗口左上角后退按钮是否允许用户点击
  bool get canGoBack => _histories.length > 1;

  int get currentIndex {
    if (_histories.isEmpty) return -1;

    if (_histories.last is FixedPixEzPageHistoryItem)
      return (_histories.last as FixedPixEzPageHistoryItem).index;

    return floatIndex;
  }

  Future<T?> pushRoute<T extends Object?>({
    required Widget icon,
    required Widget title,
    required Widget page,
  }) async {
    final item = FloatPixEzPageHistoryItem(
      icon: icon,
      title: title,
      page: (context) => page,
    );
    _histories.add(item);
    refresh();
    // HACK: 这里可能需要改掉
    await Future.delayed(Duration(milliseconds: 50));
    assert(navigator != null);
    return await navigator!.push(FluentPageRoute<T>(
      builder: item.page,
    ));
  }

  void pushIndex(int index) {
    if (skipIndexes.contains(index)) return;
    if (current != null && index > floatIndex) index--;

    _histories.add(FixedPixEzPageHistoryItem(
      index: index,
    ));
    refresh();
  }

  Future<void> pop() async {
    assert(canGoBack);

    final isFloated = _histories.last is FloatPixEzPageHistoryItem;
    if (isFloated) navigator?.pop();
    if (_histories.isNotEmpty) _histories.removeLast();

    refresh();

    final canPop = navigator?.canPop() ?? true;
    if (!(isFloated && canPop) &&
        _histories.last is FloatPixEzPageHistoryItem) {
      final item = _histories.last as FloatPixEzPageHistoryItem;
      // HACK: 这里可能需要改掉
      await Future.delayed(Duration(milliseconds: 50));
      assert(navigator != null);
      await navigator!.push(FluentPageRoute(
        builder: item.page,
      ));
    }
  }
}
