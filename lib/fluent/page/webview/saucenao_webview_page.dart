import 'dart:io';
import 'dart:typed_data';

import 'package:bot_toast/bot_toast.dart';
import 'package:dio/dio.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';
import 'package:pixez/custom_tab_plugin.dart';
import 'package:pixez/er/leader.dart';
import 'package:pixez/fluent/component/bounds_reporting_widget.dart';
import 'package:pixez/fluent/navigation_framework.dart';
import 'package:pixez/webview_plugin.dart';

class SauncenaoWebview extends StatefulWidget {
  final String? path;
  const SauncenaoWebview({super.key, this.path});

  @override
  State<SauncenaoWebview> createState() => _SauncenaoWebviewState();
}

class _SauncenaoWebviewState extends State<SauncenaoWebview> with RouteAware {
  var _url = "https://saucenao.com/";
  double _progress = 0.0;
  Rect? _currentBounds;
  bool _started = false;
  bool _isClosed = false;
  String? _htmlContent;
  bool _isLoading = false;
  RouteObserver<ModalRoute<dynamic>>? _routeObserver;
  ModalRoute<dynamic>? _subscribedRoute;

  @override
  void initState() {
    super.initState();
    _url = widget.path == null
        ? "https://saucenao.com/"
        : "https://saucenao.com/search.php";
    if (Platform.isLinux && widget.path != null) {
      _loadSearch();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!Platform.isLinux) return;
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
    if (Platform.isLinux) {
      WebviewPlugin.close();
    }
    super.dispose();
  }

  @override
  void didPushNext() {
    _isClosed = true;
    if (Platform.isLinux) {
      WebviewPlugin.close();
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final route = _subscribedRoute;
        if (route != null && route.isActive) {
          route.navigator?.removeRoute(route);
        }
      }
    });
  }

  Future<void> _loadSearch() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
      });
    } else {
      _isLoading = true;
    }
    try {
      String host = "saucenao.com";
      Dio dio = Dio(
        BaseOptions(
          baseUrl: "https://saucenao.com",
          headers: {HttpHeaders.hostHeader: host},
        ),
      );
      final tmpPath =
          "${(await getTemporaryDirectory()).path}/${DateTime.now().millisecondsSinceEpoch}.jpg";
      await File(
        tmpPath,
      ).writeAsBytes(_compressImage(await File(widget.path!).readAsBytes()));

      var formData = FormData();
      formData.files.addAll([
        MapEntry("file", await MultipartFile.fromFile(tmpPath)),
      ]);

      Response response = await dio.post('/search.php', data: formData);
      _htmlContent = response.data;

      if (_started && !_isClosed && _htmlContent != null) {
        if (Platform.isLinux) {
          await WebviewPlugin.loadHtml(
            _htmlContent!,
            baseUrl: "https://saucenao.com/",
          );
        }
      } else if (!_started && _currentBounds != null) {
        _startWebview();
      }
    } catch (e) {
      BotToast.showText(text: e.toString());
      print(e);
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      } else {
        _isLoading = false;
      }
    }
  }

  void _onBoundsChanged(Rect rect) {
    if (_isClosed || !Platform.isLinux) return;
    _currentBounds = rect;
    if (!_started) {
      if (widget.path == null || _htmlContent != null) {
        _startWebview();
      }
    } else {
      WebviewPlugin.updateBounds(rect);
    }
  }

  Future<void> _startWebview() async {
    if (_started || _isClosed || _currentBounds == null || !Platform.isLinux) return;
    _started = true;
    await WebviewPlugin.open(
      url: _htmlContent == null ? _url : null,
      html: _htmlContent,
      baseUrl: "https://saucenao.com/",
      bounds: _currentBounds,
      progressCallback: (progress) {
        if (mounted && !_isClosed) {
          setState(() {
            _progress = progress;
          });
        }
      },
      urlCallback: (url) {
        if (mounted && !_isClosed) {
          _handleUrl(url);
        }
      },
    );
  }

  void _handleUrl(String url) {
    final uri = Uri.tryParse(url);
    if (uri == null) return;
    if (uri.scheme == "pixiv") {
      Leader.pushWithUri(context, uri);
      if (mounted) {
        Navigator.of(context).pop("OK");
      }
    } else if (uri.host.contains("pixiv")) {
      Leader.pushWithUri(context, uri);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLinux = Platform.isLinux;
    return ScaffoldPage(
      padding: EdgeInsets.zero,
      header: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Row(
          children: [
            if (isLinux) ...[
              IconButton(
                icon: const Icon(FluentIcons.back),
                onPressed: () => WebviewPlugin.goBack(),
              ),
              const SizedBox(width: 8.0),
              IconButton(
                icon: const Icon(FluentIcons.refresh),
                onPressed: () {
                  if (widget.path != null && _htmlContent != null) {
                    WebviewPlugin.loadHtml(
                      _htmlContent!,
                      baseUrl: "https://saucenao.com/",
                    );
                  } else {
                    WebviewPlugin.reload();
                  }
                },
              ),
              const SizedBox(width: 8.0),
            ],
            IconButton(
              icon: const Icon(FluentIcons.open_in_new_window),
              onPressed: () {
                try {
                  CustomTabPlugin.launch(_url);
                } catch (e) {
                  BotToast.showText(text: e.toString());
                }
              },
            ),
            if (isLinux) ...[
              const SizedBox(width: 16.0),
              if (_isLoading || _progress < 1.0)
                Expanded(
                  child: ProgressBar(
                    value: _isLoading ? null : _progress * 100,
                  ),
                ),
            ],
          ],
        ),
      ),
      content: isLinux
          ? BoundsReportingWidget(
              onBoundsChanged: _onBoundsChanged,
              child: Container(
                color: FluentTheme.of(context).scaffoldBackgroundColor,
              ),
            )
          : Center(
              child: Text(
                'Not implemented',
                style: FluentTheme.of(context).typography.subtitle,
              ),
            ),
    );
  }
}

Uint8List _compressImage(Uint8List originImageBytes) {
  var originImage = img.decodeImage(originImageBytes);
  if (originImage == null) return originImageBytes;
  var originWidth = originImage.width;
  var originHeight = originImage.height;
  int newWidth, newHeight;
  if (originWidth < 720 || originHeight < 720) {
    newWidth = originWidth;
    newHeight = originHeight;
  } else if (originWidth > originHeight) {
    newHeight = 720;
    newWidth = originWidth * newHeight ~/ originHeight;
  } else {
    newWidth = 720;
    newHeight = originHeight * newWidth ~/ originWidth;
  }
  var newImage = img.copyResize(
    originImage,
    width: newWidth,
    height: newHeight,
  );
  return img.encodeJpg(newImage, quality: 75);
}
