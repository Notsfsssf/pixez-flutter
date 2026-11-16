import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';
import 'package:pixez/desktop/desktop_list_target.dart';

class DesktopLink {
  const DesktopLink(
    this.icon,
    this.label,
    this.builder, {
    this.replaceRoot = false,
  });

  final IconData icon;
  final String label;
  final WidgetBuilder builder;
  final bool replaceRoot;
}

/// A persistent desktop frame. Detail routes use the inner navigator so the
/// library navigation remains available while browsing artwork and authors.
class DesktopShell extends StatefulWidget {
  const DesktopShell({
    super.key,
    required this.selectedIndex,
    required this.labels,
    required this.onSelected,
    required this.contentBuilder,
    required this.searchBuilder,
    required this.accountBuilder,
    required this.accountLabel,
    required this.links,
    this.accountInWorkspace = false,
  });

  final int selectedIndex;
  final List<String> labels;
  final ValueChanged<int> onSelected;
  final WidgetBuilder contentBuilder;
  final WidgetBuilder searchBuilder;
  final WidgetBuilder accountBuilder;
  final String accountLabel;
  final List<DesktopLink> links;
  final bool accountInWorkspace;

  @override
  State<DesktopShell> createState() => _DesktopShellState();

  static _DesktopShellState? _current;

  /// Opens [builder] inside the workspace pane. Returns false when no desktop
  /// shell is mounted so callers can fall back to the root navigator.
  static bool open(WidgetBuilder builder) {
    final shell = _current;
    if (shell == null || !shell.mounted) return false;
    shell._open(builder);
    return true;
  }
}

class _DesktopShellState extends State<DesktopShell> {
  final _navigator = GlobalKey<NavigatorState>();
  final _focusScope = FocusScopeNode(debugLabel: 'Desktop workspace');
  late final _observer = _RouteObserver(_routeChanged);
  bool _collapsed = false;
  bool _canGoBack = false;
  Route<dynamic>? _searchRoute;

  @override
  void initState() {
    super.initState();
    DesktopShell._current = this;
  }

