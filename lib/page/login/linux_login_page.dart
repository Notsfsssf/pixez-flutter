import 'package:flutter/rendering.dart';
import 'package:material_ui/material_ui.dart';
import 'package:pixez/custom_tab_plugin.dart';
import 'package:pixez/i18n.dart';
import 'package:pixez/login_plugin.dart';

class LinuxLoginPage extends StatefulWidget {
  final String url;

  const LinuxLoginPage({Key? key, required this.url}) : super(key: key);

  @override
  State<LinuxLoginPage> createState() => _LinuxLoginPageState();
}

class _LinuxLoginPageState extends State<LinuxLoginPage> {
  double _progress = 0.0;
  String _title = "";
  Rect? _currentBounds;
  bool _started = false;

  @override
  void dispose() {
    LoginPlugin.close();
    super.dispose();
  }

  void _onBoundsChanged(Rect rect) {
    _currentBounds = rect;
    if (!_started) {
      _started = true;
      _startLogin();
    } else {
      LoginPlugin.updateBounds(rect, visible: true);
    }
  }

  Future<void> _startLogin() async {
    final resultUri = await LoginPlugin.open(
      widget.url,
      bounds: _currentBounds,
      progressCallback: (progress) {
        if (mounted) {
          setState(() {
            _progress = progress;
          });
        }
      },
      titleCallback: (title) {
        if (mounted && title.isNotEmpty) {
          setState(() {
            _title = title;
          });
        }
      },
    );
    if (mounted && resultUri != null && resultUri.isNotEmpty) {
      Navigator.of(context).pop(resultUri);
    }
  }

  Widget _buildAppBarAction({
    required String message,
    required Widget icon,
    required VoidCallback onPressed,
  }) {
    return Tooltip(
      message: message,
      positionDelegate: (context) {
        final double x = (context.target.dx - context.tooltipSize.width - 8.0)
            .clamp(
              8.0,
              context.overlaySize.width - context.tooltipSize.width - 8.0,
            );
        final double y =
            (context.target.dy +
                    (context.targetSize.height - context.tooltipSize.height) /
                        2.0)
                .clamp(0.0, 56.0 - context.tooltipSize.height);
        return Offset(x, y);
      }, // 这里只是为了防止 Tooltip 被 WebKit 层遮住
      child: IconButton(icon: icon, onPressed: onPressed),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Center(
          child: Tooltip(
            message: I18n.of(context).cancel,
            positionDelegate: (context) {
              final double x =
                  (context.target.dx + context.targetSize.width / 2.0 + 4.0)
                      .clamp(
                        8.0,
                        context.overlaySize.width -
                            context.tooltipSize.width -
                            8.0,
                      );
              final double y =
                  (context.target.dy +
                          (context.targetSize.height -
                                  context.tooltipSize.height) /
                              2.0)
                      .clamp(0.0, 56.0 - context.tooltipSize.height);
              return Offset(x, y);
            }, // 这里同样是为了防止 Tooltip 被 WebKit 层遮住
            child: IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
        ),
        title: Text(_title.isNotEmpty ? _title : I18n.of(context).login),
        actions: <Widget>[
          _buildAppBarAction(
            message: I18n.of(context).back,
            icon: const Icon(Icons.arrow_back),
            onPressed: () => LoginPlugin.goBack(),
          ),
          _buildAppBarAction(
            message: I18n.of(context).refresh,
            icon: const Icon(Icons.refresh),
            onPressed: () => LoginPlugin.reload(),
          ),
          _buildAppBarAction(
            message: I18n.of(context).open_in_browser,
            icon: const Icon(Icons.open_in_browser),
            onPressed: () {
              CustomTabPlugin.launch(widget.url);
            },
          ),
        ],
        bottom: _progress < 1.0
            ? PreferredSize(
                preferredSize: const Size.fromHeight(2.0),
                child: LinearProgressIndicator(value: _progress),
              )
            : null,
      ),
      body: _BoundsReportingWidget(
        onBoundsChanged: _onBoundsChanged,
        child: Container(color: Theme.of(context).scaffoldBackgroundColor),
      ),
    );
  }
}

class _BoundsReportingWidget extends SingleChildRenderObjectWidget {
  final ValueChanged<Rect> onBoundsChanged;

  const _BoundsReportingWidget({
    Key? key,
    required this.onBoundsChanged,
    Widget? child,
  }) : super(key: key, child: child);

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
