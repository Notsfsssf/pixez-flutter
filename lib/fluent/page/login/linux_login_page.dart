import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/rendering.dart';
import 'package:pixez/custom_tab_plugin.dart';
import 'package:pixez/fluent/navigation_framework.dart';
import 'package:pixez/login_plugin.dart';

class LinuxLoginPage extends StatefulWidget {
  final String url;

  const LinuxLoginPage({super.key, required this.url});

  @override
  State<LinuxLoginPage> createState() => _LinuxLoginPageState();
}

class _LinuxLoginPageState extends State<LinuxLoginPage> with RouteAware {
  double _progress = 0.0;
  Rect? _currentBounds;
  bool _started = false;
  bool _isClosed = false;
  RouteObserver<ModalRoute<dynamic>>? _routeObserver;
  ModalRoute<dynamic>? _subscribedRoute;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final modalRoute = ModalRoute.of(context);
    if (modalRoute != null && modalRoute != _subscribedRoute) {
      _routeObserver?.unsubscribe(this);
      _routeObserver = PixEzNavigator.routeObserverOf(context);
      _routeObserver?.subscribe(this, modalRoute);
      _subscribedRoute = modalRoute;
    }
  }

  @override
  void dispose() {
    _isClosed = true;
    _routeObserver?.unsubscribe(this);
    LoginPlugin.close();
    super.dispose();
  }

  @override
  void didPushNext() {
    // 切换到其他页面，主动销毁 WebKit（因为他不会自动销毁xD）
    _isClosed = true;
    LoginPlugin.close();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final route = _subscribedRoute;
        if (route != null && route.isActive) {
          route.navigator?.removeRoute(route);
        }
      }
    });
  }

  void _onBoundsChanged(Rect rect) {
    if (_isClosed) return;
    _currentBounds = rect;
    if (!_started) {
      _started = true;
      _startLogin();
    } else {
      LoginPlugin.updateBounds(rect);
    }
  }

  Future<void> _startLogin() async {
    final resultUri = await LoginPlugin.open(
      widget.url,
      bounds: _currentBounds,
      progressCallback: (progress) {
        if (mounted && !_isClosed) {
          setState(() {
            _progress = progress;
          });
        }
      },
    );
    if (mounted && !_isClosed && resultUri != null && resultUri.isNotEmpty) {
      final route = _subscribedRoute;
      if (route != null && route.isActive) {
        if (route.isCurrent) {
          Navigator.of(context).pop(resultUri);
        } else {
          route.navigator?.removeRoute(route);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldPage(
      padding: EdgeInsets.zero,
      header: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Row(
          children: [
            IconButton(
              icon: const Icon(FluentIcons.back),
              onPressed: () => LoginPlugin.goBack(),
            ),
            const SizedBox(width: 8.0),
            IconButton(
              icon: const Icon(FluentIcons.refresh),
              onPressed: () => LoginPlugin.reload(),
            ),
            const SizedBox(width: 8.0),
            IconButton(
              icon: const Icon(FluentIcons.open_in_new_window),
              onPressed: () {
                CustomTabPlugin.launch(widget.url);
              },
            ),
            const SizedBox(width: 16.0),
            if (_progress < 1.0)
              Expanded(
                child: ProgressBar(value: _progress * 100),
              ),
          ],
        ),
      ),
      content: _BoundsReportingWidget(
        onBoundsChanged: _onBoundsChanged,
        child: Container(
          color: FluentTheme.of(context).scaffoldBackgroundColor,
        ),
      ),
    );
  }
}

class _BoundsReportingWidget extends SingleChildRenderObjectWidget {
  final ValueChanged<Rect> onBoundsChanged;

  const _BoundsReportingWidget({
    required this.onBoundsChanged,
    super.child,
  });

  @override
  RenderObject createRenderObject(BuildContext context) {
    return _RenderBoundsReporter(onBoundsChanged);
  }

  @override
  void updateRenderObject(
    BuildContext context,
    covariant _RenderBoundsReporter renderObject,
  ) {
    renderObject.onBoundsChanged = onBoundsChanged;
  }
}

class _RenderBoundsReporter extends RenderProxyBox {
  ValueChanged<Rect> onBoundsChanged;
  Rect? _lastRect;

  _RenderBoundsReporter(this.onBoundsChanged);

  @override
  void performLayout() {
    super.performLayout();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!attached) return;
      final offset = localToGlobal(Offset.zero);
      final rect = offset & size;
      if (_lastRect != rect) {
        _lastRect = rect;
        onBoundsChanged(rect);
      }
    });
  }
}
