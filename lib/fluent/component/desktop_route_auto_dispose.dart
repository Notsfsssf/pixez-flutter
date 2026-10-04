import 'package:flutter/widgets.dart';
import 'package:pixez/constants.dart';
import 'package:pixez/fluent/navigation_framework.dart';

/// Wraps a page widget on desktop to automatically remove its route from
/// [PixEzNavigator] when a new route is pushed on top of it.
class DesktopRouteAutoDispose extends StatefulWidget {
  final Widget child;

  const DesktopRouteAutoDispose({super.key, required this.child});

  @override
  State<DesktopRouteAutoDispose> createState() =>
      _DesktopRouteAutoDisposeState();
}

class _DesktopRouteAutoDisposeState extends State<DesktopRouteAutoDispose>
    with RouteAware {
  RouteObserver<ModalRoute<dynamic>>? _routeObserver;
  ModalRoute<dynamic>? _subscribedRoute;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (Constants.isFluent) {
      final modalRoute = ModalRoute.of(context);
      if (modalRoute != null && modalRoute != _subscribedRoute) {
        _routeObserver?.unsubscribe(this);
        _routeObserver = PixEzNavigator.routeObserverOf(context);
        _routeObserver?.subscribe(this, modalRoute);
        _subscribedRoute = modalRoute;
      }
    }
  }

  @override
  void dispose() {
    _routeObserver?.unsubscribe(this);
    super.dispose();
  }

  @override
  void didPushNext() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final route = _subscribedRoute;
        if (route != null && route.isActive) {
          route.navigator?.removeRoute(route);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