  void _routeChanged() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final canGoBack = _navigator.currentState?.canPop() ?? false;
      // A popped native desktop route can leave focus at the app's root.
      // Keep workspace shortcuts available without stealing an editor's focus.
      if (!_focusScope.hasFocus && ModalRoute.of(context)?.isCurrent == true) {
        _focusScope.requestFocus();
      }
      if (canGoBack != _canGoBack) setState(() => _canGoBack = canGoBack);
    });
  }

  void _select(int index) {
    _navigator.currentState?.popUntil((route) => route.isFirst);
    widget.onSelected(index);
  }

  void _open(WidgetBuilder builder) {
    _navigator.currentState?.push(MaterialPageRoute(builder: builder));
  }

  /// Cmd+F focuses the open search page instead of stacking another one.
  void _openSearch() {
    final navigator = _navigator.currentState;
    if (navigator == null) return;
    final existing = _searchRoute;
    if (existing != null && existing.isActive) {
      if (!existing.isCurrent) navigator.popUntil((route) => route == existing);
      return;
    }
    final route = MaterialPageRoute(builder: widget.searchBuilder);
    _searchRoute = route;
    navigator.push(route);
  }

  static final _scrollKeys = {
    LogicalKeyboardKey.arrowUp,
    LogicalKeyboardKey.arrowDown,
    LogicalKeyboardKey.pageUp,
    LogicalKeyboardKey.pageDown,
    LogicalKeyboardKey.home,
    LogicalKeyboardKey.end,
    LogicalKeyboardKey.space,
  };

  /// Scroll keys move the visible list rather than traversing focus, which
  /// made the page jump to whichever button received focus. Text fields and
  /// focused buttons see the keys first; Tab still moves focus.
  KeyEventResult _scrollKey(FocusNode node, KeyEvent event) {
    if (event is KeyUpEvent || !_scrollKeys.contains(event.logicalKey)) {
      return KeyEventResult.ignored;
    }
    final keyboard = HardwareKeyboard.instance;
    if (keyboard.isMetaPressed ||
        keyboard.isControlPressed ||
        keyboard.isAltPressed ||
        keyboard.isShiftPressed) {
      return KeyEventResult.ignored;
    }
    // Handled even without a list on screen, so focus never jumps instead.
    DesktopList.scroll(event.logicalKey);
    return KeyEventResult.handled;
  }

  @override
  void dispose() {
    if (DesktopShell._current == this) DesktopShell._current = null;
    _focusScope.dispose();
    super.dispose();
  }

  static const _icons = [
    Icons.home_outlined,
    Icons.leaderboard_outlined,
    Icons.favorite_border,
    Icons.search,
    Icons.tune,
  ];

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return CallbackShortcuts(
      bindings: {
        for (var i = 0; i < 5; i++)
          SingleActivator(
            [
              LogicalKeyboardKey.digit1,
              LogicalKeyboardKey.digit2,
              LogicalKeyboardKey.digit3,
              LogicalKeyboardKey.digit4,
              LogicalKeyboardKey.digit5,
            ][i],
            meta: true,
          ): () =>
              _select(i),
        const SingleActivator(LogicalKeyboardKey.keyF, meta: true): _openSearch,
        const SingleActivator(LogicalKeyboardKey.bracketLeft, meta: true): () =>
            _navigator.currentState?.maybePop(),
        const SingleActivator(LogicalKeyboardKey.keyR, meta: true):
            DesktopList.refresh,
      },
      child: FocusScope(
        node: _focusScope,
        autofocus: true,
        onKeyEvent: _scrollKey,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final expanded = !_collapsed && constraints.maxWidth >= 1050;
            return Scaffold(
              backgroundColor: colors.surfaceContainerLow,
              body: SafeArea(
                child: Row(
                  children: [
                    SizedBox(
                      width: expanded ? 220 : 76,
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 20),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Image.asset(
                                  'assets/images/icon.png',
                                  width: 32,
                                  height: 32,
                                ),
                                if (expanded) ...[
                                  const SizedBox(width: 12),
                                  Text(
                                    'PixEz',
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleLarge
                                        ?.copyWith(fontWeight: FontWeight.w700),
                                  ),
                                  const SizedBox(width: 40),
                                ],
                              ],
                            ),
                          ),
                          Expanded(
                            child: ListView(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                              ),
                              children: [
                                for (var i = 0; i < widget.labels.length; i++)
                                  _navigationItem(
                                    icon: _icons[i],
                                    label: widget.labels[i],
                                    expanded: expanded,
                                    selected: i == widget.selectedIndex,
                                    hint: '⌘${i + 1}',
                                    onTap: () => _select(i),
                                  ),
                                const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 12),
                                  child: Divider(),
                                ),
                                for (final link in widget.links)
                                  _navigationItem(
                                    icon: link.icon,
                                    label: link.label,
                                    expanded: expanded,
                                    onTap: () => link.replaceRoot
                                        ? Navigator.of(
                                            context,
                                            rootNavigator: true,
                                          ).pushReplacement(
                                            MaterialPageRoute(
                                              builder: link.builder,
                                            ),
                                          )
                                        : _open(link.builder),
                                  ),
                              ],
                            ),
                          ),
                          const Divider(indent: 16, endIndent: 16),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                            child: _navigationItem(
                              icon: Icons.account_circle_outlined,
                              label: widget.accountLabel,
                              expanded: expanded,
                              onTap: () => widget.accountInWorkspace
                                  ? _open(widget.accountBuilder)
                                  : Navigator.of(
                                      context,
                                      rootNavigator: true,
                                    ).push(
                                      MaterialPageRoute(
                                        builder: widget.accountBuilder,
                                      ),
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        children: [
                          SizedBox(
                            height: 64,
                            child: Row(
                              children: [
                                IconButton(
                                  tooltip: MaterialLocalizations.of(
                                    context,
                                  ).drawerLabel,
                                  onPressed: () =>
                                      setState(() => _collapsed = !_collapsed),
                                  icon: const Icon(Icons.view_sidebar_outlined),
                                ),
                                IconButton(
                                  tooltip:
                                      '${MaterialLocalizations.of(context).backButtonTooltip}  ⌘[',
                                  onPressed: _canGoBack
                                      ? () =>
                                            _navigator.currentState?.maybePop()
                                      : null,
                                  icon: const Icon(Icons.arrow_back),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  // Detail pages carry their own app bar title.
                                  child: Text(
                                    _canGoBack
                                        ? ''
                                        : widget.labels[widget.selectedIndex],
                                    style: Theme.of(
                                      context,
                                    ).textTheme.titleMedium,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                TextButton.icon(
                                  onPressed: _openSearch,
                                  icon: const Icon(Icons.search, size: 20),
                                  label: Text('${widget.labels[3]}   ⌘F'),
                                ),
                                const SizedBox(width: 20),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Container(
                              margin: const EdgeInsets.only(
                                right: 16,
                                bottom: 16,
                              ),
                              clipBehavior: Clip.antiAlias,
                              decoration: BoxDecoration(
                                color: colors.surface,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: colors.outlineVariant.withValues(
                                    alpha: 0.5,
                                  ),
                                ),
                              ),
                              child: LayoutBuilder(
                                builder: (context, pane) => MediaQuery(
                                  data: MediaQuery.of(
                                    context,
                                  ).copyWith(size: pane.biggest),
                                  child: Navigator(
                                    key: _navigator,
                                    observers: [_observer],
                                    onGenerateRoute: (_) => MaterialPageRoute(
                                      builder: widget.contentBuilder,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _navigationItem({
    required IconData icon,
    required String label,
    required bool expanded,
    required VoidCallback onTap,
    bool selected = false,
    String? hint,
  }) {
    final colors = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Tooltip(
        message: '$label${hint == null ? '' : '  $hint'}',
        child: Material(
          color: selected ? colors.secondaryContainer : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          child: InkWell(
            borderRadius: BorderRadius.circular(10),
            onTap: onTap,
            child: Semantics(
              selected: selected,
              button: true,
              label: expanded ? null : label,
              child: SizedBox(
                height: 44,
                child: Row(
                  mainAxisAlignment: expanded
                      ? MainAxisAlignment.start
                      : MainAxisAlignment.center,
                  children: [
                    if (expanded) const SizedBox(width: 12),
                    Icon(
                      icon,
                      size: 22,
                      color: selected
                          ? colors.onSecondaryContainer
                          : colors.onSurfaceVariant,
                    ),
                    if (expanded) ...[
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (hint != null)
                        Text(
                          hint,
                          style: Theme.of(context).textTheme.labelSmall
                              ?.copyWith(color: colors.onSurfaceVariant),
                        ),
                      const SizedBox(width: 12),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _RouteObserver extends NavigatorObserver {
  _RouteObserver(this.onChanged);
  final VoidCallback onChanged;

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) =>
      onChanged();

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) =>
      onChanged();

  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) =>
      onChanged();
}
